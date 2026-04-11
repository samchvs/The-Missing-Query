import 'package:graphics_project/domain/entities/app_user.dart';
import 'package:graphics_project/domain/repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository repository;

  const SignInUseCase(this.repository);

  Future<AppUser> call({
    required String email,
    required String password,
  }) {
    return repository.signIn(email: email, password: password);
  }
}
