import 'package:flutter/foundation.dart';
import '../core/models/user_model.dart';
import '../core/models/achievement_model.dart';
import '../services/storage_service.dart';

/// User data provider
class UserProvider with ChangeNotifier {
  final StorageService _storageService;
  
  User? _user;
  List<Achievement> _unlockedAchievements = [];

  UserProvider({
    required StorageService storageService,
  }) : _storageService = storageService;

  // Getters
  User? get user => _user;
  List<Achievement> get unlockedAchievements => _unlockedAchievements;
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

  /// Update user points
  Future<void> addPoints(int points) async {
    if (_user == null) return;

    _user = _user!.copyWith(
      totalPoints: _user!.totalPoints + points,
    );
    
    await _storageService.saveUser(_user!);
    notifyListeners();
  }

  /// Increment solved problems
  Future<void> incrementSolved({required String language}) async {
    if (_user == null) return;

    final languageStats = Map<String, int>.from(_user!.languageStats);
    languageStats[language] = (languageStats[language] ?? 0) + 1;

    _user = _user!.copyWith(
      solvedProblems: _user!.solvedProblems + 1,
      languageStats: languageStats,
    );

    await _storageService.saveUser(_user!);
    _checkAchievements();
    notifyListeners();
  }

  /// Update streak
  Future<void> updateStreak() async {
    if (_user == null) return;

    final now = DateTime.now();
    final lastActive = _user!.lastActiveDate;
    final hoursSinceLastActive = now.difference(lastActive).inHours;

    int newStreak = _user!.currentStreak;
    
    if (hoursSinceLastActive < 24) {
      // Same day, no change
      return;
    } else if (hoursSinceLastActive < 48) {
      // Next day, increment streak
      newStreak++;
    } else {
      // Streak broken, reset
      newStreak = 1;
    }

    final newLongestStreak = newStreak > _user!.longestStreak
        ? newStreak
        : _user!.longestStreak;

    _user = _user!.copyWith(
      currentStreak: newStreak,
      longestStreak: newLongestStreak,
      lastActiveDate: now,
    );

    await _storageService.saveUser(_user!);
    _checkAchievements();
    notifyListeners();
  }

  /// Check and unlock achievements
  void _checkAchievements() {
    if (_user == null) return;

    final newAchievements = <String>[];

    // Check solved achievements
    if (_user!.solvedProblems >= 1 && !_hasAchievement('first_solve')) {
      newAchievements.add('first_solve');
    }
    if (_user!.solvedProblems >= 10 && !_hasAchievement('solved_10')) {
      newAchievements.add('solved_10');
    }
    if (_user!.solvedProblems >= 30 && !_hasAchievement('solved_30')) {
      newAchievements.add('solved_30');
    }
    if (_user!.solvedProblems >= 100 && !_hasAchievement('solved_100')) {
      newAchievements.add('solved_100');
    }

    // Check streak achievements
    if (_user!.currentStreak >= 3 && !_hasAchievement('streak_3')) {
      newAchievements.add('streak_3');
    }
    if (_user!.currentStreak >= 7 && !_hasAchievement('streak_7')) {
      newAchievements.add('streak_7');
    }
    if (_user!.currentStreak >= 30 && !_hasAchievement('streak_30')) {
      newAchievements.add('streak_30');
    }

    if (newAchievements.isNotEmpty) {
      _unlockAchievements(newAchievements);
    }
  }

  /// Unlock achievements
  Future<void> _unlockAchievements(List<String> achievementIds) async {
    if (_user == null) return;

    final updatedAchievementIds = List<String>.from(_user!.achievementIds)
      ..addAll(achievementIds);

    _user = _user!.copyWith(achievementIds: updatedAchievementIds);
    await _storageService.saveUser(_user!);
    _loadAchievements();
    
    // Could show notification here
    debugPrint('Unlocked achievements: $achievementIds');
  }

  /// Check if user has achievement
  bool _hasAchievement(String id) {
    return _user?.achievementIds.contains(id) ?? false;
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
    notifyListeners();
  }
}
