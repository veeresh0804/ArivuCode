/// Test case model for challenge validation
class TestCase {
  final String input;
  final String expectedOutput;
  final bool isHidden; // Hidden test cases for anti-cheating

  const TestCase({
    required this.input,
    required this.expectedOutput,
    this.isHidden = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'input': input,
      'expectedOutput': expectedOutput,
      'isHidden': isHidden,
    };
  }

  factory TestCase.fromJson(Map<String, dynamic> json) {
    return TestCase(
      input: json['input'] as String,
      expectedOutput: json['expectedOutput'] as String,
      isHidden: json['isHidden'] as bool? ?? false,
    );
  }
}

/// Challenge model
class Challenge {
  final String id;
  final String title;
  final String description;
  final String difficulty; // Easy, Medium, Hard
  final int points;
  final int timeLimit; // in seconds
  final List<String> supportedLanguages;
  final List<TestCase> testCases;
  final Map<String, String> starterCode; // language -> code
  final List<String> tags;
  final String category; // Arrays, Strings, DP, etc.
  final String? hints;
  final int hintPenalty;
  final String? editorial;
  final List<String> similarChallenges;
  final int solvedCount;
  final double successRate;
  final DateTime createdAt;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.points,
    required this.timeLimit,
    required this.supportedLanguages,
    required this.testCases,
    required this.starterCode,
    this.tags = const [],
    this.category = 'General',
    this.hints,
    this.hintPenalty = 0,
    this.editorial,
    this.similarChallenges = const [],
    this.solvedCount = 0,
    this.successRate = 0.0,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'points': points,
      'timeLimit': timeLimit,
      'supportedLanguages': supportedLanguages,
      'testCases': testCases.map((tc) => tc.toJson()).toList(),
      'starterCode': starterCode,
      'tags': tags,
      'category': category,
      'hints': hints,
      'hintPenalty': hintPenalty,
      'editorial': editorial,
      'similarChallenges': similarChallenges,
      'solvedCount': solvedCount,
      'successRate': successRate,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      difficulty: json['difficulty'] as String,
      points: json['points'] as int,
      timeLimit: json['timeLimit'] as int,
      supportedLanguages: List<String>.from(json['supportedLanguages'] as List),
      testCases: (json['testCases'] as List)
          .map((tc) => TestCase.fromJson(tc as Map<String, dynamic>))
          .toList(),
      starterCode: Map<String, String>.from(json['starterCode'] as Map),
      tags: List<String>.from(json['tags'] as List? ?? []),
      category: json['category'] as String? ?? 'General',
      hints: json['hints'] as String?,
      hintPenalty: json['hintPenalty'] as int? ?? 0,
      editorial: json['editorial'] as String?,
      similarChallenges: List<String>.from(json['similarChallenges'] as List? ?? []),
      solvedCount: json['solvedCount'] as int? ?? 0,
      successRate: (json['successRate'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Challenge copyWith({
    String? id,
    String? title,
    String? description,
    String? difficulty,
    int? points,
    int? timeLimit,
    List<String>? supportedLanguages,
    List<TestCase>? testCases,
    Map<String, String>? starterCode,
    List<String>? tags,
    String? category,
    String? hints,
    int? hintPenalty,
    String? editorial,
    List<String>? similarChallenges,
    int? solvedCount,
    double? successRate,
    DateTime? createdAt,
  }) {
    return Challenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      points: points ?? this.points,
      timeLimit: timeLimit ?? this.timeLimit,
      supportedLanguages: supportedLanguages ?? this.supportedLanguages,
      testCases: testCases ?? this.testCases,
      starterCode: starterCode ?? this.starterCode,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      hints: hints ?? this.hints,
      hintPenalty: hintPenalty ?? this.hintPenalty,
      editorial: editorial ?? this.editorial,
      similarChallenges: similarChallenges ?? this.similarChallenges,
      solvedCount: solvedCount ?? this.solvedCount,
      successRate: successRate ?? this.successRate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
