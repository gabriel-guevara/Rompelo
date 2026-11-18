import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'features/settings/providers/app_settings_provider.dart';

Future<void> main() async {
  // Necesario para usar plugins (almacenamiento local) antes de runApp.
  WidgetsFlutterBinding.ensureInitialized();

  // Lectura local y rápida (no hay red): los ajustes guardados quedan
  // disponibles desde el primer frame.
  final prefs = await SharedPreferences.getInstance();

  // ProviderScope guarda el estado de todos los providers de Riverpod;
  // debe envolver la app completa.
  runApp(ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    child: const RompeloApp(),
  ));
}
