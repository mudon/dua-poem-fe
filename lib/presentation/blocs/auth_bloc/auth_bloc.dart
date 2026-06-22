import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/services/secure_storage_service.dart';
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
import '../../../data/services/fcm_service.dart';
import '../../../data/services/device_token_service.dart';
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
    on<GoogleLoginRequested>(_onGoogleLogin);
    on<SetPasswordRequested>(_onSetPassword);
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _authRepo.login(event.email, event.password);
    if (result.isSuccess) {
      await _saveUser(result.data!);
      await _signalRService.connect();
      await getIt<FcmService>().registerTokenWithBackend();
      emit(Authenticated(result.data!));
    } else if (result.code == AuthErrorCodes.emailNotVerified) {
      emit(EmailNotVerified(event.email));
    } else {
      emit(AuthError(result.error!, code: result.code));
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
      await getIt<FcmService>().registerTokenWithBackend();
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
    try {
      final token = await getIt<FcmService>().getToken();
      if (token != null) {
        await getIt<DeviceTokenService>().unregisterToken(token);
      }
    } catch (_) {}
    await _signalRService.disconnect();
    getIt<DuaBloc>().add(dua_event.ClearReturnedReports());
    getIt<PoemBloc>().add(poem_event.ClearReturnedReports());
    await _authRepo.logout();
    final storage = getIt<SecureStorageService>();
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
      try {
        await getIt<FcmService>().registerTokenWithBackend();
      } catch (_) {
        // FCM token registration is non-fatal
      }
      final storage = getIt<SecureStorageService>();
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

  Future<void> _onGoogleLogin(
      GoogleLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      String firebaseIdToken;

      if (kIsWeb) {
        final provider = fa.GoogleAuthProvider();
        final result = await fa.FirebaseAuth.instance.signInWithPopup(provider);
        firebaseIdToken = await result.user?.getIdToken() ?? '';
      } else {
        final googleSignIn = GoogleSignIn.instance;
        await googleSignIn.initialize();
        final account = await googleSignIn.authenticate();
        final idToken = account.authentication.idToken;
        if (idToken == null) {
          emit(const AuthError('No ID token received from Google'));
          return;
        }
        final credential = fa.GoogleAuthProvider.credential(idToken: idToken);
        await fa.FirebaseAuth.instance.signInWithCredential(credential);
        firebaseIdToken =
            await fa.FirebaseAuth.instance.currentUser?.getIdToken() ?? '';
      }

      if (firebaseIdToken.isEmpty) {
        emit(const AuthError('Failed to get Firebase token'));
        return;
      }

      final result = await _authRepo.googleLogin(firebaseIdToken);
      if (result.isSuccess) {
        await _saveUser(result.data!);
        await _signalRService.connect();
        await getIt<FcmService>().registerTokenWithBackend();
        emit(Authenticated(result.data!));
      } else {
        emit(AuthError(result.error!, code: result.code));
      }
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('canceled') || msg.contains('cancelled')) return;
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSetPassword(SetPasswordRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await _authRepo.setPassword(event.email, event.newPassword, event.idToken);
      if (result.isSuccess) {
        emit(PasswordSetSuccess());
      } else {
        emit(AuthError(result.error!));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
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
    final storage = getIt<SecureStorageService>();
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
      'selectedBadgeColor': user.selectedBadgeColor,
      'joinedDate': user.joinedDate,
    }));
  }
}
