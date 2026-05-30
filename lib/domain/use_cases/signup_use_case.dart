import '../../core/network/api_result.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/interfaces/i_auth_repository.dart';

class SignupUseCase {
  final IAuthRepository repository;

  SignupUseCase(this.repository);

  Future<ApiResult<UserModel>> call(String firstName, String lastName, String email, String password) {
    return repository.signup(firstName, lastName, email, password);
  }
}
