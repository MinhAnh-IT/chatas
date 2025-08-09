import 'package:chatas/core/constants/app_route_constants.dart';
import 'package:chatas/features/auth/presentation/pages/login_page.dart';
import 'package:chatas/features/auth/presentation/pages/register_page.dart';
import 'package:chatas/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:chatas/features/profile/presentation/pages/profile_page.dart';
import 'package:chatas/features/chat_message/presentation/pages/chat_message_page.dart';
import 'package:chatas/features/chat_message/presentation/cubit/chat_message_cubit.dart';
import 'package:chatas/features/chat_message/domain/usecases/send_message_usecase.dart';
import 'package:chatas/features/chat_message/domain/usecases/add_reaction_usecase.dart';
import 'package:chatas/features/chat_message/domain/usecases/remove_reaction_usecase.dart';
import 'package:chatas/features/chat_message/domain/usecases/edit_message_usecase.dart';
import 'package:chatas/features/chat_message/domain/usecases/delete_message_usecase.dart';
import 'package:chatas/features/chat_message/domain/usecases/get_messages_stream_usecase.dart';
import 'package:chatas/features/chat_message/domain/usecases/mark_messages_as_read_usecase.dart';
import 'package:chatas/features/chat_message/data/repositories/chat_message_repository_impl.dart';
import 'package:chatas/features/chat_thread/presentation/pages/chat_thread_list_page.dart';
import 'package:chatas/features/chat_thread/presentation/pages/archived_threads_page.dart';
import 'package:chatas/features/chat_thread/presentation/cubit/chat_thread_list_cubit.dart';
import 'package:chatas/features/chat_thread/domain/usecases/send_first_message_usecase.dart';
import 'package:chatas/features/chat_thread/domain/usecases/get_chat_threads_usecase.dart';
import 'package:chatas/features/chat_thread/domain/usecases/get_archived_threads_usecase.dart';
import 'package:chatas/features/chat_thread/domain/usecases/create_chat_thread_usecase.dart';
import 'package:chatas/features/chat_thread/domain/usecases/search_chat_threads_usecase.dart';
import 'package:chatas/features/chat_thread/domain/usecases/delete_chat_thread_usecase.dart';
import 'package:chatas/features/chat_thread/domain/usecases/hide_chat_thread_usecase.dart';
import 'package:chatas/features/chat_thread/domain/usecases/mark_thread_deleted_usecase.dart';
import 'package:chatas/features/chat_thread/domain/usecases/archive_thread_usecase.dart';
import 'package:chatas/features/chat_thread/domain/usecases/leave_group_usecase.dart';
import 'package:chatas/features/chat_thread/domain/usecases/join_group_usecase.dart';
import 'package:chatas/features/chat_thread/domain/usecases/find_or_create_chat_thread_usecase.dart';
import 'package:chatas/features/chat_thread/data/repositories/chat_thread_repository_impl.dart';
import 'package:chatas/features/friends/presentation/pages/friends_list_page.dart';
import 'package:chatas/features/friends/presentation/pages/friend_search_page.dart';
import 'package:chatas/features/friends/presentation/pages/friend_requests_page.dart';
import 'package:chatas/features/friends/injection/friends_injection.dart';
import 'package:chatas/features/friends/presentation/widgets/friends_with_chat_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final isLoggedIn = user != null;
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password';

      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      if (isLoggedIn && isAuthRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: AppRouteConstants.homePathName,
        builder: (context, state) => const ChatThreadListPage(),
      ),
      GoRoute(
        path: AppRouteConstants.loginPath,
        name: AppRouteConstants.loginPathName,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: AppRouteConstants.registerPathName,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: AppRouteConstants.forgotPasswordPathName,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/profile',
        name: AppRouteConstants.profilePathName,
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/archived',
        name: 'archived',
        builder: (context, state) {
          // Create repository and use cases for archived page
          final repository = ChatThreadRepositoryImpl();
          final getChatThreadsUseCase = GetChatThreadsUseCase(repository);
          final getArchivedThreadsUseCase = GetArchivedThreadsUseCase(repository);
          final createChatThreadUseCase = CreateChatThreadUseCase(repository);
          final searchChatThreadsUseCase = SearchChatThreadsUseCase(repository);
          final deleteChatThreadUseCase = DeleteChatThreadUseCase(repository);
          final hideChatThreadUseCase = HideChatThreadUseCase(repository);
          final markThreadDeletedUseCase = MarkThreadDeletedUseCase(repository);
          final archiveThreadUseCase = ArchiveThreadUseCase(repository);
          final leaveGroupUseCase = LeaveGroupUseCase(repository);
          final joinGroupUseCase = JoinGroupUseCase(repository);
          final findOrCreateChatThreadUseCase = FindOrCreateChatThreadUseCase(repository);

          return BlocProvider(
            create: (context) => ChatThreadListCubit(
              getChatThreadsUseCase: getChatThreadsUseCase,
              getArchivedThreadsUseCase: getArchivedThreadsUseCase,
              createChatThreadUseCase: createChatThreadUseCase,
              searchChatThreadsUseCase: searchChatThreadsUseCase,
              deleteChatThreadUseCase: deleteChatThreadUseCase,
              hideChatThreadUseCase: hideChatThreadUseCase,
              markThreadDeletedUseCase: markThreadDeletedUseCase,
              archiveThreadUseCase: archiveThreadUseCase,
              leaveGroupUseCase: leaveGroupUseCase,
              joinGroupUseCase: joinGroupUseCase,
              findOrCreateChatThreadUseCase: findOrCreateChatThreadUseCase,
            ),
            child: const ArchivedThreadsPage(),
          );
        },
      ),
      GoRoute(
        path: AppRouteConstants.friendsPath,
        name: AppRouteConstants.friendsPathName,
        builder: (context, state) {
          // Lấy currentUserId từ Firebase Auth
          final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

          return BlocProvider(
            create: (context) =>
                FriendsDependencyInjection.createFriendsListCubit(),
            child: FriendsWithChatProvider(
              currentUserId: currentUserId,
              child: FriendsListPage(currentUserId: currentUserId),
            ),
          );
        },
      ),
      GoRoute(
        path: AppRouteConstants.friendRequestsPath,
        name: AppRouteConstants.friendRequestsPathName,
        builder: (context, state) {
          // Lấy currentUserId từ Firebase Auth
          final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

          return BlocProvider(
            create: (context) =>
                FriendsDependencyInjection.createFriendRequestCubit(
                  currentUserId,
                ),
            child: const FriendRequestsPage(),
          );
        },
      ),
      GoRoute(
        path: AppRouteConstants.friendSearchPath,
        name: AppRouteConstants.friendSearchPathName,
        builder: (context, state) {
          // Lấy currentUserId từ Firebase Auth
          final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

          return BlocProvider(
            create: (context) =>
                FriendsDependencyInjection.createFriendSearchCubit(),
            child: FriendSearchPage(currentUserId: currentUserId),
          );
        },
      ),
      GoRoute(
        path: '${AppRouteConstants.chatMessagePath}/:threadId',
        name: AppRouteConstants.chatMessagePathName,
        builder: (context, state) {
          final threadId = state.pathParameters['threadId']!;
          final currentUserId =
              state.uri.queryParameters['currentUserId'] ?? '';
          final otherUserName =
              state.uri.queryParameters['otherUserName'] ?? '';

          // Setup repository and use cases for ChatMessage feature
          final repository = ChatMessageRepositoryImpl();
          final sendMessageUseCase = SendMessageUseCase(repository);
          final addReactionUseCase = AddReactionUseCase(repository);
          final removeReactionUseCase = RemoveReactionUseCase(
            repository: repository,
          );
          final editMessageUseCase = EditMessageUseCase(repository: repository);
          final deleteMessageUseCase = DeleteMessageUseCase(
            repository: repository,
          );
          final getMessagesStreamUseCase = GetMessagesStreamUseCase(
            repository: repository,
          );
          final markMessagesAsReadUseCase = MarkMessagesAsReadUseCase(
            repository,
          );

          // Setup ChatThread repository and use cases for first message creation
          final chatThreadRepository = ChatThreadRepositoryImpl();
          final sendFirstMessageUseCase = SendFirstMessageUseCase(
            chatThreadRepository: chatThreadRepository,
            chatMessageRepository: repository,
          );

          return BlocProvider(
            create: (context) => ChatMessageCubit(
              getMessagesStreamUseCase: getMessagesStreamUseCase,
              sendMessageUseCase: sendMessageUseCase,
              addReactionUseCase: addReactionUseCase,
              removeReactionUseCase: removeReactionUseCase,
              editMessageUseCase: editMessageUseCase,
              deleteMessageUseCase: deleteMessageUseCase,
              sendFirstMessageUseCase: sendFirstMessageUseCase,
              markMessagesAsReadUseCase: markMessagesAsReadUseCase,
            ),
            child: ChatMessagePage(
              threadId: threadId,
              currentUserId: currentUserId,
              otherUserName: otherUserName,
            ),
          );
        },
      ),
    ],
  );
}
