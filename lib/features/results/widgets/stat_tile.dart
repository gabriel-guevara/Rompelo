import 'package:flutter/material.dart';

import '../../../core/constants/app_color.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/chunky_pressable.dart';

/// Mini tarjeta de estadística ("Tarjetas jugadas · 42 · En 18 minutos").
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.caption,
    required this.icon,
    this.iconColor = AppColors.primary,
  });

  final String label;
  final String value;
  final String caption;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppRadius.inner,
        boxShadow: chunkyShadow(AppColors.ink.withValues(alpha: 0.06), 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: textTheme.labelSmall
                      ?.copyWith(color: AppColors.onSurfaceVariant),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, size: 20, color: iconColor),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTheme.tabular(
                AppTheme.withWeight(textTheme.headlineLarge!, FontWeight.w900)),
          ),
          Text(caption, style: textTheme.bodySmall),
        ],
      ),
    );
  }
}
