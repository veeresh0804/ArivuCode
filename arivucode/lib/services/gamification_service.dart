import 'package:uuid/uuid.dart';
import '../core/models/user_model.dart';
import '../core/models/achievement_model.dart';
import '../core/constants/app_constants.dart';

/// Service to handle gamification logic (points, streaks, achievements)
class GamificationService {
  
  /// Calculate points for a submission
  int calculatePoints({
    required int basePoints,
    required int timeLimit,
    required int timeTaken,
    required int attempts,
    bool isFirstSolve = false,
  }) {
    // Base points for the challenge
    double points = basePoints.toDouble();
    
    // Time bonus: up to 20% bonus for fast solutions
    // If taken < 50% of time limit, full 20% bonus
    // Linearly decreases to 0% at 100% of time limit
    if (timeTaken < timeLimit) {
      double timeRatio = timeTaken / timeLimit;
      if (timeRatio < 0.5) {
        points *= 1.2;
      } else {
        double bonus = 0.2 * (1.0 - timeRatio) * 2;
        points *= (1.0 + bonus);
      }
    }
    
    // Attempt penalty: -5% per failed attempt (max -50%)
    if (attempts > 1) {
      double penalty = (attempts - 1) * 0.05;
      if (penalty > 0.5) penalty = 0.5;
      points *= (1.0 - penalty);
    }
    
    // First solve bonus (mock)
    if (isFirstSolve) {
      points += 50;
    }
    
    return points.round();
  }

  /// Check and update streak
  /// Returns updated User object
  User updateStreak(User user) {
    final now = DateTime.now();
    final lastActive = user.lastActiveDate;
    
    // Check if same day
    if (_isSameDay(now, lastActive)) {
      // Already active today, no streak change unless we need to update lastActive
      return user.copyWith(lastActiveDate: now);
    }
    
    // Check if consecutive day (yesterday)
    final yesterday = now.subtract(const Duration(days: 1));
    if (_isSameDay(yesterday, lastActive)) {
      // Streak continues
      final newStreak = user.currentStreak + 1;
      return user.copyWith(
        currentStreak: newStreak,
        longestStreak: newStreak > user.longestStreak ? newStreak : user.longestStreak,
        lastActiveDate: now,
      );
    }
    
    // Streak broken
    return user.copyWith(
      currentStreak: 1, // Reset to 1 (today is active)
      lastActiveDate: now,
    );
  }

  /// Check for new achievements
  /// Returns list of newly unlocked achievements
  List<Achievement> checkAchievements(User user, List<Achievement> allAchievements) {
    final newAchievements = <Achievement>[];
    
    for (final achievement in allAchievements) {
      // Skip if already unlocked
      if (user.achievementIds.contains(achievement.id)) continue;
      
      bool unlocked = false;
      
      switch (achievement.category) {
        case 'solved':
          unlocked = user.solvedProblems >= achievement.requiredValue;
          break;
        case 'streak':
          unlocked = user.currentStreak >= achievement.requiredValue;
          break;
        case 'points':
          unlocked = user.totalPoints >= achievement.requiredValue;
          break;
        // Add more categories as needed
      }
      
      if (unlocked) {
        newAchievements.add(achievement.unlock());
      }
    }
    
    return newAchievements;
  }

  /// Helper to check if two dates are the same calendar day
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Check for level up
  /// Returns updated user with new level and XP
  User processXP(User user, int xpGained) {
    int currentXp = user.experiencePoints + xpGained;
    int currentLevel = user.level;
    
    while (true) {
      int neededXp = (100 * (currentLevel * currentLevel * 0.5 + currentLevel * 0.5)).toInt();
      if (currentXp >= neededXp) {
        currentXp -= neededXp;
        currentLevel++;
      } else {
        break;
      }
    }
    
    return user.copyWith(
      level: currentLevel,
      experiencePoints: currentXp,
    );
  }
}
