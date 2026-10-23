/// Rutas de la app como constantes (evita "strings mágicos" repetidos).
///
/// Separado de `app_router.dart` para que cualquier capa (p. ej. el catálogo)
/// pueda construir rutas sin depender de la configuración de GoRouter.
abstract final class AppRoutes {
  // Ramas del shell (bottom nav).
  static const String explore = '/';
  static const String configure = '/configurar';
  static const String results = '/resultados';
  static const String settings = '/ajustes';

  // Rutas con parámetro `:juego` (id del catálogo: charadas, trivia, impostor).
  static const String gameParam = 'juego';
  static const String play = '/partida';

  static String configureGame(String gameId) => '$configure/$gameId';
  static String playGame(String gameId) => '$play/$gameId';
}
