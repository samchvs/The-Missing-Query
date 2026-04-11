import 'package:graphics_project/domain/repositories/local_storage_repository.dart';

class SaveLocalUsernameUseCase {
  final LocalStorageRepository repository;

  const SaveLocalUsernameUseCase(this.repository);

  Future<void> call(String username) => repository.saveUsername(username);
}
