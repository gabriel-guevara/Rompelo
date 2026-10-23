import 'package:flutter/material.dart';

import '../constants/app_color.dart';
import '../constants/app_spacing.dart';
import 'chunky_pressable.dart';

/// Variantes de color del botón chunky (DESIGN.md › Buttons).
enum ChunkyButtonVariant {
  /// Acción principal de tensión: vino con texto blanco.
  wine(AppColors.secondary, AppColors.onSecondary, AppColors.shadowWine),

  /// Acción de navegación: azul primario con texto blanco.
  primary(AppColors.primary, AppColors.onPrimary, AppColors.shadowPrimary),

  /// Azul cielo con texto tinta.
  sky(AppColors.primaryContainer, AppColors.ink, AppColors.shadowSky),

  /// Leche con texto tinta (p. ej. "Pasar").
  milk(AppColors.milk, AppColors.ink, AppColors.shadowTactile),

  /// Fantasma: borde, sin relleno ni sombra.
  ghost(Colors.transparent, AppColors.ink, Colors.transparent);

  const ChunkyButtonVariant(this.background, this.foreground, this.shadow);

  final Color background;
  final Color foreground;
  final Color shadow;
}

/// Botón pill con sombra sólida que se "hunde" al presionar, como un
/// pulsador de arcade.
class ChunkyButton extends StatelessWidget {
  const ChunkyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ChunkyButtonVariant.wine,
    this.leadingIcon,
    this.trailingIcon,
    this.height = 58,
    this.depth = 5,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final ChunkyButtonVariant variant;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  /// Alto mínimo del botón (58 px en DESIGN.md; 48 en las GameCards).
  final double height;

  /// Grosor de la sombra sólida inferior.
  final double depth;

  /// `true` ocupa todo el ancho disponible (zona del pulgar).
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final isGhost = variant == ChunkyButtonVariant.ghost;
    final textStyle = Theme.of(context)
        .textTheme
        .labelLarge
        ?.copyWith(color: variant.foreground);

    return Opacity(
      opacity: onPressed == null ? 0.5 : 1,
      // El padding inferior reserva el espacio de la sombra para que no se
      // superponga con lo que haya debajo.
      child: Padding(
        padding: EdgeInsets.only(bottom: isGhost ? 0 : depth),
        child: ChunkyPressable(
          onTap: onPressed,
          semanticLabel: label,
          builder: (context, pressed) => AnimatedContainer(
            duration: kChunkyPressDuration,
            curve: Curves.easeOut,
            constraints: BoxConstraints(minHeight: height),
            width: expand ? double.infinity : null,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            transform: Matrix4.translationValues(
                0, pressed && !isGhost ? depth - 1 : 0, 0),
            decoration: BoxDecoration(
              color: variant.background,
              borderRadius: AppRadius.pill,
              border: isGhost
                  ? Border.all(
                      color: AppColors.ink.withValues(alpha: 0.2), width: 2)
                  : null,
              boxShadow: isGhost
                  ? null
                  : chunkyShadow(variant.shadow, pressed ? 1 : depth),
            ),
            child: Row(
              mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (leadingIcon != null) ...[
                  Icon(leadingIcon, size: 22, color: variant.foreground),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: textStyle,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (trailingIcon != null) ...[
                  const SizedBox(width: 8),
                  Icon(trailingIcon, size: 20, color: variant.foreground),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
