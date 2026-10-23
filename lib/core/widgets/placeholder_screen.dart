import 'package:flutter/material.dart';

import '../constants/app_color.dart';
import '../constants/app_spacing.dart';
import 'chunky_card.dart';
import 'rompelo_app_bar.dart';

/// Pantalla temporal para rutas cuya UI real llega en fases posteriores.
///
/// Permite probar la navegación completa desde la Fase 1 sin crear
/// pantallas vacías duplicadas.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.message,
    this.appBar,
    this.children = const [],
  });

  final String title;
  final IconData icon;
  final String message;

  /// Por defecto [RompeloAppBar]; las pantallas en partida pasan la suya.
  final PreferredSizeWidget? appBar;

  /// Contenido extra bajo la tarjeta (botones de navegación, demos…).
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: appBar ?? const RompeloAppBar(),
      body: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.margin, AppSpacing.lg,
                AppSpacing.margin, AppSpacing.xl),
            children: [
              Text(title, style: textTheme.displayMedium),
              const SizedBox(height: AppSpacing.md),
              ChunkyCard(
                color: AppColors.milk,
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryFixed,
                        borderRadius: AppRadius.inner,
                      ),
                      child: Icon(icon, size: 30, color: AppColors.primary),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(message, style: textTheme.bodyMedium),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
