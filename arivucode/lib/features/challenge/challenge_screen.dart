import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/challenge_model.dart';
import '../../data/challenge_repository.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/difficulty_badge.dart';
import 'challenge_detail_screen.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  List<Challenge> _challenges = [];
  List<Challenge> _filteredChallenges = [];
  bool _isLoading = true;
  String _selectedDifficulty = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadChallenges();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadChallenges() async {
    setState(() => _isLoading = true);
    try {
      final challenges = await ChallengeRepository.getAllChallenges();
      setState(() {
        _challenges = challenges;
        _filteredChallenges = challenges;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading challenges: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _filterChallenges() {
    setState(() {
      _filteredChallenges = _challenges.where((challenge) {
        // Filter by difficulty
        final matchesDifficulty = _selectedDifficulty == 'All' ||
            challenge.difficulty == _selectedDifficulty;

        // Filter by search query
        final query = _searchController.text.toLowerCase();
        final matchesSearch = query.isEmpty ||
            challenge.title.toLowerCase().contains(query) ||
            challenge.description.toLowerCase().contains(query) ||
            challenge.tags.any((tag) => tag.toLowerCase().contains(query));

        return matchesDifficulty && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Challenges'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadChallenges,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: Column(
          children: [
            _buildSearchAndFilter(),
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _filteredChallenges.isEmpty
                      ? _buildEmptyState()
                      : _buildChallengeList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.backgroundMedium,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            onChanged: (_) => _filterChallenges(),
            decoration: InputDecoration(
              hintText: 'Search challenges...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filterChallenges();
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Difficulty filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All'),
                const SizedBox(width: 8),
                _buildFilterChip(AppConstants.difficultyEasy),
                const SizedBox(width: 8),
                _buildFilterChip(AppConstants.difficultyMedium),
                const SizedBox(width: 8),
                _buildFilterChip(AppConstants.difficultyHard),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String difficulty) {
    final isSelected = _selectedDifficulty == difficulty;
    final color = difficulty == 'All'
        ? AppColors.primary
        : difficulty == AppConstants.difficultyEasy
            ? AppColors.difficultyEasy
            : difficulty == AppConstants.difficultyMedium
                ? AppColors.difficultyMedium
                : AppColors.difficultyHard;

    return FilterChip(
      label: Text(difficulty),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedDifficulty = difficulty;
          _filterChallenges();
        });
      },
      backgroundColor: AppColors.surface,
      selectedColor: color.withOpacity(0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected ? color : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
      side: BorderSide(
        color: isSelected ? color : AppColors.border,
        width: isSelected ? 2 : 1,
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No challenges found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeList() {
    return RefreshIndicator(
      onRefresh: _loadChallenges,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        itemCount: _filteredChallenges.length,
        itemBuilder: (context, index) {
          final challenge = _filteredChallenges[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.paddingMedium),
            child: _buildChallengeCard(challenge),
          );
        },
      ),
    );
  }

  Widget _buildChallengeCard(Challenge challenge) {
    return CustomCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChallengeDetailScreen(challenge: challenge),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and difficulty
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  challenge.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              DifficultyBadge(difficulty: challenge.difficulty),
            ],
          ),
          const SizedBox(height: 8),
          
          // Description preview
          Text(
            challenge.description.split('\n').first,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          
          // Tags
          if (challenge.tags.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: challenge.tags.take(3).map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 12),
          
          // Stats row
          Row(
            children: [
              _buildStatItem(Icons.star, '${challenge.points} pts'),
              const SizedBox(width: 16),
              _buildStatItem(Icons.timer, '${challenge.timeLimit ~/ 60} min'),
              const SizedBox(width: 16),
              _buildStatItem(Icons.people, '${challenge.solvedCount}'),
              const Spacer(),
              Text(
                '${challenge.successRate.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: challenge.successRate >= 70
                      ? AppColors.success
                      : challenge.successRate >= 50
                          ? AppColors.warning
                          : AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
