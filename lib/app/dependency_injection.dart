import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/dio_client.dart';
import '../data/services/auth_service.dart';
import '../data/services/dua_service.dart';
import '../data/services/poem_service.dart';
import '../data/services/category_service.dart';
import '../data/services/tag_service.dart';
import '../data/services/user_service.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/dua_repository.dart';
import '../data/repositories/poem_repository.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/tag_repository.dart';
import '../presentation/blocs/auth_bloc/auth_bloc.dart';
import '../presentation/blocs/home_bloc/home_bloc.dart';
import '../presentation/blocs/dua_bloc/dua_bloc.dart';
import '../presentation/blocs/poem_bloc/poem_bloc.dart';
import '../presentation/blocs/category_bloc/category_bloc.dart';
import '../presentation/blocs/tag_bloc/tag_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  final secureStorage = const FlutterSecureStorage();
  final dio = Dio();

  // Core
  getIt.registerLazySingleton<SharedPreferences>(() => prefs);
  getIt.registerLazySingleton(() => DioClient(dio, secureStorage));

  // Services
  getIt.registerLazySingleton(() => AuthService(getIt<DioClient>()));
  getIt.registerLazySingleton(() => DuaService(getIt<DioClient>()));
  getIt.registerLazySingleton(() => PoemService(getIt<DioClient>()));
  getIt.registerLazySingleton(() => CategoryService(getIt<DioClient>()));
  getIt.registerLazySingleton(() => TagService(getIt<DioClient>()));
  getIt.registerLazySingleton(() => UserService(getIt<DioClient>()));

  // Repositories
  getIt.registerLazySingleton(() => AuthRepository(getIt<AuthService>(), secureStorage));
  getIt.registerLazySingleton(() => DuaRepository(getIt<DuaService>()));
  getIt.registerLazySingleton(() => PoemRepository(getIt<PoemService>()));
  getIt.registerLazySingleton(() => CategoryRepository(getIt<CategoryService>()));
  getIt.registerLazySingleton(() => TagRepository(getIt<TagService>()));

  // BLoCs
  getIt.registerFactory(() => AuthBloc(getIt<AuthRepository>(), getIt<UserService>()));
  getIt.registerFactory(() => HomeBloc(getIt<DuaRepository>(), getIt<PoemRepository>()));
  getIt.registerLazySingleton(() => DuaBloc(getIt<DuaRepository>()));
  getIt.registerLazySingleton(() => PoemBloc(getIt<PoemRepository>()));
  getIt.registerFactory(() => CategoryBloc(getIt<CategoryRepository>()));
  getIt.registerFactory(() => TagBloc(getIt<TagRepository>()));
}
