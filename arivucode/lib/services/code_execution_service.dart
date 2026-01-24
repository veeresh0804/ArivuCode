import 'dart:async';
import 'dart:math';
import 'package:uuid/uuid.dart';
import '../core/models/execution_result_model.dart';
import '../core/models/challenge_model.dart';

/// Code execution service
/// Currently uses mock execution - can be replaced with Judge0 API or custom backend
class CodeExecutionService {
  final _uuid = const Uuid();
  final _random = Random();

  /// Execute code against test cases
  /// Returns ExecutionResult with test results
  Future<ExecutionResult> executeCode({
    required String code,
    required String language,
    required List<TestCase> testCases,
    int timeoutSeconds = 10,
  }) async {
    final submissionId = _uuid.v4();
    final startTime = DateTime.now();

    try {
      // Simulate compilation/validation
      await Future.delayed(const Duration(milliseconds: 500));

      // Check for basic syntax errors (mock)
      if (_hasBasicSyntaxError(code, language)) {
        return ExecutionResult(
          submissionId: submissionId,
          status: ExecutionStatus.compilationError,
          testResults: [],
          totalTests: testCases.length,
          passedTests: 0,
          totalExecutionTimeMs: 0,
          compilationOutput: null,
          errorMessage: 'Compilation failed: Syntax error detected',
          executedAt: startTime,
        );
      }

      // Execute test cases
      final testResults = <TestCaseResult>[];
      int totalExecTime = 0;
      int passedCount = 0;

      for (int i = 0; i < testCases.length; i++) {
        final testCase = testCases[i];
        
        // Simulate execution delay
        await Future.delayed(Duration(milliseconds: 100 + _random.nextInt(200)));
        
        final result = await _executeTestCase(
          code: code,
          language: language,
          testCase: testCase,
          index: i,
        );
        
        testResults.add(result);
        totalExecTime += result.executionTimeMs;
        if (result.passed) passedCount++;

        // Check for timeout
        if (totalExecTime > timeoutSeconds * 1000) {
          return ExecutionResult(
            submissionId: submissionId,
            status: ExecutionStatus.timeout,
            testResults: testResults,
            totalTests: testCases.length,
            passedTests: passedCount,
            totalExecutionTimeMs: totalExecTime,
            errorMessage: 'Time limit exceeded',
            executedAt: startTime,
          );
        }
      }

      // Determine final status
      final status = passedCount == testCases.length
          ? ExecutionStatus.success
          : ExecutionStatus.wrongAnswer;

      return ExecutionResult(
        submissionId: submissionId,
        status: status,
        testResults: testResults,
        totalTests: testCases.length,
        passedTests: passedCount,
        totalExecutionTimeMs: totalExecTime,
        executedAt: startTime,
      );
    } catch (e) {
      return ExecutionResult(
        submissionId: submissionId,
        status: ExecutionStatus.runtimeError,
        testResults: [],
        totalTests: testCases.length,
        passedTests: 0,
        totalExecutionTimeMs: 0,
        errorMessage: 'Runtime error: ${e.toString()}',
        executedAt: startTime,
      );
    }
  }

  /// Execute a single test case (mock implementation)
  Future<TestCaseResult> _executeTestCase({
    required String code,
    required String language,
    required TestCase testCase,
    required int index,
  }) async {
    // Simulate execution time
    final execTime = 50 + _random.nextInt(200);
    
    // Mock: Check if code looks reasonable
    // In reality, this would execute the code with the input
    final codeQuality = _analyzeCodeQuality(code, language);
    
    // Simulate different outcomes based on code quality
    if (codeQuality < 0.3) {
      // Bad code - likely to fail
      return TestCaseResult(
        testCaseIndex: index,
        input: testCase.input,
        expectedOutput: testCase.expectedOutput,
        actualOutput: 'Incorrect output',
        passed: false,
        executionTimeMs: execTime,
      );
    } else if (codeQuality < 0.5) {
      // Mediocre code - random pass/fail
      final passed = _random.nextBool();
      return TestCaseResult(
        testCaseIndex: index,
        input: testCase.input,
        expectedOutput: testCase.expectedOutput,
        actualOutput: passed ? testCase.expectedOutput : 'Wrong output',
        passed: passed,
        executionTimeMs: execTime,
      );
    } else {
      // Good code - likely to pass with occasional edge case failures
      final passed = _random.nextDouble() > 0.1; // 90% pass rate
      return TestCaseResult(
        testCaseIndex: index,
        input: testCase.input,
        expectedOutput: testCase.expectedOutput,
        actualOutput: passed ? testCase.expectedOutput : 'Edge case failure',
        passed: passed,
        executionTimeMs: execTime,
      );
    }
  }

  /// Mock: Analyze code quality
  double _analyzeCodeQuality(String code, String language) {
    if (code.trim().isEmpty) return 0.0;
    
    double score = 0.5; // Base score
    
    // Check for language-specific patterns
    switch (language.toLowerCase()) {
      case 'python':
        if (code.contains('def ')) score += 0.2;
        if (code.contains('return')) score += 0.1;
        if (code.contains('print')) score += 0.1;
        break;
      case 'java':
        if (code.contains('public static void main')) score += 0.2;
        if (code.contains('System.out.println')) score += 0.1;
        break;
      case 'c':
      case 'c++':
        if (code.contains('int main')) score += 0.2;
        if (code.contains('printf') || code.contains('cout')) score += 0.1;
        break;
      case 'javascript':
        if (code.contains('function') || code.contains('=>')) score += 0.2;
        if (code.contains('console.log')) score += 0.1;
        break;
    }
    
    // Check code length - reasonable solutions are usually 10-100 lines
    final lines = code.split('\n').length;
    if (lines >= 5 && lines <= 100) score += 0.1;
    
    return score.clamp(0.0, 1.0);
  }

  /// Mock: Check for basic syntax errors
  bool _hasBasicSyntaxError(String code, String language) {
    if (code.trim().isEmpty) return true;
    
    // Very basic checks - in reality, this would be done by compiler
    switch (language.toLowerCase()) {
      case 'python':
        // Check for unmatched parentheses
        if (_countChar(code, '(') != _countChar(code, ')')) return true;
        if (_countChar(code, '[') != _countChar(code, ']')) return true;
        break;
      case 'java':
      case 'c':
      case 'c++':
        if (_countChar(code, '{') != _countChar(code, '}')) return true;
        if (_countChar(code, '(') != _countChar(code, ')')) return true;
        break;
      case 'javascript':
        if (_countChar(code, '{') != _countChar(code, '}')) return true;
        break;
    }
    
    return false;
  }

  int _countChar(String text, String char) {
    return char.allMatches(text).length;
  }

  /// Validate code before execution
  bool validateCode(String code, String language) {
    if (code.trim().isEmpty) return false;
    if (_hasBasicSyntaxError(code, language)) return false;
    return true;
  }
}
