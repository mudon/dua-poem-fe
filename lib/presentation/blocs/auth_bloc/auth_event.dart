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
  UpdateProfileRequested(this.firstName, this.lastName, {this.bio});
}

class ClearAuthError extends AuthEvent {}
