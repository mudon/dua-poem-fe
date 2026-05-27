import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/user_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepo;

  AuthBloc(this._authRepo) : super(AuthInitial()) {
    on<LoginRequested>(_onLogin);
    on<SignupRequested>(_onSignup);
    on<LogoutRequested>(_onLogout);
    on<CheckAuthStatus>(_onCheck);
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _authRepo.login(event.email, event.password);
    if (result.isSuccess) {
      await _saveUser(result.data!);
      emit(Authenticated(result.data!));
    } else {
      emit(AuthError(result.error!));
    }
  }

  Future<void> _onSignup(SignupRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _authRepo.signup(event.name, event.email, event.password);
    if (result.isSuccess) {
      await _saveUser(result.data!);
      emit(Authenticated(result.data!));
    } else {
      emit(AuthError(result.error!));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await _authRepo.logout();
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'cached_user');
    emit(Unauthenticated());
  }

  Future<void> _onCheck(CheckAuthStatus event, Emitter<AuthState> emit) async {
    final isLogged = await _authRepo.isLoggedIn();
    if (isLogged) {
      const storage = FlutterSecureStorage();
      final cachedUser = await storage.read(key: 'cached_user');
      if (cachedUser != null) {
        final user = UserModel.fromJson(jsonDecode(cachedUser));
        emit(Authenticated(user));
      } else {
        emit(Authenticated(UserModel(
          id: '',
          name: '',
          email: '',
          createdAt: DateTime.now(),
        )));
      }
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _saveUser(UserModel user) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: 'cached_user', value: jsonEncode({
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'role': user.role,
      'createdAt': user.createdAt.toIso8601String(),
      'avatar': user.avatar,
      'bio': user.bio,
      'joinedDate': user.joinedDate,
    }));
  }
}
