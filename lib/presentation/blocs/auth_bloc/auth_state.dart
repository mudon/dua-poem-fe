import '../../../data/models/user_model.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserModel user;
  Authenticated(this.user);
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  final String? code;
  const AuthError(this.message, {this.code});
}

class EmailNotVerified extends AuthState {
  final String email;
  final String? error;
  final bool isLoading;
  EmailNotVerified(this.email, {this.error, this.isLoading = false});
}

class VerificationSuccess extends AuthState {}

class ForgotPasswordMode extends AuthState {
  final String email;
  final String? error;
  final bool isLoading;
  final ForgotPasswordStep step;
  ForgotPasswordMode({
    this.email = '',
    this.error,
    this.isLoading = false,
    this.step = ForgotPasswordStep.email,
  });
}

enum ForgotPasswordStep { email, reset }

class PasswordResetSuccess extends AuthState {}

class PasswordSetSuccess extends AuthState {}
