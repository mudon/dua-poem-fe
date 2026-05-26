import '../../core/network/api_result.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/interfaces/i_auth_repository.dart';

class LoginUseCase {
  final IAuthRepository repository;

  LoginUseCase(this.repository);

  Future<ApiResult<UserModel>> call(String email, String password) {
    return repository.login(email, password);
  }
}
