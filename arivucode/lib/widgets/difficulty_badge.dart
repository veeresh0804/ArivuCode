import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';

class DifficultyBadge extends StatelessWidget {
  final String difficulty;
  final bool showIcon;

  const DifficultyBadge({
    super.key,
    required this.difficulty,
    this.showIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = _getDifficultyColor();
    final IconData icon = _getDifficultyIcon();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingSmall,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            difficulty,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor() {
    return switch (difficulty.toLowerCase()) {
      'easy' => AppColors.difficultyEasy,
      'medium' => AppColors.difficultyMedium,
      'hard' => AppColors.difficultyHard,
      _ => AppColors.textSecondary,
    };
  }

  IconData _getDifficultyIcon() {
    return switch (difficulty.toLowerCase()) {
      'easy' => Icons.star_outline,
      'medium' => Icons.star_half,
      'hard' => Icons.star,
      _ => Icons.help_outline,
    };
  }
}
