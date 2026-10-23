import 'package:flutter/material.dart';

import '../constants/app_color.dart';
import '../constants/app_spacing.dart';
import 'chunky_pressable.dart';

/// Tarjeta "rounded-3xl" con borde sutil y caída sólida inferior
/// (DESIGN.md › Game Cards).
class ChunkyCard extends StatelessWidget {
  const ChunkyCard({
    super.key,
    required this.child,
    this.color = AppColors.surfaceContainerLowest,
    this.borderColor = AppColors.borderSubtle,
    this.shadowColor = AppColors.borderSubtle,
    this.depth = 8,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.borderRadius = AppRadius.card,
  });

  final Widget child;
  final Color color;
  final Color borderColor;
  final Color shadowColor;

  /// Alto de la caída sólida; 0 la elimina.
  final double depth;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      // Reserva el espacio de la caída para no pisar el elemento inferior.
      margin: EdgeInsets.only(bottom: depth),
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: depth > 0 ? chunkyShadow(shadowColor, depth) : null,
      ),
      child: child,
    );
  }
}
