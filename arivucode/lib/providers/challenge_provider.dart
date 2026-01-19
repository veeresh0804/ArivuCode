import 'package:flutter/foundation.dart';
import '../core/models/challenge_model.dart';
import '../data/challenge_repository.dart';

/// Challenge state provider
class ChallengeProvider with ChangeNotifier {
  List<Challenge> _challenges = [];
  Challenge? _currentChallenge;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Challenge> get challenges => _challenges;
  Challenge? get currentChallenge => _currentChallenge;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load all challenges
  Future<void> loadChallenges() async {
    _setLoading(true);
    _clearError();

    try {
      _challenges = await ChallengeRepository.getAllChallenges();
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
    notifyListeners();
  }

  /// Get challenges by difficulty
  List<Challenge> getChallengesByDifficulty(String difficulty) {
    return _challenges.where((c) => c.difficulty == difficulty).toList();
  }

  /// Search challenges
  List<Challenge> searchChallenges(String query) {
    final lowerQuery = query.toLowerCase();
    return _challenges.where((c) {
      return c.title.toLowerCase().contains(lowerQuery) ||
          c.description.toLowerCase().contains(lowerQuery) ||
          c.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
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
