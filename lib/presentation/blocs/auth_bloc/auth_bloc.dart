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
      emit(Authenticated(result.data!));
    } else {
      emit(AuthError(result.error!));
    }
  }

  Future<void> _onSignup(SignupRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _authRepo.signup(event.name, event.email, event.password);
    if (result.isSuccess) {
      emit(Authenticated(result.data!));
    } else {
      emit(AuthError(result.error!));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await _authRepo.logout();
    emit(Unauthenticated());
  }

  Future<void> _onCheck(CheckAuthStatus event, Emitter<AuthState> emit) async {
    final isLogged = await _authRepo.isLoggedIn();
    if (isLogged) {
      emit(Authenticated(UserModel(id: 0, name: '', email: '', joinedDate: '')));
    } else {
      emit(Unauthenticated());
    }
  }
}
