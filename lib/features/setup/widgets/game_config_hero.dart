import 'package:flutter/material.dart';

import '../../../core/constants/app_color.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';

/// Cabecera de cada configuración: etiquetas, título grande, descripción y
/// un pie propio de cada juego (consejo, recomendación, avatares…).
class GameConfigHero extends StatelessWidget {
  const GameConfigHero({
    super.key,
    required this.tags,
    required this.title,
    required this.description,
    this.footer,
    this.tint = AppColors.secondaryFixed,
  });

  /// Píldoras sobre el título (normalmente `PillChip` estáticos).
  final List<Widget> tags;
  final String title;
  final String description;
  final Widget? footer;

  /// Color del brillo del degradado (vino en Charadas, azul en el resto).
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xxl)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceContainerLow,
            AppColors.surfaceContainer,
            tint.withValues(alpha: 0.6),
          ],
        ),
        boxShadow: const [
          BoxShadow(
              color: AppColors.surfaceContainerHighest, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: tags),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style:
                AppTheme.withWeight(textTheme.displayMedium!, FontWeight.w900),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            description,
            style: textTheme.bodyMedium
                ?.copyWith(color: AppColors.onSurfaceVariant),
          ),
          if (footer != null) ...[
            const SizedBox(height: AppSpacing.md),
            footer!,
          ],
        ],
      ),
    );
  }
}
