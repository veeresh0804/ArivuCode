import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/streak_indicator.dart'; // Ensure this matches actual file
import '../editor/code_editor_screen.dart';
import '../challenge/challenge_screen.dart';
import '../profile/profile_screen.dart';
import '../gamification/leaderboard_screen.dart';
import '../../providers/user_provider.dart';
import '../../widgets/hologram_globe.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Consume user data
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    return Scaffold(
      body: _buildBody(userProvider),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBody(UserProvider userProvider) {
    return switch (_currentIndex) {
      0 => _buildHomeTab(userProvider),
      1 => const ChallengeScreen(),
      2 => const CodeEditorScreen(), // Accessed via FAB usually, but kept for logic
      3 => const ProfileScreen(), // Ensure this widget exists
      _ => _buildHomeTab(userProvider),
    };
  }

  Widget _buildHomeTab(UserProvider userProvider) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  // Holographic background element
                  Positioned(
                    right: -50,
                    top: -20,
                    child: Opacity(
                      opacity: 0.5,
                      child: const HologramGlobe(size: 250),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWelcomeHeader(userProvider.user?.username ?? 'Coder'),
                        const SizedBox(height: 24),
                        _buildStreakCard(userProvider.currentStreak),
                        const SizedBox(height: 24),
                        _buildStatsRow(userProvider.totalPoints, userProvider.solvedProblems),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingLarge,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            
            // Feature Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingLarge,
              ),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                delegate: SliverChildListDelegate([
                  _buildFeatureCard(
                    icon: Icons.code,
                    title: 'Code Editor',
                    subtitle: 'Practice coding',
                    gradient: AppColors.primaryGradient,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CodeEditorScreen(),
                        ),
                      );
                    },
                  ),
                  _buildFeatureCard(
                    icon: Icons.emoji_events,
                    title: 'Challenges',
                    subtitle: 'Solve problems',
                    gradient: LinearGradient(
                      colors: [AppColors.success, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () {
                      // Navigate via BottomNav or Push
                      setState(() => _currentIndex = 1);
                    },
                  ),
                  _buildFeatureCard(
                    icon: Icons.leaderboard,
                    title: 'Leaderboard',
                    subtitle: 'Top coders',
                    gradient: LinearGradient(
                      colors: [AppColors.warning, AppColors.error],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LeaderboardScreen(),
                        ),
                      );
                    },
                  ),
                  _buildFeatureCard(
                    icon: Icons.school,
                    title: 'Learn',
                    subtitle: 'Tutorials & guides',
                    gradient: LinearGradient(
                      colors: [AppColors.info, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Learning resources coming soon!')),
                      );
                    },
                  ),
                ]),
              ),
            ),
            
            const SliverToBoxAdapter(
              child: SizedBox(height: 100), // Space for FAB
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(String username) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.primaryGradient.createShader(bounds),
              child: Text(
                username,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        // Notification icon
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No new notifications')),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStreakCard(int streak) {
    return CustomCard(
      useGradient: true,
      gradient: AppColors.streakGradient,
      child: Row(
        children: [
          const Icon(
            Icons.local_fire_department,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Streak',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$streak days',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Keep it going! 🔥',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(int points, int solved) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.star,
            value: points.toString(),
            label: 'Points',
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.check_circle,
            value: solved.toString(),
            label: 'Solved',
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return CustomCard(
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return CustomCard(
      useGradient: true,
      gradient: gradient,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundMedium,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2), // Updated to proper API
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index != 2) { // Skip FAB index
            setState(() => _currentIndex = index);
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Challenges',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.code, color: Colors.transparent),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CodeEditorScreen()),
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.code, size: 32),
      ),
    );
  }
}
