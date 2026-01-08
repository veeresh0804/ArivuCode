import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';

enum ButtonVariant {
  primary,
  secondary,
  outline,
  gradient,
}

enum ButtonSize {
  small,
  medium,
  large,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    // Size configurations
    final double horizontalPadding = switch (size) {
      ButtonSize.small => AppConstants.paddingMedium,
      ButtonSize.medium => AppConstants.paddingLarge,
      ButtonSize.large => AppConstants.paddingXLarge,
    };

    final double verticalPadding = switch (size) {
      ButtonSize.small => AppConstants.paddingSmall,
      ButtonSize.medium => AppConstants.paddingMedium,
      ButtonSize.large => 18.0,
    };

    final double fontSize = switch (size) {
      ButtonSize.small => 14.0,
      ButtonSize.medium => 16.0,
      ButtonSize.large => 18.0,
    };

    final double iconSize = switch (size) {
      ButtonSize.small => AppConstants.iconSizeSmall,
      ButtonSize.medium => AppConstants.iconSizeMedium,
      ButtonSize.large => 28.0,
    };

    Widget buttonChild = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == ButtonVariant.outline
                    ? AppColors.primary
                    : Colors.white,
              ),
            ),
          )
        else if (icon != null) ...[
          Icon(icon, size: iconSize),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    Widget button = switch (variant) {
      ButtonVariant.primary => ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.textDisabled,
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.borderRadiusMedium),
            ),
          ),
          child: buttonChild,
        ),
      ButtonVariant.secondary => ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.textDisabled,
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.borderRadiusMedium),
            ),
          ),
          child: buttonChild,
        ),
      ButtonVariant.outline => OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(
              color: isDisabled ? AppColors.textDisabled : AppColors.primary,
              width: 2,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppConstants.borderRadiusMedium),
            ),
          ),
          child: buttonChild,
        ),
      ButtonVariant.gradient => Container(
          decoration: BoxDecoration(
            gradient: isDisabled ? null : AppColors.primaryGradient,
            color: isDisabled ? AppColors.textDisabled : null,
            borderRadius:
                BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
          child: ElevatedButton(
            onPressed: isDisabled ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.borderRadiusMedium),
              ),
            ),
            child: buttonChild,
          ),
        ),
    };

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
