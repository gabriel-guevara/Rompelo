import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_color.dart';
import '../constants/app_spacing.dart';
import '../router/app_routes.dart';
import 'chunky_button.dart';
import '../../features/catalog/widgets/how_to_play.dart';
import 'chunky_pressable.dart';

/// Barra superior de las partidas: "Salir", badge "Partida en vivo" y las
/// reglas del juego (mockups `partida_*`). Reemplaza al `RompeloAppBar` del shell.
class LiveGameTopBar extends StatelessWidget implements PreferredSizeWidget {
  const LiveGameTopBar({super.key});

  static const double _height = 64;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: _height,
          padding: AppSpacing.screenPadding,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.surfaceContainerHighest),
            ),
          ),
          child: Row(
            children: [
              ChunkyPressable(
                onTap: () => exitMatchWithConfirmation(context),
                semanticLabel: 'Salir',
                builder: (context, pressed) => AnimatedContainer(
                  duration: kChunkyPressDuration,
                  constraints:
                      const BoxConstraints(minHeight: 48, minWidth: 48),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  transform: Matrix4.translationValues(0, pressed ? 2 : 0, 0),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: AppRadius.pill,
                    boxShadow:
                        chunkyShadow(AppColors.shadowTactile, pressed ? 0 : 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.close_rounded, size: 20),
                      const SizedBox(width: 4),
                      Text('Salir', style: textTheme.labelSmall),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryFixed,
                      borderRadius: AppRadius.pill,
                      boxShadow: chunkyShadow(AppColors.secondaryFixedDim, 2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined,
                            size: 18, color: AppColors.secondary),
                        const SizedBox(width: 4),
                        // DESIGN.md: nada en mayúsculas, ni "Partida En Vivo".
                        Flexible(
                          child: Text(
                            'Partida en vivo',
                            style: textTheme.labelLarge
                                ?.copyWith(color: AppColors.onSecondaryFixed),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Reglas del juego en curso (`/partida/:juego`).
              HowToPlayButton(
                gameId: GoRouterState.of(context).pathParameters['juego'],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pide confirmación y, si se acepta, vuelve a Explorar (`/`).
///
/// Pública porque también la usa el gesto "atrás" de Android (`PopScope`):
/// salir sin querer de una partida en plena fiesta sería frustrante.
Future<void> exitMatchWithConfirmation(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      // En horizontal (Charadas) la altura no alcanza: el diálogo desplaza.
      scrollable: true,
      icon: const Icon(Icons.logout_rounded, color: AppColors.secondary),
      title: const Text('¿Salir de la partida?'),
      content: const Text(
          'Se perderá el marcador de esta ronda y volverán al catálogo.'),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ChunkyButton(
              label: 'Sí, salir',
              height: 52,
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: AppSpacing.xs),
            ChunkyButton(
              label: 'Seguir jugando',
              height: 48,
              variant: ChunkyButtonVariant.ghost,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ],
    ),
  );
  if (confirmed == true && context.mounted) context.go(AppRoutes.explore);
}
