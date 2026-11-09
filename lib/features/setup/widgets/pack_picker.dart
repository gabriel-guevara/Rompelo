import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_color.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/pill_chip.dart';
import '../data/deck_options.dart';

/// Selector de packs en dos niveles: mezclas rápidas de un toque y, si se
/// quiere, la lista completa plegada y ordenada por grupos.
class PackPicker extends StatefulWidget {
  const PackPicker({
    super.key,
    required this.packs,
    required this.groups,
    required this.selected,
    required this.onToggle,
    required this.onSelectMany,
    this.surpriseCount = 4,
  });

  final List<DeckOption> packs;
  final List<DeckGroup> groups;
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final ValueChanged<Set<String>> onSelectMany;

  /// Cuántos packs elige "Sorpresa".
  final int surpriseCount;

  @override
  State<PackPicker> createState() => _PackPickerState();
}

class _PackPickerState extends State<PackPicker> {
  final Random _random = Random();
  bool _expanded = false;

  late final Map<String, DeckOption> _byId = {
    for (final pack in widget.packs) pack.id: pack,
  };

  Set<String> get _allIds => _byId.keys.toSet();

  void _surprise() {
    final ids = _allIds.toList()..shuffle(_random);
    widget.onSelectMany(ids.take(widget.surpriseCount).toSet());
  }

  String _summary() {
    final titles = [
      for (final pack in widget.packs)
        if (widget.selected.contains(pack.id)) pack.title,
    ];
    if (titles.length == widget.packs.length) return 'Todos los temas';
    if (titles.length <= 2) return titles.join(' y ');
    return '${titles.take(2).join(', ')} y ${titles.length - 2} más';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Nivel 1: mezclas rápidas.
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            PillChip(
              label: 'Sorpresa',
              icon: Icons.casino_rounded,
              onTap: _surprise,
            ),
            PillChip(
              label: 'Todo mezclado',
              icon: Icons.all_inclusive_rounded,
              selected: setEquals(widget.selected, _allIds),
              onTap: () => widget.onSelectMany(_allIds),
            ),
            for (final group in widget.groups)
              PillChip(
                label: group.title,
                icon: group.icon,
                selected: setEquals(widget.selected, group.deckIds.toSet()),
                onTap: () => widget.onSelectMany(group.deckIds.toSet()),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Resumen de lo elegido + botón para personalizar.
        Container(
          padding: const EdgeInsets.only(left: AppSpacing.md),
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: AppRadius.pill,
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  _summary(),
                  style: textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton.icon(
                onPressed: () => setState(() => _expanded = !_expanded),
                icon: Icon(_expanded
                    ? Icons.expand_less_rounded
                    : Icons.tune_rounded),
                label: Text(_expanded ? 'Listo' : 'Personalizar'),
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary),
              ),
            ],
          ),
        ),

        // Nivel 2: todos los packs, plegados por grupo.
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: _expanded
              ? Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final group in widget.groups) ...[
                        Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: Row(
                            children: [
                              Icon(group.icon,
                                  size: 18, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text(group.title, style: textTheme.labelLarge),
                            ],
                          ),
                        ),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.xs,
                          children: [
                            for (final id in group.deckIds)
                              if (_byId[id] case final pack?)
                                PillChip(
                                  key: ValueKey('deck-$id'),
                                  label: pack.title,
                                  icon: pack.icon,
                                  selected: widget.selected.contains(id),
                                  onTap: () => widget.onToggle(id),
                                ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    ],
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}