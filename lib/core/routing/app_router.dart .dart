import 'package:chatas/core/constants/app_route_constants.dart';
import 'package:chatas/features/auth/presentation/pages/login_page.dart';
import 'package:chatas/features/chat_thread/presentation/pages/chat_thread_list_page.dart';
import 'package:go_router/go_router.dart';

class AppRouter{
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
         path: '/',
         name: AppRouteConstants.homePathName,
         builder: (context, state) => const ChatThreadListPage(),
      ),
      GoRoute(
        path: '/login',
        name: AppRouteConstants.loginPathName,
        builder: (context, state) => const LoginPage(),
      ),
    ]
  );
}