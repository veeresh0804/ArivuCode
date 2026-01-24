import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/user_model.dart';
import '../../providers/user_provider.dart';
import '../../widgets/custom_card.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock leaderboard data (since we don't have a backend returning multiple users yet)
    // In a real app, we would fetch List<User> from a provider.
    // Here we will use the current user + mocks.
    
    final currentUser = context.watch<UserProvider>().user;
    
    final List<Map<String, dynamic>> mockUsers = [
      {'name': 'CodeMaster', 'points': 1250, 'avatar': null, 'id': '1'},
      {'name': 'DartVader', 'points': 980, 'avatar': null, 'id': '2'},
      {'name': 'FlutterDev', 'points': 850, 'avatar': null, 'id': '3'},
      {'name': 'AlgorithmAce', 'points': 720, 'avatar': null, 'id': '4'},
      {'name': 'NullSafe', 'points': 650, 'avatar': null, 'id': '5'},
    ];

    if (currentUser != null) {
      mockUsers.add({
        'name': currentUser.username,
        'points': currentUser.totalPoints,
        'avatar': currentUser.profileImageUrl,
        'id': currentUser.id,
      });
      // Sort by points desc
      mockUsers.sort((a, b) => (b['points'] as int).compareTo(a['points'] as int));
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  itemCount: mockUsers.length,
                  itemBuilder: (context, index) {
                    final user = mockUsers[index];
                    final isMe = currentUser != null && user['id'] == currentUser.id;
                    final rank = index + 1;
                    
                    return _buildLeaderboardItem(context, user, rank, isMe);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: AppColors.backgroundMedium,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          const Text(
            'Leaderboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Top coders this week',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(
    BuildContext context, 
    Map<String, dynamic> user, 
    int rank, 
    bool isMe,
  ) {
    final isTop3 = rank <= 3;
    final rankColor = rank == 1 ? const Color(0xFFFFD700) : 
                     rank == 2 ? const Color(0xFFC0C0C0) :
                     rank == 3 ? const Color(0xFFCD7F32) :
                     AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: isMe ? Border.all(color: AppColors.primary.withOpacity(0.5)) : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          alignment: Alignment.center,
          child: isTop3 
              ? Icon(Icons.emoji_events, color: rankColor, size: 28)
              : Text(
                  '#$rank',
                  style: TextStyle(
                    color: rankColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
        ),
        title: Text(
          user['name'],
          style: TextStyle(
            color: isMe ? AppColors.primary : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.backgroundDark,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.stars, size: 16, color: AppColors.warning),
              const SizedBox(width: 4),
              Text(
                '${user['points']}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
