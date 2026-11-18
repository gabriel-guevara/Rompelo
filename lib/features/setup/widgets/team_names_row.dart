import 'package:flutter/material.dart';

import '../../../core/constants/app_color.dart';
import '../../../core/constants/app_spacing.dart';

/// Los dos bandos rivales ("Equipo A" vino / "Equipo B" azul) con su campo
/// de texto. Lo usan Charadas (modo equipos) y Trivia (modo pulsador).
class TeamNamesRow extends StatelessWidget {
  const TeamNamesRow({
    super.key,
    required this.names,
    required this.onRename,
  });

  final List<String> names;
  final void Function(int index, String name) onRename;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TeamNameCard(
            key: const ValueKey('team-name-0'),
            label: 'Equipo A',
            icon: Icons.wine_bar_rounded,
            color: AppColors.secondary,
            tint: AppColors.secondaryFixed,
            name: names[0],
            onChanged: (name) => onRename(0, name),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _TeamNameCard(
            key: const ValueKey('team-name-1'),
            label: 'Equipo B',
            icon: Icons.bubble_chart_rounded,
            color: AppColors.primary,
            tint: AppColors.primaryFixed,
            name: names[1],
            onChanged: (name) => onRename(1, name),
          ),
        ),
      ],
    );
  }
}

/// Tarjeta "Equipo A / Team Vino" con su campo de texto.
///
/// Es `StatefulWidget` porque el `TextEditingController` debe vivir mientras
/// la tarjeta exista (si se creara en `build`, se perdería el cursor en cada
/// tecla).
class _TeamNameCard extends StatefulWidget {
  const _TeamNameCard({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.tint,
    required this.name,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color tint;
  final String name;
  final ValueChanged<String> onChanged;

  @override
  State<_TeamNameCard> createState() => _TeamNameCardState();
}

class _TeamNameCardState extends State<_TeamNameCard> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.name);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: widget.tint.withValues(alpha: 0.5),
        borderRadius: AppRadius.inner,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration:
                    BoxDecoration(color: widget.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(widget.label,
                    style: textTheme.labelSmall?.copyWith(color: widget.color)),
              ),
              Icon(widget.icon, size: 18, color: widget.color),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: _controller,
            onChanged: widget.onChanged,
            maxLength: 16,
            style: textTheme.labelLarge,
            decoration: const InputDecoration(
              counterText: '',
              isDense: true,
              filled: true,
              fillColor: AppColors.surfaceContainerLowest,
              contentPadding:
                  // 13 px arriba/abajo: el campo llega a 48 px de alto.
                  EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              border: OutlineInputBorder(
                borderRadius: AppRadius.pill,
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
