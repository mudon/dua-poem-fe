import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/dependency_injection.dart';
import '../../../core/constants/auth_error_codes.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/errors/error_helper.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/user_service.dart';
import '../../../data/services/signalr_service.dart';
import '../../../data/models/user_model.dart';
import '../../blocs/dua_bloc/dua_event.dart' as dua_event;
import '../../blocs/poem_bloc/poem_event.dart' as poem_event;
import '../../blocs/dua_bloc/dua_bloc.dart';
import '../../blocs/poem_bloc/poem_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepo;
  final UserService _userService;
  final SignalRService _signalRService;

  AuthBloc(this._authRepo, this._userService, this._signalRService) : super(AuthInitial()) {
    on<LoginRequested>(_onLogin);
    on<SignupRequested>(_onSignup);
    on<VerifyEmailRequested>(_onVerifyEmail);
    on<ResendOtpRequested>(_onResendOtp);
    on<ReturnToAuth>(_onReturnToAuth);
    on<ShowForgotPassword>(_onShowForgotPassword);
    on<ForgotPasswordRequested>(_onForgotPassword);
    on<ResetPasswordSubmitted>(_onResetPassword);
    on<CancelForgotPassword>(_onCancelForgotPassword);
    on<LogoutRequested>(_onLogout);
    on<CheckAuthStatus>(_onCheck);
    on<UpdateProfileRequested>(_onUpdateProfile);
    on<ClearAuthError>(_onClearError);
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _authRepo.login(event.email, event.password);
    if (result.isSuccess) {
      await _saveUser(result.data!);
      await _signalRService.connect();
      emit(Authenticated(result.data!));
    } else if (result.code == AuthErrorCodes.emailNotVerified) {
      emit(EmailNotVerified(event.email));
    } else {
      emit(AuthError(result.error!));
    }
  }

  Future<void> _onSignup(SignupRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _authRepo.signup(event.firstName, event.lastName, event.email, event.password);
    if (result.isSuccess) {
      emit(EmailNotVerified(result.data!));
    } else {
      emit(AuthError(result.error!));
    }
  }

  Future<void> _onVerifyEmail(VerifyEmailRequested event, Emitter<AuthState> emit) async {
    emit(EmailNotVerified(event.email, isLoading: true));
    final result = await _authRepo.verifyEmail(event.email, event.code);
    if (result.isSuccess) {
      await _saveUser(result.data!);
      await _signalRService.connect();
      emit(Authenticated(result.data!));
    } else {
      emit(EmailNotVerified(event.email, error: result.error));
    }
  }

  Future<void> _onResendOtp(ResendOtpRequested event, Emitter<AuthState> emit) async {
    emit(EmailNotVerified(event.email, isLoading: true));
    final result = await _authRepo.resendOtp(event.email);
    if (result.isSuccess) {
      emit(EmailNotVerified(event.email));
    } else {
      emit(EmailNotVerified(event.email, error: result.error));
    }
  }

  void _onReturnToAuth(ReturnToAuth event, Emitter<AuthState> emit) {
    emit(Unauthenticated());
  }

  void _onShowForgotPassword(ShowForgotPassword event, Emitter<AuthState> emit) {
    emit(ForgotPasswordMode());
  }

  Future<void> _onForgotPassword(ForgotPasswordRequested event, Emitter<AuthState> emit) async {
    emit(ForgotPasswordMode(email: event.email, isLoading: true));
    final result = await _authRepo.forgotPassword(event.email);
    if (result.isSuccess) {
      emit(ForgotPasswordMode(email: event.email, step: ForgotPasswordStep.reset));
    } else {
      emit(ForgotPasswordMode(email: event.email, step: ForgotPasswordStep.email, error: result.error));
    }
  }

  Future<void> _onResetPassword(ResetPasswordSubmitted event, Emitter<AuthState> emit) async {
    emit(ForgotPasswordMode(email: event.email, step: ForgotPasswordStep.reset, isLoading: true));
    final result = await _authRepo.resetPassword(event.email, event.code, event.newPassword);
    if (result.isSuccess) {
      emit(PasswordResetSuccess());
    } else {
      emit(ForgotPasswordMode(email: event.email, step: ForgotPasswordStep.reset, error: result.error));
    }
  }

  void _onCancelForgotPassword(CancelForgotPassword event, Emitter<AuthState> emit) {
    emit(Unauthenticated());
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await _signalRService.disconnect();
    getIt<DuaBloc>().add(dua_event.ClearReturnedReports());
    getIt<PoemBloc>().add(poem_event.ClearReturnedReports());
    await _authRepo.logout();
    const storage = FlutterSecureStorage();
    await storage.delete(key: StorageKeys.cachedUser);
    emit(Unauthenticated());
  }

  Future<void> _onCheck(CheckAuthStatus event, Emitter<AuthState> emit) async {
    final isLogged = await _authRepo.isLoggedIn();
    if (isLogged) {
      try {
        await _signalRService.connect();
      } catch (_) {
        // SignalR connection failure is non-fatal; API calls still work via token refresh
      }
      const storage = FlutterSecureStorage();
      final cachedUser = await storage.read(key: StorageKeys.cachedUser);
      if (cachedUser != null) {
        final user = UserModel.fromJson(jsonDecode(cachedUser));
        emit(Authenticated(user));
      } else {
        emit(Authenticated(UserModel(
          id: '',
          firstName: '',
          lastName: '',
          email: '',
          createdAt: DateTime.now(),
        )));
      }
    } else {
      emit(Unauthenticated());
    }
  }

  void _onClearError(ClearAuthError event, Emitter<AuthState> emit) {
    if (state is AuthError) {
      emit(AuthInitial());
    }
  }

  Future<void> _onUpdateProfile(UpdateProfileRequested event, Emitter<AuthState> emit) async {
    final current = state;
    if (current is! Authenticated) return;

    try {
      final data = await _userService.updateProfile(
        firstName: event.firstName,
        lastName: event.lastName,
        bio: event.bio,
        avatarType: event.avatarType?.value,
        avatarValue: event.avatarValue,
        selectedBadgeSlug: event.selectedBadgeSlug,
      );
      final user = UserModel.fromJson(data);
      await _saveUser(user);
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e is DioException ? e.userMessage : 'Failed to update profile'));
    }
  }

  Future<void> _saveUser(UserModel user) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: StorageKeys.cachedUser, value: jsonEncode({
      'id': user.id,
      'firstName': user.firstName,
      'lastName': user.lastName,
      'email': user.email,
      'role': user.role.name,
      'createdAt': user.createdAt.toIso8601String(),
      'avatar': user.avatar,
      'bio': user.bio,
      'avatarType': user.avatarType?.value,
      'avatarValue': user.avatarValue,
      'selectedBadgeSlug': user.selectedBadgeSlug,
      'joinedDate': user.joinedDate,
    }));
  }
}
