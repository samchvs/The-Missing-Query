import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PointsController extends ChangeNotifier {
  static final PointsController instance = PointsController._internal();
  factory PointsController() => instance;

  PointsController._internal();

  final Map<String, int> _casePoints = {};
  String _activeCaseId = 'case1';
  String? _currentUserId;
  bool _initialized = false;

  /// Callback set by AuthController to sync case points to Supabase.
  Future<void> Function(String caseId, int points)? _onCasePointsChanged;

  int get currentPoints => _casePoints[_activeCaseId] ?? 0;

  /// Total points across all cases — used as high_score in leaderboards.
  int get totalPoints => _casePoints.values.fold(0, (sum, p) => sum + p);

  bool get isInitialized => _initialized;
  String get activeCaseId => _activeCaseId;

  String _getStorageKey(String? userId, String caseId) =>
      'points_${userId ?? "default"}_$caseId';

  /// Sets the context for which case is currently being played.
  void setActiveCase(String caseId) {
    _activeCaseId = caseId;
    notifyListeners();
  }

  /// Register a callback that AuthController provides to sync to Supabase.
  void setRemoteSyncCallback(
      Future<void> Function(String caseId, int points)? callback) {
    _onCasePointsChanged = callback;
  }

  /// Loads points for all known cases from local storage, then syncs from
  /// Supabase remote values if they are higher.
  Future<void> initializeForUser(
    String? userId, {
    Map<String, int>? remoteCasePoints,
  }) async {
    _currentUserId = userId;

    if (userId == null) {
      _casePoints.clear();
      _initialized = true;
      notifyListeners();
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    // Load local points for all 3 cases
    const cases = ['case1', 'case2', 'case3'];
    for (final c in cases) {
      _casePoints[c] = prefs.getInt(_getStorageKey(userId, c)) ?? 0;
    }

    // Sync from remote: if Supabase has higher values, use them
    if (remoteCasePoints != null) {
      for (final c in cases) {
        final remote = remoteCasePoints[c] ?? 0;
        if (remote > (_casePoints[c] ?? 0)) {
          _casePoints[c] = remote;
          await prefs.setInt(_getStorageKey(userId, c), remote);
        }
      }
    }

    // Legacy migration: if case1 is still 0, check old global key
    if (_casePoints['case1'] == 0) {
      final legacyKey = 'points_$userId';
      final legacyPoints = prefs.getInt(legacyKey) ?? 0;
      if (legacyPoints > 0) {
        _casePoints['case1'] = legacyPoints;
        await prefs.setInt(_getStorageKey(userId, 'case1'), legacyPoints);
      }
    }

    _initialized = true;
    notifyListeners();
  }

  /// Adds points to the currently active case and syncs to Supabase.
  Future<void> addPoints(int points) async {
    final current = _casePoints[_activeCaseId] ?? 0;
    _casePoints[_activeCaseId] = current + points;

    notifyListeners();

    // Persist locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _getStorageKey(_currentUserId, _activeCaseId),
      _casePoints[_activeCaseId]!,
    );

    // Sync to Supabase via the callback
    if (_onCasePointsChanged != null) {
      await _onCasePointsChanged!(_activeCaseId, _casePoints[_activeCaseId]!);
    }
  }

  /// Returns points for a specific case.
  int getPointsForCase(String caseId) => _casePoints[caseId] ?? 0;
}
