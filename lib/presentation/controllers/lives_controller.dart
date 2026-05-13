import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LivesController extends ChangeNotifier {
  static final LivesController instance = LivesController._internal();
  factory LivesController() => instance;

  LivesController._internal() {
    _startTicker();
  }

  static const int maxLives = 5;
  static const Duration refillDuration = Duration(minutes: 5);

  int _currentLives = maxLives;
  final List<DateTime> _pendingRefills = [];
  String? _currentUserId;

  Timer? _ticker;
  bool _initialized = false;

  int get currentLives => _currentLives;
  bool get isFull => _currentLives >= maxLives;

  // ================= INIT =================
  Future<void> initializeForUser(String? userId) async {
    _currentUserId = userId;
    
    // If no user is logged in, we reset the lives state
    if (userId == null) {
      _currentLives = maxLives;
      _pendingRefills.clear();
      _initialized = true;
      notifyListeners();
      return;
    }

    await _loadData();
    _initialized = true;
    notifyListeners();
  }

  // ================= STORAGE =================
  String _getLivesKey() => 'lives_${_currentUserId ?? "default"}';
  String _getRefillsKey() => 'refills_${_currentUserId ?? "default"}';

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setInt(_getLivesKey(), _currentLives);

    final timestamps = _pendingRefills
        .map((e) => e.millisecondsSinceEpoch)
        .toList();

    prefs.setString(_getRefillsKey(), jsonEncode(timestamps));
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    _currentLives = prefs.getInt(_getLivesKey()) ?? maxLives;

    final raw = prefs.getString(_getRefillsKey());

    _pendingRefills.clear();
    if (raw != null) {
      final List decoded = jsonDecode(raw);
      _pendingRefills.addAll(
        decoded.map((e) => DateTime.fromMillisecondsSinceEpoch(e)),
      );
    }

    _processRefills();
  }

  // ================= TIMER =================
  void _startTicker() {
    _ticker?.cancel();

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      _processRefills();
      notifyListeners();
    });
  }

  void _processRefills() {
    if (_pendingRefills.isEmpty) return;

    final now = DateTime.now();
    _pendingRefills.sort((a, b) => a.compareTo(b));

    bool changed = false;

    while (_pendingRefills.isNotEmpty &&
        !now.isBefore(_pendingRefills.first) &&
        _currentLives < maxLives) {
      _pendingRefills.removeAt(0);
      _currentLives++;
      changed = true;
    }

    if (_currentLives >= maxLives) {
      _currentLives = maxLives;
      _pendingRefills.clear();
      changed = true;
    }

    if (changed) {
      _saveData(); 
    }
  }

  // ================= GAME LOGIC =================
  bool deductLife() {
    /*
    _processRefills();

    if (_currentLives <= 0) return false;

    _currentLives--;

    _pendingRefills.add(DateTime.now().add(refillDuration));

    _saveData();
    notifyListeners();
    */

    return true;
  }

  // ================= TIMER DISPLAY =================
  Duration get timeUntilNextRefill {
    _processRefills();

    if (_pendingRefills.isEmpty || _currentLives >= maxLives) {
      return Duration.zero;
    }

    _pendingRefills.sort((a, b) => a.compareTo(b));

    final diff = _pendingRefills.first.difference(DateTime.now());

    if (diff.isNegative) return Duration.zero;
    return diff;
  }

  String get formattedCountdown {
    if (!_initialized) return '--:--';

    final duration = timeUntilNextRefill;

    if (_currentLives >= maxLives) return 'FULL';

    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    final hours = duration.inHours;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
    }

    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
