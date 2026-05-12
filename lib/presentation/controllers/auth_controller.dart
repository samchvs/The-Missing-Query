import 'package:flutter/material.dart';
import 'package:graphics_project/data/datasources/supabase_auth_datasource.dart';
import 'package:graphics_project/data/repositories/auth_repository_impl.dart';
import 'package:graphics_project/data/datasources/shared_prefs_datasource.dart';
import 'package:graphics_project/data/repositories/local_storage_repository_impl.dart';
import 'package:graphics_project/data/models/character_model.dart';
import 'package:graphics_project/domain/entities/app_user.dart';
import 'package:graphics_project/domain/usecases/sign_in_usecase.dart';
import 'package:graphics_project/domain/usecases/sign_up_usecase.dart';
import 'package:graphics_project/domain/usecases/sign_out_usecase.dart';
import 'package:graphics_project/domain/usecases/get_current_user_usecase.dart';
import 'package:graphics_project/domain/usecases/save_local_username_usecase.dart';
import 'package:graphics_project/domain/usecases/get_local_username_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graphics_project/presentation/controllers/points_controller.dart';
import 'package:graphics_project/presentation/controllers/lives_controller.dart';
import 'package:graphics_project/presentation/controllers/leaderboard_controller.dart';

class AuthController extends ChangeNotifier {
  late final SignInUseCase _signIn;
  late final SignUpUseCase _signUp;
  late final SignOutUseCase _signOut;
  late final GetCurrentUserUseCase _getCurrentUser;
  late final SaveLocalUsernameUseCase _saveLocalUsername;
  late final GetLocalUsernameUseCase _getLocalUsername;
  late final AuthRepositoryImpl _authRepo;

  bool _isLoading = false;
  String? _errorMessage;
  String? _debugErrorMessage;
  AppUser? _currentUser;
  String? _localUsername;
  int _currentAvatarIndex = 0;

  final LeaderboardController leaderboard = LeaderboardController();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get debugErrorMessage => _debugErrorMessage;
  AppUser? get currentUser => _currentUser;
  String? get localUsername => _localUsername;

  bool get isAuthenticated => _currentUser != null;

  String get displayUsername =>
      _currentUser?.username ?? _localUsername ?? '';

  /// The avatar index (0–3) for the current user's character.
  int get currentAvatarIndex => _currentAvatarIndex;

  /// The asset path corresponding to the current avatar index.
  String get currentCharacterPath =>
      CharacterModel.all[_currentAvatarIndex.clamp(0, CharacterModel.all.length - 1)].path;

  AuthController._();

  static Future<AuthController> create() async {
    final controller = AuthController._();
    await controller._init();
    return controller;
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final prefsDataSource = SharedPrefsDataSource(prefs);
    final localRepo = LocalStorageRepositoryImpl(prefsDataSource);

    final supabaseDataSource = SupabaseAuthDataSource(Supabase.instance.client);
    _authRepo = AuthRepositoryImpl(supabaseDataSource);

    _signIn = SignInUseCase(_authRepo);
    _signUp = SignUpUseCase(_authRepo);
    _signOut = SignOutUseCase(_authRepo);
    _getCurrentUser = GetCurrentUserUseCase(_authRepo);
    _saveLocalUsername = SaveLocalUsernameUseCase(localRepo);
    _getLocalUsername = GetLocalUsernameUseCase(localRepo);

    // Restore session + local username
    _currentUser = _getCurrentUser();
    
    // If we have a session, fetch the latest remote profile to ensure we have the correct username
    if (_currentUser != null) {
      try {
        final latestUsername = await _authRepo.fetchUsername(_currentUser!.id);
        if (latestUsername != null && latestUsername.isNotEmpty) {
          _currentUser = AppUser(
            id: _currentUser!.id,
            email: _currentUser!.email,
            username: latestUsername,
          );
        }
      } catch (_) {}
    }
    
    _localUsername = await _getLocalUsername();

    if (_currentUser != null) {
      // If local storage is empty OR stale (different from remote), update it
      if (_localUsername == null || _localUsername != _currentUser!.username) {
        _localUsername = _currentUser!.username;
        await _saveLocalUsername(_localUsername!);
      }
    }

    // Load per-case points from Supabase and initialize controllers
    Map<String, int>? remoteCasePoints;
    int remoteTotal = 0;
    if (_currentUser != null) {
      remoteCasePoints = await _authRepo.getCasePoints(_currentUser!.id);
      remoteTotal = remoteCasePoints.values.fold(0, (s, v) => s + v);
    }

    // Register the Supabase sync callback in PointsController
    _registerPointsSyncCallback();

    await PointsController.instance.initializeForUser(
      _currentUser?.id,
      remoteCasePoints: remoteCasePoints,
    );
    await LivesController.instance.initializeForUser(_currentUser?.id);

    // Push existing total to leaderboard on startup
    if (_currentUser != null && remoteTotal > 0) {
      leaderboard.maybePushScore(
        userId: _currentUser?.id,
        username: displayUsername,
        score: remoteTotal,
      );
    }

    // Auto-sync leaderboard whenever points change
    PointsController.instance.addListener(() {
      if (_currentUser != null) {
        leaderboard.maybePushScore(
          userId: _currentUser?.id,
          username: displayUsername,
          score: PointsController.instance.totalPoints,
        );
      }
    });
  }

