import 'package:graphics_project/data/datasources/shared_prefs_datasource.dart';
import 'package:graphics_project/domain/repositories/local_storage_repository.dart';

class LocalStorageRepositoryImpl implements LocalStorageRepository {
  final SharedPrefsDataSource _dataSource;

  LocalStorageRepositoryImpl(this._dataSource);

  @override
  Future<void> saveUsername(String username) =>
      _dataSource.saveUsername(username);

  @override
  Future<String?> getUsername() async => _dataSource.getUsername();

  @override
  Future<void> clear() => _dataSource.clear();
}
