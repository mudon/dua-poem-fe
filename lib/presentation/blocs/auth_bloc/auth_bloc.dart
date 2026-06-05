import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/dependency_injection.dart';
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
    on<LogoutRequested>(_onLogout);
    on<CheckAuthStatus>(_onCheck);
    on<UpdateProfileRequested>(_onUpdateProfile);
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _authRepo.login(event.email, event.password);
    if (result.isSuccess) {
      await _saveUser(result.data!);
      await _signalRService.connect();
      emit(Authenticated(result.data!));
    } else {
      emit(AuthError(result.error!));
    }
  }

  Future<void> _onSignup(SignupRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _authRepo.signup(event.firstName, event.lastName, event.email, event.password);
    if (result.isSuccess) {
      await _saveUser(result.data!);
      await _signalRService.connect();
      emit(Authenticated(result.data!));
    } else {
      emit(AuthError(result.error!));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await _signalRService.disconnect();
    getIt<DuaBloc>().add(dua_event.ClearReturnedReports());
    getIt<PoemBloc>().add(poem_event.ClearReturnedReports());
    await _authRepo.logout();
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'cached_user');
    emit(Unauthenticated());
  }

  Future<void> _onCheck(CheckAuthStatus event, Emitter<AuthState> emit) async {
    final isLogged = await _authRepo.isLoggedIn();
    if (isLogged) {
      await _signalRService.connect();
      const storage = FlutterSecureStorage();
      final cachedUser = await storage.read(key: 'cached_user');
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

  Future<void> _onUpdateProfile(UpdateProfileRequested event, Emitter<AuthState> emit) async {
    final current = state;
    if (current is! Authenticated) return;

    try {
      final data = await _userService.updateProfile(event.firstName, event.lastName, event.bio);
      final user = UserModel.fromJson(data);
      await _saveUser(user);
      emit(Authenticated(user));
    } catch (_) {
      emit(AuthError('Failed to update profile'));
    }
  }

  Future<void> _saveUser(UserModel user) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: 'cached_user', value: jsonEncode({
      'id': user.id,
      'firstName': user.firstName,
      'lastName': user.lastName,
      'email': user.email,
      'role': user.role,
      'createdAt': user.createdAt.toIso8601String(),
      'avatar': user.avatar,
      'bio': user.bio,
      'joinedDate': user.joinedDate,
    }));
  }
}
