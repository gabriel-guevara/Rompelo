import 'package:flutter/material.dart';

import '../../../core/constants/app_color.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/selection_tile.dart';
import '../data/deck_options.dart';

/// Lista de mazos seleccionables con check (DESIGN.md › Selection Controls).
///
/// Controlada: recibe [selected] y avisa con [onToggle]; la regla de
/// "mínimo N mazos" la decide el provider, no la lista.
class DeckList extends StatelessWidget {
  const DeckList({
    super.key,
    required this.decks,
    required this.selected,
    required this.onToggle,
    this.activeColor = AppColors.secondary,
    this.activeShadow = AppColors.shadowWine,
    this.activeTint = AppColors.secondaryFixed,
  });

  final List<DeckOption> decks;
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final Color activeColor;
  final Color activeShadow;
  final Color activeTint;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final (index, deck) in decks.indexed) ...[
          if (index > 0) const SizedBox(height: AppSpacing.sm),
          SelectionTile(
            key: ValueKey('deck-${deck.id}'),
            title: deck.title,
            subtitle: deck.subtitle,
            icon: deck.icon,
            emoji: deck.emoji,
            badge: deck.badge,
            // Los mazos +18 se tiñen de vino aunque el juego sea azul.
            badgeColor: deck.adult ? AppColors.secondary : null,
            activeColor: deck.adult ? AppColors.secondary : activeColor,
            activeShadow: deck.adult ? AppColors.shadowWine : activeShadow,
            activeTint: deck.adult ? AppColors.secondaryFixed : activeTint,
            selected: selected.contains(deck.id),
            onTap: () => onToggle(deck.id),
          ),
        ],
      ],
    );
  }
}
