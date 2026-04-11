import 'package:graphics_project/domain/repositories/local_storage_repository.dart';

class GetLocalUsernameUseCase {
  final LocalStorageRepository repository;

  const GetLocalUsernameUseCase(this.repository);

  Future<String?> call() => repository.getUsername();
}
