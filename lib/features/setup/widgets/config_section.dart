import 'package:flutter/material.dart';

import '../../../core/constants/app_color.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/chunky_card.dart';

/// Tarjeta blanca de una sección de configuración ("Reglas de la ronda",
/// "Participantes"…) con título, subtítulo y un icono o widget a la derecha.
class ConfigSection extends StatelessWidget {
  const ConfigSection({
    super.key,
    required this.children,
    this.title,
    this.subtitle,
    this.trailing,
  });

  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ChunkyCard(
      shadowColor: AppColors.surfaceContainerHighest,
      depth: 6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title!, style: textTheme.headlineSmall),
                      if (subtitle != null)
                        Text(subtitle!, style: textTheme.bodySmall),
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  trailing!,
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          ...children,
        ],
      ),
    );
  }
}

/// Fila de una regla: título + explicación a la izquierda, control a la
/// derecha (stepper, switch, valor…).
class RuleRow extends StatelessWidget {
  const RuleRow({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: textTheme.labelLarge),
              if (subtitle != null) Text(subtitle!, style: textTheme.bodySmall),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: AppSpacing.sm),
          trailing!,
        ],
      ],
    );
  }
}

/// [RuleRow] con un interruptor pill del color de acento del juego.
class RuleSwitch extends StatelessWidget {
  const RuleSwitch({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.accent = AppColors.secondary,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    // MergeSemantics: el lector de pantalla anuncia título + estado como un
    // solo control ("Penalización al pasar, activado").
    return MergeSemantics(
      child: RuleRow(
        title: title,
        subtitle: subtitle,
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          thumbColor: const WidgetStatePropertyAll(Colors.white),
          trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? accent
                : AppColors.surfaceContainerHighest,
          ),
          trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
    );
  }
}

/// Etiqueta de un selector con el valor actual resaltado a la derecha
/// ("Tiempo por turno · 1 minuto frenético").
class OptionLabel extends StatelessWidget {
  const OptionLabel({
    super.key,
    required this.label,
    required this.value,
    this.valueColor = AppColors.secondary,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(child: Text(label, style: textTheme.labelLarge)),
          Text(
            value,
            style: AppTheme.withWeight(textTheme.labelMedium!, FontWeight.w700)
                .copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}

/// Badge pequeño de conteo ("2 seleccionados", "3 activos").
class CountBadge extends StatelessWidget {
  const CountBadge({
    super.key,
    required this.label,
    this.background = AppColors.secondaryFixed,
    this.foreground = AppColors.secondary,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.pill,
      ),
      child: Text(
        label,
        style: AppTheme.withWeight(
          Theme.of(context).textTheme.labelSmall!,
          FontWeight.w700,
        ).copyWith(color: foreground),
      ),
    );
  }
}
