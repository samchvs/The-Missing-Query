/// Local device storage.
abstract class LocalStorageRepository {
  Future<void> saveUsername(String username);
  Future<String?> getUsername();
  Future<void> clear();
}
