import 'package:chatas/core/constants/app_route_constants.dart';
import 'package:chatas/features/auth/presentation/pages/login_page.dart';
import 'package:chatas/features/auth/presentation/pages/register_page.dart';
import 'package:chatas/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:chatas/features/profile/presentation/pages/profile_page.dart';
import 'package:chatas/features/chat_thread/presentation/pages/chat_thread_list_page.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppRouter{
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final isLoggedIn = user != null;
      final isAuthRoute = state.matchedLocation == '/login' || 
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
        path: '/login',
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
    ]
  );
}
