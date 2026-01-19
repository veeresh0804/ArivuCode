/// Submission result for a test case
class TestResult {
  final String input;
  final String expectedOutput;
  final String actualOutput;
  final bool passed;
  final int executionTime; // in milliseconds

  const TestResult({
    required this.input,
    required this.expectedOutput,
    required this.actualOutput,
    required this.passed,
    required this.executionTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'input': input,
      'expectedOutput': expectedOutput,
      'actualOutput': actualOutput,
      'passed': passed,
      'executionTime': executionTime,
    };
  }

  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      input: json['input'] as String,
      expectedOutput: json['expectedOutput'] as String,
      actualOutput: json['actualOutput'] as String,
      passed: json['passed'] as bool,
      executionTime: json['executionTime'] as int,
    );
  }
}

/// Submission model
class Submission {
  final String id;
  final String userId;
  final String challengeId;
  final String code;
  final String language;
  final String status; // pending, running, passed, failed, error
  final List<TestResult> testResults;
  final int totalTests;
  final int passedTests;
  final int executionTime; // total time in milliseconds
  final int timeTaken; // time taken by user in seconds
  final String? errorMessage;
  final DateTime submittedAt;

  const Submission({
    required this.id,
    required this.userId,
    required this.challengeId,
    required this.code,
    required this.language,
    required this.status,
    this.testResults = const [],
    required this.totalTests,
    required this.passedTests,
    this.executionTime = 0,
    this.timeTaken = 0,
    this.errorMessage,
    required this.submittedAt,
  });

  bool get isPassed => status == 'passed' && passedTests == totalTests;
  bool get isFailed => status == 'failed' || status == 'error';
  bool get isRunning => status == 'running' || status == 'pending';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'challengeId': challengeId,
      'code': code,
      'language': language,
      'status': status,
      'testResults': testResults.map((tr) => tr.toJson()).toList(),
      'totalTests': totalTests,
      'passedTests': passedTests,
      'executionTime': executionTime,
      'timeTaken': timeTaken,
      'errorMessage': errorMessage,
      'submittedAt': submittedAt.toIso8601String(),
    };
  }

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      id: json['id'] as String,
      userId: json['userId'] as String,
      challengeId: json['challengeId'] as String,
      code: json['code'] as String,
      language: json['language'] as String,
      status: json['status'] as String,
      testResults: (json['testResults'] as List?)
              ?.map((tr) => TestResult.fromJson(tr as Map<String, dynamic>))
              .toList() ??
          [],
      totalTests: json['totalTests'] as int,
      passedTests: json['passedTests'] as int,
      executionTime: json['executionTime'] as int? ?? 0,
      timeTaken: json['timeTaken'] as int? ?? 0,
      errorMessage: json['errorMessage'] as String?,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
    );
  }

  Submission copyWith({
    String? id,
    String? userId,
    String? challengeId,
    String? code,
    String? language,
    String? status,
    List<TestResult>? testResults,
    int? totalTests,
    int? passedTests,
    int? executionTime,
    int? timeTaken,
    String? errorMessage,
    DateTime? submittedAt,
  }) {
    return Submission(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      challengeId: challengeId ?? this.challengeId,
      code: code ?? this.code,
      language: language ?? this.language,
      status: status ?? this.status,
      testResults: testResults ?? this.testResults,
      totalTests: totalTests ?? this.totalTests,
      passedTests: passedTests ?? this.passedTests,
      executionTime: executionTime ?? this.executionTime,
      timeTaken: timeTaken ?? this.timeTaken,
      errorMessage: errorMessage ?? this.errorMessage,
      submittedAt: submittedAt ?? this.submittedAt,
    );
  }
}
