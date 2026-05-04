import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PointsController extends ChangeNotifier {
  static final PointsController instance = PointsController._internal();
  factory PointsController() => instance;

  PointsController._internal();

  int _currentPoints = 0;
  String? _currentUserId;
  bool _initialized = false;

  int get currentPoints => _currentPoints;
  bool get isInitialized => _initialized;

  String _getStorageKey(String? userId) => 'points_${userId ?? "guest"}';

  Future<void> initializeForUser(String? userId) async {
    _currentUserId = userId;
    final prefs = await SharedPreferences.getInstance();
    _currentPoints = prefs.getInt(_getStorageKey(userId)) ?? 0;
    _initialized = true;
    notifyListeners();
  }

  Future<void> addPoints(int points) async {
    _currentPoints += points;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_getStorageKey(_currentUserId), _currentPoints);
  }

  Future<void> deductPoints(int points) async {
    _currentPoints -= points;
    if (_currentPoints < 0) _currentPoints = 0;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_getStorageKey(_currentUserId), _currentPoints);
  }
}
