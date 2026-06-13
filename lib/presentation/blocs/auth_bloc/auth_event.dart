import '../../../core/enums/avatar_type.dart';

abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email, password;
  LoginRequested(this.email, this.password);
}

class SignupRequested extends AuthEvent {
  final String firstName, lastName, email, password;
  SignupRequested(this.firstName, this.lastName, this.email, this.password);
}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

class UpdateProfileRequested extends AuthEvent {
  final String firstName;
  final String lastName;
  final String? bio;
  final AvatarType? avatarType;
  final String? avatarValue;
  final String? selectedBadgeSlug;
  UpdateProfileRequested(this.firstName, this.lastName, {this.bio, this.avatarType, this.avatarValue, this.selectedBadgeSlug});
}

class ClearAuthError extends AuthEvent {}

class VerifyEmailRequested extends AuthEvent {
  final String email, code;
  VerifyEmailRequested(this.email, this.code);
}

class ResendOtpRequested extends AuthEvent {
  final String email;
  ResendOtpRequested(this.email);
}

class ReturnToAuth extends AuthEvent {}

class ShowForgotPassword extends AuthEvent {}

class ForgotPasswordRequested extends AuthEvent {
  final String email;
  ForgotPasswordRequested(this.email);
}

class ResetPasswordSubmitted extends AuthEvent {
  final String email, code, newPassword;
  ResetPasswordSubmitted(this.email, this.code, this.newPassword);
}

class CancelForgotPassword extends AuthEvent {}
