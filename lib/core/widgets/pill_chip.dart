import 'package:flutter/material.dart';

import '../constants/app_color.dart';
import '../constants/app_spacing.dart';
import 'chunky_pressable.dart';

/// Chip con forma de píldora (DESIGN.md › Chips & Category Pills).
///
/// - Con [onTap]: filtro seleccionable ("Explora por vibra").
/// - Sin [onTap]: etiqueta informativa (mazos de una GameCard).
class PillChip extends StatelessWidget {
  const PillChip({
    super.key,
    required this.label,
    this.icon,
    this.iconColor,
    this.selected = false,
    this.onTap,
    this.background,
    this.foreground,
  });

  final String label;
  final IconData? icon;
  final Color? iconColor;
  final bool selected;
  final VoidCallback? onTap;

  /// Permiten teñir etiquetas estáticas (p. ej. el tag de un juego).
  final Color? background;
  final Color? foreground;

  bool get _interactive => onTap != null;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (!_interactive) {
      final fg = foreground ?? AppColors.onSurfaceVariant;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: background ?? AppColors.surfaceContainerLow,
          borderRadius: AppRadius.pill,
          border: background == null
              ? Border.all(color: AppColors.surfaceContainerHigh)
              : null,
        ),
        child: _content(textTheme.labelSmall?.copyWith(color: fg), fg, 15,
            wrapText: true),
      );
    }

    final bg = selected
        ? AppColors.primary
        : (background ?? AppColors.surfaceContainerLowest);
    final fg =
        selected ? AppColors.onPrimary : (foreground ?? AppColors.onSurface);
    final shadow = selected
        ? AppColors.shadowPrimary
        : AppColors.onSurface.withValues(alpha: 0.06);
    final depth = selected ? 3.0 : 2.0;

    return Padding(
      padding: EdgeInsets.only(bottom: depth),
      child: ChunkyPressable(
        onTap: onTap,
        selected: selected,
        builder: (context, pressed) => AnimatedContainer(
          duration: kChunkyPressDuration,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          transform: Matrix4.translationValues(0, pressed ? 2 : 0, 0),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: AppRadius.pill,
            border: selected
                ? null
                : Border.all(color: AppColors.surfaceContainerHighest),
            boxShadow: chunkyShadow(shadow, pressed ? 0 : depth),
          ),
          child: _content(textTheme.labelMedium?.copyWith(color: fg), fg, 18),
        ),
      ),
    );
  }

  /// [wrapText] deja que la etiqueta pase a una segunda línea si no cabe
  /// (chips estáticos dentro de un `Wrap`). Los interactivos no lo usan:
  /// viven en carruseles horizontales, donde el ancho no tiene límite y un
  /// `Flexible` no tendría contra qué medirse.
  Widget _content(TextStyle? style, Color fg, double iconSize,
      {bool wrapText = false}) {
    final text = Text(label, style: style);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: iconSize, color: selected ? fg : (iconColor ?? fg)),
          const SizedBox(width: 4),
        ],
        if (wrapText) Flexible(child: text) else text,
      ],
    );
  }
}
