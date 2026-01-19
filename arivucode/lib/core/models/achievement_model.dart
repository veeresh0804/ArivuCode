import '../../core/constants/app_constants.dart';

/// Achievement tier
enum AchievementTier {
  bronze,
  silver,
  gold,
  platinum,
}

/// Achievement model
class Achievement {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final AchievementTier tier;
  final int requiredValue;
  final String category; // streak, solved, speed, etc.
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.tier,
    required this.requiredValue,
    required this.category,
    this.unlockedAt,
  });

  bool get isUnlocked => unlockedAt != null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconName': iconName,
      'tier': tier.name,
      'requiredValue': requiredValue,
      'category': category,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconName: json['iconName'] as String,
      tier: AchievementTier.values.firstWhere(
        (t) => t.name == json['tier'],
        orElse: () => AchievementTier.bronze,
      ),
      requiredValue: json['requiredValue'] as int,
      category: json['category'] as String,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
    );
  }

  Achievement copyWith({
    String? id,
    String? name,
    String? description,
    String? iconName,
    AchievementTier? tier,
    int? requiredValue,
    String? category,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      tier: tier ?? this.tier,
      requiredValue: requiredValue ?? this.requiredValue,
      category: category ?? this.category,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  /// Unlock this achievement
  Achievement unlock() {
    return copyWith(unlockedAt: DateTime.now());
  }
}

/// Predefined achievements
class Achievements {
  Achievements._();

  static final List<Achievement> all = [
    Achievement(
      id: AppConstants.achievementFirstSolve,
      name: 'First Steps',
      description: 'Solve your first challenge',
      iconName: 'code',
      tier: AchievementTier.bronze,
      requiredValue: 1,
      category: 'solved',
    ),
    Achievement(
      id: AppConstants.achievement10Solved,
      name: 'Problem Solver',
      description: 'Solve 10 challenges',
      iconName: 'emoji_events',
      tier: AchievementTier.silver,
      requiredValue: 10,
      category: 'solved',
    ),
    Achievement(
      id: AppConstants.achievement30Solved,
      name: 'Code Master',
      description: 'Solve 30 challenges',
      iconName: 'military_tech',
      tier: AchievementTier.gold,
      requiredValue: 30,
      category: 'solved',
    ),
    Achievement(
      id: AppConstants.achievement100Solved,
      name: 'Coding Legend',
      description: 'Solve 100 challenges',
      iconName: 'workspace_premium',
      tier: AchievementTier.platinum,
      requiredValue: 100,
      category: 'solved',
    ),
    Achievement(
      id: AppConstants.achievementStreak3,
      name: 'Getting Started',
      description: 'Maintain a 3-day streak',
      iconName: 'local_fire_department',
      tier: AchievementTier.bronze,
      requiredValue: 3,
      category: 'streak',
    ),
    Achievement(
      id: AppConstants.achievementStreak7,
      name: 'Dedicated',
      description: 'Maintain a 7-day streak',
      iconName: 'local_fire_department',
      tier: AchievementTier.silver,
      requiredValue: 7,
      category: 'streak',
    ),
    Achievement(
      id: AppConstants.achievementStreak30,
      name: 'Unstoppable',
      description: 'Maintain a 30-day streak',
      iconName: 'local_fire_department',
      tier: AchievementTier.gold,
      requiredValue: 30,
      category: 'streak',
    ),
    Achievement(
      id: AppConstants.achievementFirstWin,
      name: 'First Victory',
      description: 'Beat a friend\'s time',
      iconName: 'emoji_events',
      tier: AchievementTier.bronze,
      requiredValue: 1,
      category: 'competition',
    ),
    Achievement(
      id: AppConstants.achievementSpeedDemon,
      name: 'Speed Demon',
      description: 'Solve a challenge in under 5 minutes',
      iconName: 'speed',
      tier: AchievementTier.silver,
      requiredValue: 1,
      category: 'speed',
    ),
  ];

  /// Get achievement by ID
  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get achievements by category
  static List<Achievement> getByCategory(String category) {
    return all.where((a) => a.category == category).toList();
  }

  /// Get achievements by tier
  static List<Achievement> getByTier(AchievementTier tier) {
    return all.where((a) => a.tier == tier).toList();
  }
}
