import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/live_game_top_bar.dart';
import '../providers/match_result_provider.dart';

/// Esqueleto común de las 3 partidas: [LiveGameTopBar], contenido
/// desplazable con ancho máximo y, opcional, acciones fijas en la zona del
/// pulgar ([bottom]). Es un *layout* compartido, igual que `ConfigScaffold`.
class LiveGameScaffold extends StatelessWidget {
  const LiveGameScaffold({
    super.key,
    required this.children,
    this.bottom,
  });

  final List<Widget> children;

  /// Botones que quedan fijos abajo (DESIGN.md › Vertical Rhythm).
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    // PopScope intercepta el "atrás" del sistema (Android) para pedir la
    // misma confirmación que el botón "Salir".
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) exitMatchWithConfirmation(context);
      },
      child: Scaffold(
        appBar: const LiveGameTopBar(),
        body: _constrained(
          ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.margin, AppSpacing.sm,
                AppSpacing.margin, AppSpacing.lg),
            children: children,
          ),
        ),
        bottomNavigationBar: bottom == null
            ? null
            : SafeArea(
                child: _constrained(
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.margin, 0, AppSpacing.margin, AppSpacing.md),
                    child: bottom,
                  ),
                ),
              ),
      ),
    );
  }

  /// Centra y limita a 540 px (modo tablet / mesa).
  static Widget _constrained(Widget child) => Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
          child: child,
        ),
      );
}

/// Guarda el resultado en [lastMatchResultProvider] y abre el marcador.
///
/// Se usa `go` (no `push`): la partida terminada no debe quedar en el
/// historial para que "atrás" no regrese a ella.
void finishMatch(BuildContext context, WidgetRef ref, MatchResult result) {
  ref.read(lastMatchResultProvider.notifier).save(result);
  context.go(AppRoutes.results);
}

/// Muestra un aviso breve; reemplaza el anterior para no encolar varios.
void showGameMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ));
}
