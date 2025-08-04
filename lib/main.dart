import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/chat_thread/presentation/pages/chat_thread_list_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/di/auth_dependency_injection.dart';
import 'features/profile/di/profile_dependency_injection.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  setupProfileDependencies();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => BlocProvider(
              create: (_) => AuthCubit(),
              child: LoginPage(),
            ),
        '/register': (context) => BlocProvider(
              create: (_) => AuthCubit(),
              child: RegisterPage(),
            ),
        '/forgot-password': (context) => BlocProvider(
              create: (_) => AuthCubit(),
              child: ForgotPasswordPage(),
            ),
        '/profile': (context) => BlocProvider(
              create: (_) => ProfileCubit(
                getUserProfileUseCase: getIt(),
                updateProfileUseCase: getIt(),
                changePasswordUseCase: getIt(),
                uploadProfileImageUseCase: getIt(),
                checkUsernameAvailabilityUseCase: getIt(),
              ),
              child: const ProfilePage(),
            ),
            '/chatThreads': (context) => ChatThreadListPage(),
      },
    );
  }
}