  /// Registers a callback so PointsController can sync per-case scores to Supabase.
  void _registerPointsSyncCallback() {
    PointsController.instance.setRemoteSyncCallback(
      _currentUser == null
          ? null
          : (caseId, points) async {
              try {
                await _authRepo.updateCasePoints(
                  userId: _currentUser!.id,
                  caseId: caseId,
                  points: points,
                );
              } catch (_) {
                // Never crash the game over a sync failure
              }
            },
    );
  }

  // ──────────────────────────────────────────────
  // Public API
  // ──────────────────────────────────────────────

  /// Registers a new Supabase user; also saves username locally.
  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      _currentUser = await _signUp(
        email: email,
        password: password,
        username: username,
      );
      _localUsername = username;
      await _saveLocalUsername(username);

      _registerPointsSyncCallback();
      await PointsController.instance.initializeForUser(_currentUser?.id);
      await LivesController.instance.initializeForUser(_currentUser?.id);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Signs in an existing Supabase user; saves their profile username locally.
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      _currentUser = await _signIn(email: email, password: password);
      _localUsername = _currentUser!.username;
      await _saveLocalUsername(_localUsername!);

      // Fetch per-case points from Supabase
      final remoteCasePoints = await _authRepo.getCasePoints(_currentUser!.id);
      final remoteTotal = remoteCasePoints.values.fold(0, (s, v) => s + v);

      _registerPointsSyncCallback();
      await PointsController.instance.initializeForUser(
        _currentUser?.id,
        remoteCasePoints: remoteCasePoints,
      );
      await LivesController.instance.initializeForUser(_currentUser?.id);

      if (remoteTotal > 0) {
        leaderboard.maybePushScore(
          userId: _currentUser?.id,
          username: displayUsername,
          score: remoteTotal,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Signs out of Supabase and clears local state.
  Future<void> signOut() async {
    _setLoading(true);
    _clearError();
    try {
      await _signOut();
      _currentUser = null;
      _currentAvatarIndex = 0;
      _localUsername = null;

      // Clear Supabase sync callback
      PointsController.instance.setRemoteSyncCallback(null);

      // Reset points and lives states
      await PointsController.instance.initializeForUser(null);
      await LivesController.instance.initializeForUser(null);

      notifyListeners();
    } catch (e) {
      _setError(e);
    } finally {
      _setLoading(false);
    }
  }

  /// Updates the username locally and, if logged in, also in Supabase profiles.
  Future<void> updateUsername(String username) async {
    _localUsername = username;
    await _saveLocalUsername(username);
    if (_currentUser != null) {
      try {
        await _authRepo.updateUsername(
          userId: _currentUser!.id,
          username: username,
        );
        _currentUser = AppUser(
          id: _currentUser!.id,
          email: _currentUser!.email,
          username: username,
        );
        
        // Force refresh the leaderboard so the new username shows up locally
        await leaderboard.forceRefresh();
      } catch (_) {
        // Silently fail the remote update — local is already saved
      }
    }
    notifyListeners();
  }

  void clearError() => _clearError();

  /// Updates the character selection in-memory (avatar index only — no longer persisted to DB).
  Future<void> updateCharacter(String characterPath) async {
    final index = CharacterModel.all.indexWhere((c) => c.path == characterPath);
    _currentAvatarIndex = index < 0 ? 0 : index;
    notifyListeners();
  }

  // ──────────────────────────────────────────────
  // Private helpers
  // ──────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(Object e) {
    _errorMessage = _parseError(e);
    _debugErrorMessage = e.toString();
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    _debugErrorMessage = null;
    notifyListeners();
  }

  /// Converts a thrown exception into a displayable error string.
  String _parseError(Object e) {
    final msg = e.toString().toLowerCase();

    if (msg.contains('already registered') ||
        msg.contains('user_already_exists') ||
        msg.contains('duplicate key')) {
      return 'That email is already registered.';
    }

    if (e is AuthException) {
      if (e.message.toLowerCase().contains('invalid login credentials')) {
        return 'Incorrect email or password.';
      }

      final code = e.statusCode;
      if (code == '400' || code == '422') {
        return 'Invalid email or password format.';
      }
      if (code == '401') return 'Incorrect email or password.';
      if (code == '429') return 'Too many attempts. Please wait a moment.';

      return e.message;
    }

    if (msg.contains('network') || msg.contains('socketexception')) {
      return 'No internet connection. Please check your network.';
    }

    return 'Something went wrong. Please try again.';}
}
