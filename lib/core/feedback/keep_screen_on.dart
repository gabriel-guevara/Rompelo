import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../features/settings/providers/app_settings_provider.dart';

/// Enciende/apaga el bloqueo de suspensión de pantalla. Es un provider para
/// que los tests lo reemplacen (no hay plugin nativo en el entorno de test).
final screenWakeProvider = Provider<void Function(bool on)>(
  (ref) => (on) => WakelockPlus.toggle(enable: on).catchError((Object _) {}),
);

/// Mientras este widget está en pantalla (una partida) y el ajuste
/// "Pantalla siempre encendida" está activo, el teléfono no se apaga solo.
/// Al salir de la partida se libera.
class KeepScreenOn extends ConsumerStatefulWidget {
  const KeepScreenOn({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<KeepScreenOn> createState() => _KeepScreenOnState();
}

class _KeepScreenOnState extends ConsumerState<KeepScreenOn> {
  late final void Function(bool on) _setWake = ref.read(screenWakeProvider);
  bool _on = false;

  void _apply(bool on) {
    if (on == _on) return;
    _on = on;
    _setWake(on);
  }

  @override
  void dispose() {
    _apply(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // `watch`: si el ajuste cambia, se aplica al momento.
    _apply(ref.watch(appSettingsProvider.select((s) => s.keepScreenOn)));
    return widget.child;
  }
}
