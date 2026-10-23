import 'package:flutter/material.dart';

import '../../../core/widgets/placeholder_screen.dart';

/// Tab Ajustes (`/ajustes`).
///
/// Placeholder de la Fase 1; la versión simple final llega en la Fase 5.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Ajustes',
      icon: Icons.settings_rounded,
      message: 'Rómpelo funciona 100 % offline y sin registro.',
    );
  }
}
