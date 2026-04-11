/// Abstract contract for local device storage.
/// Keeps SharedPreferences out of the domain layer.
abstract class LocalStorageRepository {
  Future<void> saveUsername(String username);
  Future<String?> getUsername();
  Future<void> clear();
}
