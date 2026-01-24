import 'package:flutter/foundation.dart';
import '../core/models/user_model.dart';
import '../core/models/achievement_model.dart';
import '../services/storage_service.dart';
import '../services/gamification_service.dart';

/// User data provider
class UserProvider with ChangeNotifier {
  final StorageService _storageService;
  final GamificationService _gamificationService = GamificationService();
  
  User? _user;
  List<Achievement> _unlockedAchievements = [];
  List<Achievement> _newlyUnlockedAchievements = [];

  UserProvider({
    required StorageService storageService,
  }) : _storageService = storageService;

  // Getters
  User? get user => _user;
  List<Achievement> get unlockedAchievements => _unlockedAchievements;
  List<Achievement> get newlyUnlockedAchievements => _newlyUnlockedAchievements;
  int get totalPoints => _user?.totalPoints ?? 0;
  int get solvedProblems => _user?.solvedProblems ?? 0;
  int get currentStreak => _user?.currentStreak ?? 0;

  /// Initialize user data
  void initializeUser(User user) {
    _user = user;
    _loadAchievements();
    notifyListeners();
  }

  /// Load unlocked achievements
  void _loadAchievements() {
    if (_user == null) return;
    
    _unlockedAchievements = _user!.achievementIds
        .map((id) => Achievements.getById(id))
        .whereType<Achievement>()
        .map((a) => a.unlock())
        .toList();
  }

  /// Add points to user
  Future<void> addPoints(int points) async {
    if (_user == null) return;

    _user = _gamificationService.processXP(_user!, points);
    _user = _user!.copyWith(
      totalPoints: _user!.totalPoints + points,
    );
    
    await _storageService.saveUser(_user!);
    _checkAchievements();
    notifyListeners();
  }

  /// Process challenge completion (points + tracking)
  Future<int> completeChallenge({
    required int basePoints,
    required int timeLimit,
    required int timeTaken,
    required String language,
    int attempts = 1,
    bool isFirstSolve = false,
  }) async {
    if (_user == null) return 0;

    // Calculate points
    final points = _gamificationService.calculatePoints(
      basePoints: basePoints,
      timeLimit: timeLimit,
      timeTaken: timeTaken,
      attempts: attempts,
      isFirstSolve: isFirstSolve,
    );

    // Update stats
    final languageStats = Map<String, int>.from(_user!.languageStats);
    languageStats[language] = (languageStats[language] ?? 0) + 1;

    _user = _gamificationService.processXP(_user!, points);
    _user = _user!.copyWith(
      totalPoints: _user!.totalPoints + points,
      solvedProblems: _user!.solvedProblems + 1,
      languageStats: languageStats,
    );

    await _storageService.saveUser(_user!);
    
    // Check achievements
    _checkAchievements();
    
    notifyListeners();
    return points;
  }

  /// Update streak
  Future<void> updateStreak() async {
    if (_user == null) return;

    _user = _gamificationService.updateStreak(_user!);
    
    await _storageService.saveUser(_user!);
    _checkAchievements();
    notifyListeners();
  }

  /// Check and unlock achievements
  void _checkAchievements() {
    if (_user == null) return;

    final newAchievements = _gamificationService.checkAchievements(
      _user!,
      Achievements.all,
    );

    if (newAchievements.isNotEmpty) {
      _unlockAchievements(newAchievements);
    }
  }

  /// Unlock achievements
  Future<void> _unlockAchievements(List<Achievement> achievements) async {
    if (_user == null) return;

    final newIds = achievements.map((a) => a.id).toList();
    final updatedAchievementIds = List<String>.from(_user!.achievementIds)
      ..addAll(newIds);

    _user = _user!.copyWith(achievementIds: updatedAchievementIds);
    await _storageService.saveUser(_user!);
    
    _newlyUnlockedAchievements = achievements;
    _loadAchievements();
  }
  
  /// Clear newly unlocked achievements after showing
  void clearNewAchievements() {
    _newlyUnlockedAchievements = [];
    notifyListeners();
  }

  /// Update profile
  Future<void> updateProfile({
    String? username,
    String? profileImageUrl,
  }) async {
    if (_user == null) return;

    _user = _user!.copyWith(
      username: username,
      profileImageUrl: profileImageUrl,
    );

    await _storageService.saveUser(_user!);
    notifyListeners();
  }

  /// Clear user data
  void clearUser() {
    _user = null;
    _unlockedAchievements = [];
    _newlyUnlockedAchievements = [];
    notifyListeners();
  }
}
