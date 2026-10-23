import 'package:flutter/material.dart';

import '../constants/app_color.dart';
import '../theme/app_theme.dart';
import 'chunky_pressable.dart';

/// Stepper "− 6 +" para elegir cantidades (jugadores, impostores, rondas).
///
/// Es un widget *controlado*: no guarda el valor, lo recibe en [value] y
/// avisa los cambios con [onChanged] (como un input controlado en React).
class CounterStepper extends StatelessWidget {
  const CounterStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 99,
    this.accent = AppColors.secondary,
    this.accentShadow = AppColors.shadowWine,
    this.semanticName = 'jugadores',
  }) : assert(min <= max);

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  /// Color del botón "+" y del número.
  final Color accent;
  final Color accentShadow;

  /// Se usa en las etiquetas de accesibilidad ("Aumentar jugadores").
  final String semanticName;

  @override
  Widget build(BuildContext context) {
    final numberStyle = AppTheme.tabular(
      AppTheme.withWeight(
        Theme.of(context).textTheme.headlineMedium!,
        FontWeight.w800,
      ).copyWith(color: accent),
    );

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainer,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.all(Radius.circular(999)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            key: const ValueKey('stepper-minus'),
            icon: Icons.remove_rounded,
            semanticLabel: 'Disminuir $semanticName',
            onTap: value > min ? () => onChanged(value - 1) : null,
            background: AppColors.surfaceContainerLowest,
            foreground: AppColors.onSurface,
            shadow: AppColors.borderSubtle,
          ),
          SizedBox(
            width: 44,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: numberStyle,
            ),
          ),
          _StepButton(
            key: const ValueKey('stepper-plus'),
            icon: Icons.add_rounded,
            semanticLabel: 'Aumentar $semanticName',
            onTap: value < max ? () => onChanged(value + 1) : null,
            background: accent,
            foreground: Colors.white,
            shadow: accentShadow,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
    required this.background,
    required this.foreground,
    required this.shadow,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onTap;
  final Color background;
  final Color foreground;
  final Color shadow;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.4 : 1,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: ChunkyPressable(
          onTap: onTap,
          semanticLabel: semanticLabel,
          builder: (context, pressed) => AnimatedContainer(
            duration: kChunkyPressDuration,
            width: 40,
            height: 40,
            transform: Matrix4.translationValues(0, pressed ? 3 : 0, 0),
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
              boxShadow: chunkyShadow(shadow, pressed ? 0 : 3),
            ),
            child: Icon(icon, size: 20, color: foreground),
          ),
        ),
      ),
    );
  }
}
