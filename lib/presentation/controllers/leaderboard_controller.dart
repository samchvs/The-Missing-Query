import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:graphics_project/data/datasources/supabase_leaderboard_datasource.dart';
import 'package:graphics_project/data/repositories/leaderboard_repository_impl.dart';
import 'package:graphics_project/domain/entities/leaderboard_entry.dart';
import 'package:graphics_project/domain/usecases/fetch_leaderboard_usecase.dart';
import 'package:graphics_project/domain/usecases/push_leaderboard_score_usecase.dart';


class LeaderboardController extends ChangeNotifier {
  static const Duration _cacheTtl = Duration(minutes: 5);
  static const int _maxRows = 10;

  late final FetchLeaderboardUseCase _fetch;
  late final PushLeaderboardScoreUseCase _push;

  List<LeaderboardEntry> _cachedEntries = [];
  int _totalPlayers = 0;
  DateTime? _cacheExpiry;
  bool _isLoading = false;
  String? _error;

  List<LeaderboardEntry> get entries => List.unmodifiable(_cachedEntries);
  int get totalPlayers => _totalPlayers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasCachedData => _cachedEntries.isNotEmpty;

  LeaderboardController() {
    final client = Supabase.instance.client;
    final ds = SupabaseLeaderboardDataSource(client);
    final repo = LeaderboardRepositoryImpl(ds);
    _fetch = FetchLeaderboardUseCase(repo);
    _push = PushLeaderboardScoreUseCase(repo);
  }

  // ──────────────────────────────────────────────
  // Public API
  // ──────────────────────────────────────────────

  /// Returns the cached leaderboard or fetches a fresh one if the cache is stale.
  Future<void> fetchLeaderboard() async {
    if (_isCacheValid()) return;
    await _doFetch();
  }

  /// Always fetches a fresh leaderboard from Supabase, ignoring the cache.
  Future<void> forceRefresh() => _doFetch();

  /// Checks whether [score] qualifies for the top-10 using the cache, and if
  /// so, fires a push to Supabase and invalidates the cache.
  ///
  /// Does nothing for unauthenticated users ([userId] == null).
  Future<void> maybePushScore({
    required String? userId,
    required String username,
    required int score,
  }) async {
    if (userId == null || score <= 0) return;

    // ── Fast path: check cache before making any API call ──
    if (_isCacheValid() && _cachedEntries.length >= _maxRows) {
      // Does the user already have a row in the top-10?
      final existingEntry =
          _cachedEntries.where((e) => e.idFk == userId).firstOrNull;

      if (existingEntry != null) {
        // User is already on the board; only push if the new score is higher.
        if (score <= existingEntry.highScore) return;
      } else {
        // User is not on the board; only push if they beat the current lowest.
        final lowestScore = _cachedEntries.last.highScore;
        if (score <= lowestScore) return;
      }
    }

    // ── Slow path: push to Supabase ──
    try {
      await _push(userId: userId, username: username, score: score);
    } catch (e) {
      debugPrint('LeaderboardController.maybePushScore error: $e');
    }

    // Invalidate cache so the next fetch picks up the updated board.
    _invalidateCache();
  }

  // ──────────────────────────────────────────────
  // Private helpers
  // ──────────────────────────────────────────────

  bool _isCacheValid() {
    if (_cacheExpiry == null) return false;
    return DateTime.now().isBefore(_cacheExpiry!);
  }

  void _invalidateCache() {
    _cacheExpiry = null;
  }

  Future<void> _doFetch() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final (entries, count) = await _fetch();
      _cachedEntries = entries;
      _totalPlayers = count;
      _cacheExpiry = DateTime.now().add(_cacheTtl);
    } catch (e) {
      _error = 'Failed to load leaderboard.';
      debugPrint('LeaderboardController._doFetch error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
