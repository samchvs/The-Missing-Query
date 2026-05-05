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

  /// Visual points for the currently active case.
  int get currentPoints => _casePoints[_activeCaseId] ?? 0;
  
  /// Internal total points across all cases (for DB syncing).
  int get totalPoints => _casePoints.values.fold(0, (sum, p) => sum + p);
  
  bool get isInitialized => _initialized;
  String get activeCaseId => _activeCaseId;

  String _getStorageKey(String? userId, String caseId) => 
      'points_${userId ?? "guest"}_$caseId';

  /// Sets the context for which case is currently being played.
  void setActiveCase(String caseId) {
    _activeCaseId = caseId;
    notifyListeners();
  }

  /// Loads points for all known cases from local storage.
  Future<void> initializeForUser(String? userId) async {
    _currentUserId = userId;
    final prefs = await SharedPreferences.getInstance();
    
    // Initialize points for all 3 planned cases
    const cases = ['case1', 'case2', 'case3'];
    for (final c in cases) {
      _casePoints[c] = prefs.getInt(_getStorageKey(userId, c)) ?? 0;
    }

    // --- MIGRATION ---
    // If Case 1 points are 0, check if points exist in the old legacy global key
    if (_casePoints['case1'] == 0) {
      final legacyKey = 'points_${userId ?? "guest"}';
      final legacyPoints = prefs.getInt(legacyKey) ?? 0;
      if (legacyPoints > 0) {
        _casePoints['case1'] = legacyPoints;
        // Persist to the new case-specific key
        await prefs.setInt(_getStorageKey(userId, 'case1'), legacyPoints);
      }
    }
    
    _initialized = true;
    notifyListeners();
  }

  /// Adds points to the currently active case.
  Future<void> addPoints(int points) async {
    final current = _casePoints[_activeCaseId] ?? 0;
    _casePoints[_activeCaseId] = current + points;
    
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _getStorageKey(_currentUserId, _activeCaseId), 
      _casePoints[_activeCaseId]!,
    );
  }

  /// Deducts points from the currently active case.
  Future<void> deductPoints(int points) async {
    final current = _casePoints[_activeCaseId] ?? 0;
    int newValue = current - points;
    if (newValue < 0) newValue = 0;
    
    _casePoints[_activeCaseId] = newValue;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _getStorageKey(_currentUserId, _activeCaseId), 
      newValue,
    );
  }

  /// Returns points for a specific case (useful for unlock checks).
  int getPointsForCase(String caseId) => _casePoints[caseId] ?? 0;
}
