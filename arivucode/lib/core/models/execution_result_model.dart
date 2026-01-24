/// Execution status enum
enum ExecutionStatus {
  pending,
  running,
  success,
  compilationError,
  runtimeError,
  timeout,
  memoryLimit,
  wrongAnswer,
}

/// Individual test case execution result
class TestCaseResult {
  final int testCaseIndex;
  final String input;
  final String expectedOutput;
  final String? actualOutput;
  final bool passed;
  final int executionTimeMs;
  final String? error;

  const TestCaseResult({
    required this.testCaseIndex,
    required this.input,
    required this.expectedOutput,
    this.actualOutput,
    required this.passed,
    required this.executionTimeMs,
    this.error,
  });

  Map<String, dynamic> toJson() {
    return {
      'testCaseIndex': testCaseIndex,
      'input': input,
      'expectedOutput': expectedOutput,
      'actualOutput': actualOutput,
      'passed': passed,
      'executionTimeMs': executionTimeMs,
      'error': error,
    };
  }

  factory TestCaseResult.fromJson(Map<String, dynamic> json) {
    return TestCaseResult(
      testCaseIndex: json['testCaseIndex'] as int,
      input: json['input'] as String,
      expectedOutput: json['expectedOutput'] as String,
      actualOutput: json['actualOutput'] as String?,
      passed: json['passed'] as bool,
      executionTimeMs: json['executionTimeMs'] as int,
      error: json['error'] as String?,
    );
  }
}

/// Complete execution result
class ExecutionResult {
  final String submissionId;
  final ExecutionStatus status;
  final List<TestCaseResult> testResults;
  final int totalTests;
  final int passedTests;
  final int totalExecutionTimeMs;
  final String? compilationOutput;
  final String? errorMessage;
  final DateTime executedAt;

  const ExecutionResult({
    required this.submissionId,
    required this.status,
    required this.testResults,
    required this.totalTests,
    required this.passedTests,
    required this.totalExecutionTimeMs,
    this.compilationOutput,
    this.errorMessage,
    required this.executedAt,
  });

  bool get isSuccess => status == ExecutionStatus.success && passedTests == totalTests;
  bool get hasErrors => status != ExecutionStatus.success && status != ExecutionStatus.wrongAnswer;
  bool get isWrongAnswer => status == ExecutionStatus.wrongAnswer || (status == ExecutionStatus.success && passedTests < totalTests);
  
  double get passRate => totalTests > 0 ? passedTests / totalTests : 0.0;

  String get statusMessage {
    return switch (status) {
      ExecutionStatus.pending => 'Pending execution...',
      ExecutionStatus.running => 'Running tests...',
      ExecutionStatus.success => passedTests == totalTests 
          ? 'All tests passed! 🎉'
          : '$passedTests/$totalTests tests passed',
      ExecutionStatus.compilationError => 'Compilation error',
      ExecutionStatus.runtimeError => 'Runtime error',
      ExecutionStatus.timeout => 'Time limit exceeded',
      ExecutionStatus.memoryLimit => 'Memory limit exceeded',
      ExecutionStatus.wrongAnswer => '$passedTests/$totalTests tests passed',
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'submissionId': submissionId,
      'status': status.name,
      'testResults': testResults.map((tr) => tr.toJson()).toList(),
      'totalTests': totalTests,
      'passedTests': passedTests,
      'totalExecutionTimeMs': totalExecutionTimeMs,
      'compilationOutput': compilationOutput,
      'errorMessage': errorMessage,
      'executedAt': executedAt.toIso8601String(),
    };
  }

  factory ExecutionResult.fromJson(Map<String, dynamic> json) {
    return ExecutionResult(
      submissionId: json['submissionId'] as String,
      status: ExecutionStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => ExecutionStatus.pending,
      ),
      testResults: (json['testResults'] as List)
          .map((tr) => TestCaseResult.fromJson(tr as Map<String, dynamic>))
          .toList(),
      totalTests: json['totalTests'] as int,
      passedTests: json['passedTests'] as int,
      totalExecutionTimeMs: json['totalExecutionTimeMs'] as int,
      compilationOutput: json['compilationOutput'] as String?,
      errorMessage: json['errorMessage'] as String?,
      executedAt: DateTime.parse(json['executedAt'] as String),
    );
  }
}
