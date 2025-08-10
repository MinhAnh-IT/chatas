import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/auth_result.dart' as domain;
import '../../domain/entities/login_request.dart';
import '../../domain/entities/register_request.dart';
import '../../domain/entities/user.dart';
import '../../di/auth_dependency_injection.dart';
import '../../../../shared/services/online_status_service.dart';

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  final User? user;

  const AuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class PasswordResetEmailSent extends AuthState {
  const PasswordResetEmailSent();
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthInitial());

  Future<void> login(LoginRequest request) async {
    emit(const AuthLoading());
    try {
      final result = await AuthDependencyInjection.loginUseCase(request);
      if (result is domain.AuthSuccess) {
        emit(AuthSuccess(result.user));
      } else if (result is domain.AuthFailure) {
        emit(AuthFailure(result.message));
      }
    } catch (e) {
      emit(AuthFailure('Đăng nhập thất bại: ${e.toString()}'));
    }
  }

  Future<void> register(RegisterRequest request) async {
    emit(const AuthLoading());
    try {
      final result = await AuthDependencyInjection.registerUseCase(request);
      if (result is domain.AuthSuccess) {
        emit(AuthSuccess(result.user));
      } else if (result is domain.AuthFailure) {
        emit(AuthFailure(result.message));
      }
    } catch (e) {
      emit(AuthFailure('Đăng kí thất bại: ${e.toString()}'));
    }
  }

  Future<void> logout() async {
    emit(const AuthLoading());
    try {
      // Handle offline status before logout
      await OnlineStatusService.instance.handleLogout();

      final result = await AuthDependencyInjection.logoutUseCase();
      if (result is domain.AuthSuccess) {
        emit(const AuthSuccess(null));
      } else if (result is domain.AuthFailure) {
        emit(AuthFailure(result.message));
      }
    } catch (e) {
      emit(AuthFailure('Đăng xuất thất bại: ${e.toString()}'));
    }
  }

  Future<void> getCurrentUser() async {
    emit(const AuthLoading());
    try {
      final user = await AuthDependencyInjection.getCurrentUserUseCase();
      if (user != null) {
        emit(AuthSuccess(user));
      } else {
        emit(const AuthSuccess(null));
      }
    } catch (e) {
      emit(AuthFailure('Không thể lấy thông tin người dùng : ${e.toString()}'));
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    emit(const AuthLoading());
    try {
      await AuthDependencyInjection.authRemoteDataSource.sendPasswordResetEmail(
        email,
      );
      emit(const PasswordResetEmailSent());
    } on Exception catch (e) {
      emit(AuthFailure('Gửi email đặt lại mật khẩu thất bại: ${e.toString()}'));
    }
  }
}
