import 'package:flutter/foundation.dart';
import '../core/models/challenge_model.dart';
import '../core/models/submission_model.dart';
import '../core/models/execution_result_model.dart';
import '../data/challenge_repository.dart';
import '../services/code_execution_service.dart';

/// Challenge state provider
class ChallengeProvider with ChangeNotifier {
  final CodeExecutionService _executionService = CodeExecutionService();
  
  List<Challenge> _challenges = [];
  List<Challenge> _filteredChallenges = [];
  Challenge? _currentChallenge;
  bool _isLoading = false;
  bool _isExecuting = false;
  String? _errorMessage;
  ExecutionResult? _lastExecutionResult;
  
  // Filters
  String? _selectedDifficulty;
  List<String> _selectedTags = [];
  String _searchQuery = '';
  String _sortBy = 'newest'; // newest, hardest, popular

  // Getters
  List<Challenge> get challenges => _filteredChallenges.isNotEmpty || _hasActiveFilters 
      ? _filteredChallenges 
      : _challenges;
  Challenge? get currentChallenge => _currentChallenge;
  bool get isLoading => _isLoading;
  bool get isExecuting => _isExecuting;
  String? get errorMessage => _errorMessage;
  ExecutionResult? get lastExecutionResult => _lastExecutionResult;
  String? get selectedDifficulty => _selectedDifficulty;
  List<String> get selectedTags => _selectedTags;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;

  bool get _hasActiveFilters => 
      _selectedDifficulty != null || 
      _selectedTags.isNotEmpty || 
      _searchQuery.isNotEmpty;

  /// Load all challenges
  Future<void> loadChallenges() async {
    _setLoading(true);
    _clearError();

    try {
      _challenges = await ChallengeRepository.getAllChallenges();
      _applyFiltersAndSort();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Load challenge by ID
  Future<void> loadChallenge(String id) async {
    _setLoading(true);
    _clearError();

    try {
      _currentChallenge = await ChallengeRepository.getChallengeById(id);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Set current challenge
  void setCurrentChallenge(Challenge? challenge) {
    _currentChallenge = challenge;
    _lastExecutionResult = null; // Clear previous results
    notifyListeners();
  }

  /// Execute code
  Future<ExecutionResult> executeCode({
    required String code,
    required String language,
    required List<TestCase> testCases,
  }) async {
    _isExecuting = true;
    _clearError();
    notifyListeners();

    try {
      final result = await _executionService.executeCode(
        code: code,
        language: language,
        testCases: testCases,
      );
      
      _lastExecutionResult = result;
      notifyListeners();
      return result;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _isExecuting = false;
      notifyListeners();
    }
  }

  /// Submit code for challenge
  Future<Submission?> submitCode({
    required String userId,
    required String challengeId,
    required String code,
    required String language,
    required int timeTaken,
  }) async {
    final challenge = _currentChallenge;
    if (challenge == null) {
      _setError('No challenge selected');
      return null;
    }

    try {
      final result = await executeCode(
        code: code,
        language: language,
        testCases: challenge.testCases,
      );

      final submission = Submission(
        id: result.submissionId,
        userId: userId,
        challengeId: challengeId,
        code: code,
        language: language,
        status: result.status == ExecutionStatus.success && result.passedTests == result.totalTests
            ? 'passed'
            : result.status == ExecutionStatus.success
                ? 'failed'
                : result.status.name,
        testResults: result.testResults.map((tr) => TestResult(
          input: tr.input,
          expectedOutput: tr.expectedOutput,
          actualOutput: tr.actualOutput ?? '',
          passed: tr.passed,
          executionTime: tr.executionTimeMs,
        )).toList(),
        totalTests: result.totalTests,
        passedTests: result.passedTests,
        executionTime: result.totalExecutionTimeMs,
        timeTaken: timeTaken,
        errorMessage: result.errorMessage,
        submittedAt: result.executedAt,
      );

      return submission;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  /// Filter challenges by difficulty
  void filterByDifficulty(String? difficulty) {
    _selectedDifficulty = difficulty;
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// Filter challenges by tags
  void filterByTags(List<String> tags) {
    _selectedTags = tags;
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// Toggle tag filter
  void toggleTag(String tag) {
    if (_selectedTags.contains(tag)) {
      _selectedTags.remove(tag);
    } else {
      _selectedTags.add(tag);
    }
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// Search challenges
  void searchChallenges(String query) {
    _searchQuery = query;
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// Sort challenges
  void sortChallenges(String sortBy) {
    _sortBy = sortBy;
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _selectedDifficulty = null;
    _selectedTags = [];
    _searchQuery = '';
    _applyFiltersAndSort();
    notifyListeners();
  }

  /// Apply filters and sorting
  void _applyFiltersAndSort() {
    var filtered = List<Challenge>.from(_challenges);

    // Apply difficulty filter
    if (_selectedDifficulty != null) {
      filtered = filtered.where((c) => c.difficulty == _selectedDifficulty).toList();
    }

    // Apply tag filters
    if (_selectedTags.isNotEmpty) {
      filtered = filtered.where((c) => 
        _selectedTags.any((tag) => c.tags.contains(tag))
      ).toList();
    }

    // Apply search query
    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      filtered = filtered.where((c) {
        return c.title.toLowerCase().contains(lowerQuery) ||
            c.description.toLowerCase().contains(lowerQuery) ||
            c.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
      }).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'hardest':
        filtered.sort((a, b) {
          const difficultyOrder = {'Easy': 0, 'Medium': 1, 'Hard': 2};
          return (difficultyOrder[b.difficulty] ?? 0).compareTo(difficultyOrder[a.difficulty] ?? 0);
        });
        break;
      case 'popular':
        filtered.sort((a, b) => b.solvedCount.compareTo(a.solvedCount));
        break;
      case 'success-rate':
        filtered.sort((a, b) => b.successRate.compareTo(a.successRate));
        break;
      case 'newest':
      default:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    _filteredChallenges = filtered;
  }

  /// Get all unique tags from challenges
  List<String> getAllTags() {
    final tags = <String>{};
    for (final challenge in _challenges) {
      tags.addAll(challenge.tags);
    }
    return tags.toList()..sort();
  }

  /// Get challenge statistics
  Map<String, int> getChallengeStats() {
    return {
      'total': _challenges.length,
      'easy': _challenges.where((c) => c.difficulty == 'Easy').length,
      'medium': _challenges.where((c) => c.difficulty == 'Medium').length,
      'hard': _challenges.where((c) => c.difficulty == 'Hard').length,
    };
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
