import 'package:chatas/core/constants/app_route_constants.dart';
import 'package:chatas/features/auth/presentation/pages/login_page.dart';
import 'package:chatas/features/chat_message/presentation/pages/chat_message_page.dart';
import 'package:chatas/features/chat_message/presentation/cubit/chat_message_cubit.dart';
import 'package:chatas/features/chat_message/domain/usecases/send_message_usecase.dart';
import 'package:chatas/features/chat_message/domain/usecases/add_reaction_usecase.dart';
import 'package:chatas/features/chat_message/domain/usecases/remove_reaction_usecase.dart';
import 'package:chatas/features/chat_message/domain/usecases/get_messages_stream_usecase.dart';
import 'package:chatas/features/chat_message/data/repositories/chat_message_repository_impl.dart';
import 'package:chatas/features/chat_thread/presentation/pages/chat_thread_list_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
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
          final getMessagesStreamUseCase = GetMessagesStreamUseCase(repository);

          return BlocProvider(
            create: (context) => ChatMessageCubit(
              getMessagesStreamUseCase: getMessagesStreamUseCase,
              sendMessageUseCase: sendMessageUseCase,
              addReactionUseCase: addReactionUseCase,
              removeReactionUseCase: removeReactionUseCase,
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
