import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/chat_message_cubit.dart';
import '../cubit/chat_message_state.dart';
import 'offline_summary_widget.dart';
import '../../domain/entities/chat_message.dart';
import 'dart:async';
import 'package:chatas/shared/services/online_status_service.dart';

/// A stateful widget that manages the chat summary display
/// Uses BlocListener to properly listen to summary states
class ChatSummaryWidget extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onExpandToggle;

  const ChatSummaryWidget({
    super.key,
    required this.isExpanded,
    required this.onExpandToggle,
  });

  @override
  State<ChatSummaryWidget> createState() => _ChatSummaryWidgetState();
}

class _ChatSummaryWidgetState extends State<ChatSummaryWidget> {
  ChatMessageState? _currentSummaryState;

  Timer? _stateCheckTimer;

  @override
  void initState() {
    super.initState();
    // Init

    // Check initial state after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<ChatMessageCubit>();
      final currentState = cubit.state;

      if (currentState is ChatMessageSummaryLoading ||
          currentState is ChatMessageSummaryLoaded ||
          currentState is ChatMessageSummaryError) {
        setState(() {
          _currentSummaryState = currentState;
        });
      }

      // Backup mechanism: Poll cubit state periodically
      _stateCheckTimer = Timer.periodic(const Duration(milliseconds: 100), (
        timer,
      ) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        final cubit = context.read<ChatMessageCubit>();
        final currentState = cubit.state;

        if (currentState is ChatMessageSummaryLoading ||
            currentState is ChatMessageSummaryLoaded ||
            currentState is ChatMessageSummaryError) {
          // Check if we need to update our state
          if (_currentSummaryState?.runtimeType != currentState.runtimeType) {
            setState(() {
              _currentSummaryState = currentState;
            });
          } else if (currentState is ChatMessageSummaryLoaded &&
              _currentSummaryState is ChatMessageSummaryLoaded) {
            final current = _currentSummaryState as ChatMessageSummaryLoaded;
            if (current.summary != currentState.summary) {
              setState(() {
                _currentSummaryState = currentState;
              });
            }
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _stateCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatMessageCubit, ChatMessageState>(
      listenWhen: (previous, current) {
        return current is ChatMessageSummaryLoading ||
            current is ChatMessageSummaryLoaded ||
            current is ChatMessageSummaryError;
      },
      listener: (context, state) {
        if (state is ChatMessageSummaryLoading ||
            state is ChatMessageSummaryLoaded ||
            state is ChatMessageSummaryError) {
          if (mounted) {
            setState(() {
              _currentSummaryState = state;
            });
          } else {}
        } else {}
      },
      buildWhen: (previous, current) {
        return true; // Always rebuild to catch any state
      },
      builder: (context, state) {
        // Check if cubit has summary state but widget doesn't
        if ((state is ChatMessageSummaryLoading ||
                state is ChatMessageSummaryLoaded ||
                state is ChatMessageSummaryError) &&
            _currentSummaryState?.runtimeType != state.runtimeType) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _currentSummaryState = state;
              });
            }
          });
        }

        return _buildSummaryContent();
      },
    );
  }

  Widget _buildSummaryContent() {
    final state = _currentSummaryState;
    print(
      '🎨 [WIDGET DEBUG] Building content with state: ${state?.runtimeType}',
    );

    if (state is ChatMessageSummaryLoading) {
      print('⏳ [WIDGET DEBUG] Showing loading widget');
      return const OfflineSummaryLoadingWidget();
    }

    if (state is ChatMessageSummaryLoaded) {
      print(
        '✅ [WIDGET DEBUG] Showing summary: ${state.summary.substring(0, state.summary.length > 100 ? 100 : state.summary.length)}...',
      );
      return OfflineSummaryWidget(
        summary: state.summary,
        isExpanded: widget.isExpanded,
        onExpand: widget.onExpandToggle,
        onDismiss: () {
          OnlineStatusService.instance.onUserActivity();
          setState(() {
            _currentSummaryState = null;
          });
          context.read<ChatMessageCubit>().clearSummary();
        },
      );
    }

    if (state is ChatMessageSummaryError) {
      print('❌ [WIDGET DEBUG] Showing error: ${state.message}');
      return OfflineSummaryErrorWidget(
        error: state.message,
        onRetry: () {
          OnlineStatusService.instance.onUserActivity();
          final messageState = context.read<ChatMessageCubit>().state;
          if (messageState is ChatMessageLoaded) {
            _retrySummary(messageState.messages);
          }
        },
        onDismiss: () {
          OnlineStatusService.instance.onUserActivity();
          setState(() {
            _currentSummaryState = null;
          });
          context.read<ChatMessageCubit>().clearSummary();
        },
      );
    }

    print('🔍 [WIDGET DEBUG] No summary widget to show, returning empty');
    return const SizedBox.shrink();
  }

  /// Retries generating summary
  Future<void> _retrySummary(List<ChatMessage> messages) async {
    try {
      final cubit = context.read<ChatMessageCubit>();
      await cubit.manualSummarizeAllMessages(allMessages: messages);
    } catch (e) {
      print('❌ [WIDGET DEBUG] Error in retry: $e');
    }
  }
}
