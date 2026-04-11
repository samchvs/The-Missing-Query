import 'package:graphics_project/domain/entities/app_user.dart';
import 'package:graphics_project/domain/repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  const SignUpUseCase(this.repository);

  Future<AppUser> call({
    required String email,
    required String password,
    required String username,
  }) {
    return repository.signUp(
      email: email,
      password: password,
      username: username,
    );
  }
}
