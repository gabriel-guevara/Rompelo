import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_color.dart';
import '../constants/app_spacing.dart';
import '../theme/app_theme.dart';

/// Un destino de la barra inferior.
class _Destination {
  const _Destination(this.label, this.icon, this.activeIcon);

  final String label;
  final IconData icon;
  final IconData activeIcon;
}

/// El orden debe coincidir con las ramas del `StatefulShellRoute`.
const List<_Destination> _destinations = [
  _Destination(
      'Explorar', Icons.sports_esports_outlined, Icons.sports_esports_rounded),
  _Destination('Configurar', Icons.tune_rounded, Icons.tune_rounded),
  _Destination(
      'Marcador', Icons.emoji_events_outlined, Icons.emoji_events_rounded),
  _Destination('Ajustes', Icons.settings_outlined, Icons.settings_rounded),
];

/// Scaffold del shell: muestra la rama activa y la barra inferior del
/// mockup (Explorar · Configurar · Marcador · Ajustes) con indicador pill.
class AppShellScaffold extends StatelessWidget {
  const AppShellScaffold({super.key, required this.navigationShell});

  /// Lo entrega GoRouter: sabe qué rama está activa y cómo cambiar de rama
  /// conservando el estado de cada una.
  final StatefulNavigationShell navigationShell;

  void _onSelect(int index) {
    navigationShell.goBranch(
      index,
      // Tocar la tab activa vuelve a su pantalla raíz.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _BottomNav(
        currentIndex: navigationShell.currentIndex,
        onSelect: _onSelect,
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex, required this.onSelect});

  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.9),
        border: const Border(
          top: BorderSide(color: AppColors.surfaceContainerHighest),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.06),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 80,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (final (index, destination) in _destinations.indexed)
                  _NavItem(
                    destination: destination,
                    selected: index == currentIndex,
                    onTap: () => onSelect(index),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final _Destination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        selected ? AppColors.onPrimaryFixed : AppColors.onSurfaceVariant;
    final labelStyle = AppTheme.withWeight(
      Theme.of(context).textTheme.labelSmall!,
      selected ? FontWeight.w700 : FontWeight.w500,
    ).copyWith(color: color);

    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          constraints: const BoxConstraints(minWidth: 64),
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryFixed : Colors.transparent,
            borderRadius: AppRadius.inner,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                selected ? destination.activeIcon : destination.icon,
                size: 24,
                color: color,
              ),
              const SizedBox(height: 2),
              Text(destination.label, style: labelStyle),
            ],
          ),
        ),
      ),
    );
  }
}
