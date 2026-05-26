import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/services/auth_service.dart';
import '../data/services/dua_service.dart';
import '../data/services/poem_service.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/dua_repository.dart';
import '../data/repositories/poem_repository.dart';
import '../presentation/blocs/auth_bloc/auth_bloc.dart';
import '../presentation/blocs/home_bloc/home_bloc.dart';
import '../presentation/blocs/dua_bloc/dua_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  final prefs = await SharedPreferences.getInstance();

  // Services
  getIt.registerLazySingleton(() => AuthService());
  getIt.registerLazySingleton(() => DuaService());
  getIt.registerLazySingleton(() => PoemService());

  // Repositories
  getIt.registerLazySingleton(() => AuthRepository(getIt<AuthService>(), prefs));
  getIt.registerLazySingleton(() => DuaRepository(getIt<DuaService>()));
  getIt.registerLazySingleton(() => PoemRepository(getIt<PoemService>()));

  // BLoCs
  getIt.registerFactory(() => AuthBloc(getIt<AuthRepository>()));
  getIt.registerFactory(() => HomeBloc(getIt<DuaRepository>(), getIt<PoemRepository>()));
  getIt.registerFactory(() => DuaBloc(getIt<DuaRepository>()));
}
