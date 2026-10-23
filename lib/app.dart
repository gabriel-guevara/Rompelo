import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// Widget raíz: conecta el tema y el router.
///
/// Es `ConsumerWidget` (la versión Riverpod de `StatelessWidget`) para poder
/// leer el router desde un provider con `ref.watch`.
class RompeloApp extends ConsumerWidget {
  const RompeloApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Rómpelo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
