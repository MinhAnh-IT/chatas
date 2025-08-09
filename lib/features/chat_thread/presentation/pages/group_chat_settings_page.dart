import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/chat_thread.dart';
import '../../domain/usecases/manage_group_chat_usecase.dart';
import '../../data/repositories/chat_thread_repository_impl.dart';
import '../../../auth/di/auth_dependency_injection.dart';
import '../../../../shared/widgets/smart_image.dart';
import '../../../../shared/widgets/app_bar.dart';
import '../../../../shared/services/image_upload_service.dart';
import 'add_members_page.dart';

class GroupChatSettingsPage extends StatefulWidget {
  final ChatThread chatThread;
  final VoidCallback? onUpdate;

  const GroupChatSettingsPage({
    super.key,
    required this.chatThread,
    this.onUpdate,
  });

  @override
  State<GroupChatSettingsPage> createState() => _GroupChatSettingsPageState();
}

class _GroupChatSettingsPageState extends State<GroupChatSettingsPage> {
  late ManageGroupChatUseCase _manageGroupChatUseCase;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUpdating = false;
  bool _isUploadingImage = false;
  String _currentUserId = '';
  List<Map<String, String>> _memberDetails = [];
  bool _isLoadingMembers = true;
  String _currentGroupAvatarUrl = '';

  @override
  void initState() {
    super.initState();
    _initializeUseCase();
    _initializeData();
    _loadMemberDetails();
  }

  void _initializeUseCase() {
    final repository = ChatThreadRepositoryImpl();
    _manageGroupChatUseCase = ManageGroupChatUseCase(repository);
  }

  void _initializeData() {
    _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    _nameController.text = widget.chatThread.name;
    _descriptionController.text = widget.chatThread.groupDescription ?? '';
    _currentGroupAvatarUrl = widget.chatThread.avatarUrl;
  }

  Future<void> _loadMemberDetails() async {
    print(
      'GroupChatSettingsPage: Loading member details for ${widget.chatThread.members.length} members',
    );
    setState(() {
      _isLoadingMembers = true;
    });

    try {
      final memberDetails = <Map<String, String>>[];

      for (final memberId in widget.chatThread.members) {
        print('GroupChatSettingsPage: Loading details for member: $memberId');
        try {
          final user = await AuthDependencyInjection.authRemoteDataSource
              .getUserById(memberId);
          print(
            'GroupChatSettingsPage: getUserById for $memberId returned: ${user != null ? "user found" : "null"}',
          );

          if (user != null) {
            print(
              'GroupChatSettingsPage: User details - fullName: "${user.fullName}", email: "${user.email}", avatarUrl: "${user.avatarUrl}"',
            );
            memberDetails.add({
              'id': memberId,
              'name': user.fullName.isNotEmpty
                  ? user.fullName
                  : (user.email.isNotEmpty
                        ? user.email.split('@')[0]
                        : 'Người dùng'),
              'email': user.email,
              'avatarUrl': user.avatarUrl,
            });
          } else {
            print(
              'GroupChatSettingsPage: User not found, trying direct Firestore query for $memberId',
            );
            // Fallback: Direct Firestore query
            try {
              final firestore = FirebaseFirestore.instance;
              final userDoc = await firestore
                  .collection('users')
                  .doc(memberId)
                  .get();
              print(
                'GroupChatSettingsPage: Direct Firestore - document exists: ${userDoc.exists}',
              );

              if (userDoc.exists) {
                final data = userDoc.data()!;
                final fullName = data['fullName'] as String? ?? '';
                final email = data['email'] as String? ?? '';
                final avatarUrl = data['avatarUrl'] as String? ?? '';

                print(
                  'GroupChatSettingsPage: Direct Firestore data - fullName: "$fullName", email: "$email"',
                );

                memberDetails.add({
                  'id': memberId,
                  'name': fullName.isNotEmpty
                      ? fullName
                      : (email.isNotEmpty
                            ? email.split('@')[0]
                            : 'Người dùng $memberId'),
                  'email': email,
                  'avatarUrl': avatarUrl,
                });
              } else {
                print(
                  'GroupChatSettingsPage: Document does not exist for $memberId',
                );
                memberDetails.add({
                  'id': memberId,
                  'name': 'Người dùng $memberId',
                  'email': '',
                  'avatarUrl': '',
                });
              }
            } catch (e2) {
              print(
                'GroupChatSettingsPage: Direct Firestore query failed for $memberId: $e2',
              );
              memberDetails.add({
                'id': memberId,
                'name': 'Người dùng $memberId',
                'email': '',
                'avatarUrl': '',
              });
            }
          }
        } catch (e) {
          print('GroupChatSettingsPage: Error loading member $memberId: $e');
          memberDetails.add({
            'id': memberId,
            'name': 'Người dùng $memberId',
            'email': '',
            'avatarUrl': '',
          });
        }
      }

      print(
        'GroupChatSettingsPage: Loaded ${memberDetails.length} member details',
      );
      setState(() {
        _memberDetails = memberDetails;
        _isLoadingMembers = false;
      });
    } catch (e) {
      print('GroupChatSettingsPage: Error in _loadMemberDetails: $e');
      setState(() {
        _isLoadingMembers = false;
      });
    }
  }

