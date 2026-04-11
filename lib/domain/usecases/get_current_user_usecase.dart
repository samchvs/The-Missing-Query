import 'package:graphics_project/domain/entities/app_user.dart';
import 'package:graphics_project/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  const GetCurrentUserUseCase(this.repository);

  AppUser? call() => repository.getCurrentUser();
}
