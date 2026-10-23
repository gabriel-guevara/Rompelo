import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/catalog/data/games_catalog.dart';
import '../../features/catalog/presentation/home_screen.dart';
import '../../features/games/presentation/play_placeholder_screen.dart';
import '../../features/results/presentation/results_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/setup/presentation/configure_tab_screen.dart';
import '../widgets/app_shell_scaffold.dart';
import 'app_routes.dart';

/// Expone el router como provider: cada `ProviderScope` (la app o un test)
/// obtiene su propia instancia, sin estado compartido entre tests.
final appRouterProvider = Provider<GoRouter>((ref) {
  final router = createAppRouter();
  ref.onDispose(router.dispose);
  return router;
});

/// Redirige a Explorar si `:juego` no existe en el catálogo.
String? _redirectUnknownGame(BuildContext context, GoRouterState state) {
  final id = state.pathParameters[AppRoutes.gameParam];
  return id == null || gameById(id) == null ? AppRoutes.explore : null;
}

/// Construye el árbol de rutas.
///
/// - Las 4 tabs viven en un `StatefulShellRoute.indexedStack`: cada rama
///   tiene su propio `Navigator` y conserva su estado al cambiar de tab.
/// - `/partida/:juego` cuelga del navigator raíz, así se pinta encima del
///   shell a pantalla completa (sin bottom nav).
GoRouter createAppRouter() {
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.explore,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShellScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.explore,
              builder: (context, state) => const HomeScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.configure,
              builder: (context, state) => const ConfigureTabScreen(),
              routes: [
                GoRoute(
                  path: ':${AppRoutes.gameParam}',
                  redirect: _redirectUnknownGame,
                  builder: (context, state) => GameConfigPlaceholderScreen(
                    game: gameById(state.pathParameters[AppRoutes.gameParam]!)!,
                  ),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.results,
              builder: (context, state) => const ResultsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.settings,
              builder: (context, state) => const SettingsScreen(),
            ),
          ]),
        ],
      ),
      GoRoute(
        path: '${AppRoutes.play}/:${AppRoutes.gameParam}',
        parentNavigatorKey: rootNavigatorKey,
        redirect: _redirectUnknownGame,
        builder: (context, state) => PlayPlaceholderScreen(
          game: gameById(state.pathParameters[AppRoutes.gameParam]!)!,
        ),
      ),
    ],
  );
}
