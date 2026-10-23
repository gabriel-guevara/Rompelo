import 'package:flutter/material.dart';

import '../constants/app_color.dart';
import '../constants/app_spacing.dart';
import 'chunky_pressable.dart';

/// Tile de selección (reemplaza checkboxes/radios, DESIGN.md › Selection
/// Controls). Se usa para mazos temáticos, packs de preguntas, etc.
class SelectionTile extends StatelessWidget {
  const SelectionTile({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.icon,
    this.badge,
    this.activeColor = AppColors.secondary,
    this.activeShadow = AppColors.shadowWine,
    this.activeTint = AppColors.secondaryFixed,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;

  /// Insignia corta junto al título, p. ej. "Popular".
  final String? badge;
  final bool selected;
  final VoidCallback? onTap;

  /// Color del icono y del check cuando está seleccionado.
  final Color activeColor;
  final Color activeShadow;

  /// Fondo suave del tile seleccionado.
  final Color activeTint;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: ChunkyPressable(
        onTap: onTap,
        selected: selected,
        semanticLabel: title,
        builder: (context, pressed) => AnimatedScale(
          // Pequeño "rebote" al seleccionar (scale 1.02 del mockup).
          scale: selected && !pressed ? 1.02 : 1,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutBack,
          child: AnimatedContainer(
            duration: kChunkyPressDuration,
            padding: const EdgeInsets.all(AppSpacing.md),
            transform: Matrix4.translationValues(0, pressed ? 2 : 0, 0),
            decoration: BoxDecoration(
              color: selected
                  ? activeTint.withValues(alpha: 0.4)
                  : AppColors.surfaceContainerLowest,
              borderRadius: AppRadius.inner,
              border:
                  selected ? null : Border.all(color: AppColors.milk, width: 2),
              boxShadow: chunkyShadow(
                selected ? activeTint : AppColors.borderSubtle,
                pressed ? 0 : 3,
              ),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  _IconBox(
                    icon: icon!,
                    selected: selected,
                    color: activeColor,
                    shadow: activeShadow,
                  ),
                  const SizedBox(width: AppSpacing.md),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(title, style: textTheme.labelLarge),
                          if (badge != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: activeColor,
                                borderRadius: AppRadius.pill,
                              ),
                              child: Text(
                                badge!,
                                style: textTheme.labelSmall
                                    ?.copyWith(color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                      if (subtitle != null)
                        Text(subtitle!, style: textTheme.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _Check(selected: selected, color: activeColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({
    required this.icon,
    required this.selected,
    required this.color,
    required this.shadow,
  });

  final IconData icon;
  final bool selected;
  final Color color;
  final Color shadow;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: kChunkyPressDuration,
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: selected ? color : AppColors.surfaceContainerLow,
        borderRadius: AppRadius.inner,
        boxShadow: selected ? chunkyShadow(shadow, 3) : null,
      ),
      child: Icon(
        icon,
        size: 24,
        color: selected ? Colors.white : AppColors.onSurfaceVariant,
      ),
    );
  }
}

class _Check extends StatelessWidget {
  const _Check({required this.selected, required this.color});

  final bool selected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: kChunkyPressDuration,
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? color : Colors.transparent,
        border: selected
            ? null
            : Border.all(color: AppColors.outlineVariant, width: 2),
      ),
      child: selected
          ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
          : null,
    );
  }
}
