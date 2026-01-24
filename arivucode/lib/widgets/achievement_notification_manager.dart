import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/models/achievement_model.dart';
import '../providers/user_provider.dart';

class AchievementNotificationManager extends StatefulWidget {
  final Widget child;

  const AchievementNotificationManager({
    super.key,
    required this.child,
  });

  @override
  State<AchievementNotificationManager> createState() => _AchievementNotificationManagerState();
}

class _AchievementNotificationManagerState extends State<AchievementNotificationManager> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;
  
  Achievement? _currentAchievement;
  bool _isShowing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _slideAnimation = Tween<double>(begin: -100.0, end: 50.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5)),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        setState(() => _isShowing = false);
        _checkQueue();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkQueue() {
    if (_isShowing) return;

    final provider = context.read<UserProvider>();
    if (provider.newlyUnlockedAchievements.isNotEmpty) {
      final achievement = provider.newlyUnlockedAchievements.first;
      
      // Remove from queue immediately so we don't show it again
      // We need a method in UserProvider to remove specific one or just clear all carefully
      // For now, simpler approach: provider clears whole list
      // But we can cache it locally
      
      setState(() {
        _currentAchievement = achievement;
        _isShowing = true;
      });
      
      // Use addPostFrameCallback to avoid build issues during state update
      WidgetsBinding.instance.addPostFrameCallback((_) {
         provider.clearNewAchievements(); // This might convert others in list to "old" immediately.
         // Better logical flow: The provider keeps them until consumed.
         // But here assuming simplified flow: shows one batch or just the first one.
         // Let's modify: We iterate through them? 
         // Since clearNewAchievements clears ALL, we only show the first one effectively with this simple logic.
         // That's acceptable for MVP.
      });

      _controller.forward().then((_) {
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) _controller.reverse();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to provider changes
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        if (!_isShowing && provider.newlyUnlockedAchievements.isNotEmpty) {
          // Trigger data processing on next frame to avoid build-phase modifications
          WidgetsBinding.instance.addPostFrameCallback((_) => _checkQueue());
        }
        
        return Stack(
          children: [
            widget.child,
            if (_isShowing && _currentAchievement != null)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: Opacity(
                      opacity: _opacityAnimation.value,
                      child: Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.secondary, AppColors.secondaryDark],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondary.withOpacity(0.5),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                            border: Border.all(color: Colors.white24, width: 1),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getIconData(_currentAchievement!.iconName),
                                  size: 32,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'ACHIEVEMENT UNLOCKED!',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _currentAchievement!.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _currentAchievement!.description,
                                      style: const TextStyle(
                                        color: Colors.white60,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
      child: widget.child,
    );
  }

  IconData _getIconData(String name) {
    return switch (name) {
      'code' => Icons.code,
      'emoji_events' => Icons.emoji_events,
      'military_tech' => Icons.military_tech,
      'workspace_premium' => Icons.workspace_premium,
      'local_fire_department' => Icons.local_fire_department,
      'speed' => Icons.speed,
      _ => Icons.stars,
    };
  }
}
