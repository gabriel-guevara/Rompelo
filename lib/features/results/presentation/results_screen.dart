import 'package:flutter/material.dart';

import '../../../core/widgets/placeholder_screen.dart';

/// Tab Marcador (`/resultados`).
///
/// Placeholder de la Fase 1; el podio y los premios llegan en la Fase 5.
class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Marcador',
      icon: Icons.emoji_events_rounded,
      message: 'Aquí verás el podio y los premios de la noche al terminar '
          'una partida.',
    );
  }
}
