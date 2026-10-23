import 'package:flutter/material.dart';

import '../../../core/constants/app_color.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/chunky_card.dart';
import '../../../core/widgets/chunky_pressable.dart';
import '../../games/domain/match_result.dart';

/// Colores del icono de cada tono de premio.
extension on AwardTone {
  (Color background, Color foreground, Color shadow) get colors =>
      switch (this) {
        AwardTone.sky => (
            AppColors.primaryContainer,
            AppColors.onPrimaryContainer,
            AppColors.shadowSky,
          ),
        AwardTone.wine => (
            AppColors.secondaryFixed,
            AppColors.onSecondaryFixedVariant,
            AppColors.secondaryFixedDim,
          ),
        AwardTone.warm => (
            AppColors.tertiaryFixed,
            AppColors.onTertiaryFixedVariant,
            AppColors.tertiaryContainer,
          ),
      };

  /// Color del nombre del ganador.
  Color get accent => switch (this) {
        AwardTone.sky => AppColors.primary,
        AwardTone.wine => AppColors.secondary,
        AwardTone.warm => AppColors.onSurface,
      };
}

/// Fila de "Premios de la noche": icono, premio y ganador.
class AwardTile extends StatelessWidget {
  const AwardTile({super.key, required this.award});

  final MatchAward award;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final (background, foreground, shadow) = award.tone.colors;

    return ChunkyCard(
      depth: 4,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: background,
              borderRadius: AppRadius.inner,
              boxShadow: chunkyShadow(shadow, 3),
            ),
            child: Icon(award.icon, size: 24, color: foreground),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(award.title,
                    style: textTheme.labelLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                Text(award.description,
                    style: textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // El ganador puede ser largo ("Ana y Lucas"): se limita su ancho.
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  award.winner,
                  style:
                      textTheme.labelLarge?.copyWith(color: award.tone.accent),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  award.caption,
                  style: textTheme.labelSmall
                      ?.copyWith(color: AppColors.onSurfaceVariant),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
