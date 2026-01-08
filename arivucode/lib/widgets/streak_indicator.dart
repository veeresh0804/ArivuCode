import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/theme/app_theme.dart';

class StreakIndicator extends StatelessWidget {
  final int streakCount;
  final bool showLabel;
  final double size;

  const StreakIndicator({
    super.key,
    required this.streakCount,
    this.showLabel = true,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Fire icon with gradient
        ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.streakGradient.createShader(bounds),
          child: Icon(
            Icons.local_fire_department,
            size: size,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 4),
        // Streak count
        Text(
          streakCount.toString(),
          style: AppTheme.streakTextStyle(fontSize: size * 0.75),
        ),
        if (showLabel) ...[
          const SizedBox(width: 4),
          Text(
            'day${streakCount != 1 ? 's' : ''}',
            style: TextStyle(
              fontSize: size * 0.4,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

/// Animated streak indicator with pulsing effect
class AnimatedStreakIndicator extends StatefulWidget {
  final int streakCount;
  final bool showLabel;
  final double size;

  const AnimatedStreakIndicator({
    super.key,
    required this.streakCount,
    this.showLabel = true,
    this.size = 32,
  });

  @override
  State<AnimatedStreakIndicator> createState() =>
      _AnimatedStreakIndicatorState();
}

class _AnimatedStreakIndicatorState extends State<AnimatedStreakIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: StreakIndicator(
        streakCount: widget.streakCount,
        showLabel: widget.showLabel,
        size: widget.size,
      ),
    );
  }
}
