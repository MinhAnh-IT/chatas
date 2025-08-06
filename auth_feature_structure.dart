features/
└── auth/
    ├── data/
    │   ├── datasources/
    │   │   └── auth_remote_datasource.dart => tương tác với Firebase
    │   ├── models/
    │   │   └── user_model.dart => chuyển đổi dữ liệu từ Firebase (json -> model, model -> json)
    │   └── repositories/
    │       └── auth_repository_impl.dart => triển khai logic của AuthRepository
    │
    ├── domain/
    │   ├── entities/
    │   │   └── user.dart => định nghĩa nhưng entity liên quan đến feature auth
    │   ├── repositories/
    │   │   └── auth_repository.dart => định nghĩa interface của AuthRepository
    │   └── usecases/
    │       ├── login_with_email.dart  => đảm nhiệm 1 chức năng
    │       └── register_with_email.dart => tương tự
    │
    └── presentation/
        ├── cubit/
        │   └── login_cubit.dart => quản lý trạng thái của việc đăng nhập
        ├── pages/
        │   └── login_page.dart => giao diện đăng nhập
        └── widgets/
            └── email_input.dart => widget nhập email (chỉ sử dụng chung trong feature auth)

// ----------------------------
// 📁 user.dart (entity)
class User {
  final String id;
  final String email;

  User({required this.id, required this.email});
}

// 📁 user_model.dart
import '../../domain/entities/user.dart';

class UserModel {
  final String id;
  final String email;

  UserModel({required this.id, required this.email});

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      UserModel(id: json['id'], email: json['email']);

  Map<String, dynamic> toJson() => {'id': id, 'email': email};

  User toEntity() => User(id: id, email: email);
}

// 📁 auth_remote_datasource.dart
import '../models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class AuthRemoteDataSource {
  Future<UserModel> loginWithEmail(String email, String password) async {
    final res = await fb.FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email, password: password,
    );
    return UserModel(id: res.user!.uid, email: res.user!.email ?? '');
  }
}

// 📁 auth_repository.dart
import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> loginWithEmail(String email, String password);
}

// 📁 auth_repository_impl.dart
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;

  AuthRepositoryImpl(this.remote);

  @override
  Future<User> loginWithEmail(String email, String password) async {
    final model = await remote.loginWithEmail(email, password);
    return model.toEntity();
  }
}

// 📁 login_with_email.dart
import '../repositories/auth_repository.dart';
import '../entities/user.dart';

class LoginWithEmail {
  final AuthRepository repository;

  LoginWithEmail(this.repository);

  Future<User> call(String email, String password) {
    return repository.loginWithEmail(email, password);
  }
}

// 📁 login_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/login_with_email.dart';
import '../../../domain/entities/user.dart';

class LoginState {
  final bool loading;
  final User? user;
  final String? error;

  LoginState({this.loading = false, this.user, this.error});
}

class LoginCubit extends Cubit<LoginState> {
  final LoginWithEmail usecase;

  LoginCubit(this.usecase) : super(LoginState());

  Future<void> login(String email, String password) async {
    emit(LoginState(loading: true));
    try {
      final user = await usecase(email, password);
      emit(LoginState(user: user));
    } catch (e) {
      emit(LoginState(error: e.toString()));
    }
  }
}

// 📁 login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/login_cubit.dart';

class LoginPage extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LoginCubit>();

    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: BlocBuilder<LoginCubit, LoginState>(
        builder: (context, state) {
          return Column(
            children: [
              TextField(controller: emailController),
              TextField(controller: passwordController, obscureText: true),
              if (state.loading) CircularProgressIndicator(),
              if (state.error != null) Text(state.error!, style: TextStyle(color: Colors.red)),
              ElevatedButton(
                onPressed: () => cubit.login(
                  emailController.text.trim(),
                  passwordController.text.trim(),
                ),
                child: Text("Login"),
              ),
            ],
          );
        },
      ),
    );
  }
}

// 📁 email_input.dart (demo widget)
import 'package:flutter/material.dart';

class EmailInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  EmailInput({required this.controller, this.hintText = 'Email'});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: hintText),
    );
  }
}
