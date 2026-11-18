import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/feedback/game_feedback.dart';
import '../../../core/feedback/keep_screen_on.dart';
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
    this.fill = false,
    this.maxWidth = AppSpacing.maxContentWidth,
  });

  final List<Widget> children;

  /// Botones que quedan fijos abajo (DESIGN.md › Vertical Rhythm).
  final Widget? bottom;

  /// `true`: los [children] van en una columna que ocupa todo el alto (sin
  /// desplazamiento) y pueden usar `Expanded`. Para pantallas que deben
  /// verse completas de un vistazo, como Charadas en horizontal.
  final bool fill;

  /// Ancho máximo del contenido (540 en vertical; más en horizontal).
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    // PopScope intercepta el "atrás" del sistema (Android) para pedir la
    // misma confirmación que el botón "Salir".
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) exitMatchWithConfirmation(context);
      },
      child: KeepScreenOn(
        child: Scaffold(
          appBar: const LiveGameTopBar(),
          // SafeArea lateral: en horizontal el notch queda a un costado.
          body: SafeArea(
            top: false,
            bottom: fill && bottom == null,
            child: fill
                ? Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.margin,
                            AppSpacing.sm, AppSpacing.margin, AppSpacing.sm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: children,
                        ),
                      ),
                    ),
                  )
                : _constrained(
                    maxWidth,
                    ListView(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.margin,
                          AppSpacing.sm, AppSpacing.margin, AppSpacing.lg),
                      children: children,
                    ),
                  ),
          ),
          bottomNavigationBar: bottom == null
              ? null
              : SafeArea(
                  child: _constrained(
                    maxWidth,
                    Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.margin, 0,
                          AppSpacing.margin, AppSpacing.md),
                      child: bottom,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  /// Centra y limita el ancho (540 px por defecto: modo tablet / mesa).
  static Widget _constrained(double maxWidth, Widget child) => Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      );
}

/// Guarda el resultado en [lastMatchResultProvider] y abre el marcador.
///
/// Se usa `go` (no `push`): la partida terminada no debe quedar en el
/// historial para que "atrás" no regrese a ella.
void finishMatch(BuildContext context, WidgetRef ref, MatchResult result) {
  ref.read(gameFeedbackProvider).both(GameSound.win, Haptic.heavy);
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