  bool get _isCurrentUserAdmin {
    return widget.chatThread.isUserAdmin(_currentUserId);
  }

  Future<void> _updateGroupName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty || newName == widget.chatThread.name) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      await _manageGroupChatUseCase.updateGroupName(
        chatThreadId: widget.chatThread.id,
        newName: newName,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã cập nhật tên nhóm')));

      widget.onUpdate?.call();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  Future<void> _updateGroupDescription() async {
    final newDescription = _descriptionController.text.trim();
    if (newDescription == (widget.chatThread.groupDescription ?? '')) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      await _manageGroupChatUseCase.updateGroupDescription(
        chatThreadId: widget.chatThread.id,
        newDescription: newDescription,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã cập nhật mô tả nhóm')));

      widget.onUpdate?.call();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  Future<void> _removeMember(String memberId, String memberName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: Text('Bạn có chắc muốn xóa "$memberName" khỏi nhóm?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      await _manageGroupChatUseCase.removeMember(
        chatThreadId: widget.chatThread.id,
        memberId: memberId,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Đã xóa "$memberName" khỏi nhóm')));

      // Reload member details
      await _loadMemberDetails();
      widget.onUpdate?.call();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  Future<void> _pickAndUploadGroupImage() async {
    if (!_isCurrentUserAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chỉ admin mới có thể đổi ảnh nhóm')),
      );
      return;
    }

    try {
      // Show image source selection
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Chọn nguồn ảnh'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Bạn muốn chọn ảnh từ đâu?'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Thư viện'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
          ],
        ),
      );

      if (source == null) return;

      // Pick image
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      setState(() {
        _isUploadingImage = true;
      });

      // Upload to Cloudinary
      print(
        'GroupChatSettingsPage: Uploading group avatar for group: ${widget.chatThread.id}',
      );
      final cloudImageUrl = await ImageUploadService.uploadGroupAvatar(
        imagePath: pickedFile.path,
        groupId: widget.chatThread.id,
      );

      print(
        'GroupChatSettingsPage: Image uploaded successfully: $cloudImageUrl',
      );

      // Update group avatar in repository
      await _manageGroupChatUseCase.updateGroupAvatar(
        chatThreadId: widget.chatThread.id,
        newAvatarUrl: cloudImageUrl,
      );

      // Update local state
      setState(() {
        _currentGroupAvatarUrl = cloudImageUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật ảnh nhóm thành công!')),
      );

      // Notify parent to refresh
      widget.onUpdate?.call();
    } catch (e) {
      print('GroupChatSettingsPage: Error uploading group image: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  Future<void> _navigateToAddMembers() async {
    // Get updated chat thread info before navigating
    try {
      final repository = ChatThreadRepositoryImpl();
      final updatedChatThread = await repository.getChatThreadById(
        widget.chatThread.id,
      );

      if (updatedChatThread == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể tải thông tin nhóm')),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddMembersPage(
            chatThread: updatedChatThread,
            onMembersAdded: () {
              // Reload member details and notify parent
              _loadMemberDetails();
              widget.onUpdate?.call();
            },
          ),
        ),
      );
    } catch (e) {
      print('GroupChatSettingsPage: Error loading updated chat thread: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
    }
  }

  Future<void> _leaveGroup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rời nhóm'),
        content: const Text('Bạn có chắc muốn rời khỏi nhóm này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Rời nhóm', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      await _manageGroupChatUseCase.leaveGroup(
        chatThreadId: widget.chatThread.id,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã rời khỏi nhóm')));

      // Navigate back to chat list
      Navigator.popUntil(context, (route) => route.isFirst);
      widget.onUpdate?.call();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: 'Cài đặt nhóm',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: (_isUpdating || _isUploadingImage)
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    _isUploadingImage
                        ? 'Đang tải ảnh lên...'
                        : 'Đang cập nhật...',
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Group Avatar and Name
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            SmartAvatar(
                              imageUrl: _currentGroupAvatarUrl,
                              radius: 50,
                              fallbackText: widget.chatThread.name,
                              showBorder: true,
                              showShadow: true,
                            ),
                            if (_isCurrentUserAdmin)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: IconButton(
                                    onPressed: _pickAndUploadGroupImage,
                                    icon: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 36,
                                      minHeight: 36,
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_isCurrentUserAdmin)
                          ElevatedButton.icon(
                            onPressed: _pickAndUploadGroupImage,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Đổi ảnh nhóm'),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Group Name
                  Text(
                    'Tên nhóm',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      suffixIcon: _isCurrentUserAdmin
                          ? IconButton(
                              icon: const Icon(Icons.save),
                              onPressed: _updateGroupName,
                            )
                          : null,
                    ),
                    enabled: _isCurrentUserAdmin,
                    onSubmitted: _isCurrentUserAdmin
                        ? (_) => _updateGroupName()
                        : null,
                  ),

                  const SizedBox(height: 24),

                  // Group Description
                  Text(
                    'Mô tả nhóm',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: 'Nhập mô tả nhóm...',
                      suffixIcon: _isCurrentUserAdmin
                          ? IconButton(
                              icon: const Icon(Icons.save),
                              onPressed: _updateGroupDescription,
                            )
                          : null,
                    ),
                    enabled: _isCurrentUserAdmin,
                    maxLines: 3,
                    onSubmitted: _isCurrentUserAdmin
                        ? (_) => _updateGroupDescription()
                        : null,
                  ),

                  const SizedBox(height: 32),

                  // Members Section
                  Row(
                    children: [
                      Text(
                        'Thành viên (${widget.chatThread.members.length})',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      if (_isCurrentUserAdmin)
                        ElevatedButton.icon(
                          onPressed: _navigateToAddMembers,
                          icon: const Icon(Icons.person_add, size: 18),
                          label: const Text('Thêm'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Members List
                  RefreshIndicator(
                    onRefresh: _loadMemberDetails,
                    child: _isLoadingMembers
                        ? Container(
                            height: 200,
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text('Đang tải thông tin thành viên...'),
                                ],
                              ),
                            ),
                          )
                        : _memberDetails.isEmpty
                        ? Container(
                            height: 100,
                            child: const Center(
                              child: Text('Không thể tải thông tin thành viên'),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _memberDetails.length,
                            itemBuilder: (context, index) {
                              final member = _memberDetails[index];
                              final isAdmin =
                                  member['id'] ==
                                  widget.chatThread.groupAdminId;
                              final isCurrentUser =
                                  member['id'] == _currentUserId;

                              return Card(
                                child: ListTile(
                                  leading: SmartAvatar(
                                    imageUrl: member['avatarUrl'] ?? '',
                                    radius: 20,
                                    fallbackText: member['name'] ?? 'U',
                                    showBorder: true,
                                    showShadow: true,
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          member['name'] ?? 'Người dùng',
                                          style: TextStyle(
                                            fontWeight: isCurrentUser
                                                ? FontWeight.bold
                                                : null,
                                          ),
                                        ),
                                      ),
                                      if (isCurrentUser)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: const Text(
                                            'Bạn',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      if (isAdmin)
                                        Container(
                                          margin: EdgeInsets.only(
                                            left: isCurrentUser ? 4 : 0,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: const Text(
                                            'Admin',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  subtitle: member['email']?.isNotEmpty == true
                                      ? Text(member['email']!)
                                      : Text('ID: ${member['id']}'),
                                  trailing:
                                      _isCurrentUserAdmin &&
                                          !isAdmin &&
                                          !isCurrentUser
                                      ? IconButton(
                                          icon: const Icon(
                                            Icons.remove_circle_outline,
                                            color: Colors.red,
                                          ),
                                          onPressed: () => _removeMember(
                                            member['id']!,
                                            member['name'] ?? 'Người dùng',
                                          ),
                                          tooltip: 'Xóa khỏi nhóm',
                                        )
                                      : null,
                                ),
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons
                  if (!_isCurrentUserAdmin)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _leaveGroup,
                        icon: const Icon(Icons.exit_to_app, color: Colors.red),
                        label: const Text('Rời khỏi nhóm'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
