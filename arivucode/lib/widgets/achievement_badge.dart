import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';

class AchievementBadge extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const AchievementBadge({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        decoration: BoxDecoration(
          gradient: isUnlocked ? AppColors.primaryGradient : null,
          color: isUnlocked ? null : AppColors.surface.withOpacity(0.3),
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          border: Border.all(
            color: isUnlocked
                ? Colors.transparent
                : AppColors.border.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? Colors.white.withOpacity(0.2)
                    : AppColors.surface.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: AppConstants.iconSizeLarge,
                color: isUnlocked ? Colors.white : AppColors.textDisabled,
              ),
            ),
            const SizedBox(height: 8),
            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isUnlocked ? Colors.white : AppColors.textDisabled,
              ),
            ),
            const SizedBox(height: 4),
            // Description
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: isUnlocked
                    ? Colors.white.withOpacity(0.8)
                    : AppColors.textDisabled.withOpacity(0.7),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
