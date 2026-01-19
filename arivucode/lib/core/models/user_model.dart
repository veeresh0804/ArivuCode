/// User model
class User {
  final String id;
  final String username;
  final String email;
  final String? profileImageUrl;
  final int totalPoints;
  final int solvedProblems;
  final int currentStreak;
  final int longestStreak;
  final DateTime lastActiveDate;
  final List<String> achievementIds;
  final List<String> friendIds;
  final DateTime createdAt;
  final Map<String, int> languageStats; // language -> problems solved

  const User({
    required this.id,
    required this.username,
    required this.email,
    this.profileImageUrl,
    this.totalPoints = 0,
    this.solvedProblems = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    required this.lastActiveDate,
    this.achievementIds = const [],
    this.friendIds = const [],
    required this.createdAt,
    this.languageStats = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'totalPoints': totalPoints,
      'solvedProblems': solvedProblems,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActiveDate': lastActiveDate.toIso8601String(),
      'achievementIds': achievementIds,
      'friendIds': friendIds,
      'createdAt': createdAt.toIso8601String(),
      'languageStats': languageStats,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      totalPoints: json['totalPoints'] as int? ?? 0,
      solvedProblems: json['solvedProblems'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastActiveDate: DateTime.parse(json['lastActiveDate'] as String),
      achievementIds: List<String>.from(json['achievementIds'] as List? ?? []),
      friendIds: List<String>.from(json['friendIds'] as List? ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      languageStats: Map<String, int>.from(json['languageStats'] as Map? ?? {}),
    );
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? profileImageUrl,
    int? totalPoints,
    int? solvedProblems,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActiveDate,
    List<String>? achievementIds,
    List<String>? friendIds,
    DateTime? createdAt,
    Map<String, int>? languageStats,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      totalPoints: totalPoints ?? this.totalPoints,
      solvedProblems: solvedProblems ?? this.solvedProblems,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      achievementIds: achievementIds ?? this.achievementIds,
      friendIds: friendIds ?? this.friendIds,
      createdAt: createdAt ?? this.createdAt,
      languageStats: languageStats ?? this.languageStats,
    );
  }

  /// Check if streak is still active (within 24 hours)
  bool get isStreakActive {
    final now = DateTime.now();
    final difference = now.difference(lastActiveDate);
    return difference.inHours < 24;
  }

  /// Get initials for avatar
  String get initials {
    if (username.isEmpty) return '?';
    final parts = username.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return username[0].toUpperCase();
  }
}
