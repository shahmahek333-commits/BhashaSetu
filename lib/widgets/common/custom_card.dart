import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// A reusable Material 3 rounded card with pastel styling and accessible contrast.
class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;
  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.backgroundColor = AppColors.whiteCard,
    this.borderColor = AppColors.cardBorder,
    this.borderRadius = 16.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: AppColors.lavenderLight.withValues(alpha: 0.5),
          highlightColor: AppColors.creamAlt.withValues(alpha: 0.3),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
