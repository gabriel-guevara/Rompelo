import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Preferencias de la app (mock: todavía no hay sonidos ni vibración reales,
/// pero la UI ya guarda la elección para conectarla después).
@immutable
class AppSettings {
  const AppSettings({
    this.sounds = true,
    this.vibration = true,
    this.keepScreenOn = false,
  });

  final bool sounds;
  final bool vibration;

  /// Evitar que la pantalla se apague durante la partida.
  final bool keepScreenOn;

  AppSettings copyWith({bool? sounds, bool? vibration, bool? keepScreenOn}) {
    return AppSettings(
      sounds: sounds ?? this.sounds,
      vibration: vibration ?? this.vibration,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
    );
  }
}

class AppSettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => const AppSettings();

  void setSounds(bool value) => state = state.copyWith(sounds: value);
  void setVibration(bool value) => state = state.copyWith(vibration: value);
  void setKeepScreenOn(bool value) =>
      state = state.copyWith(keepScreenOn: value);
}

final appSettingsProvider =
    NotifierProvider<AppSettingsNotifier, AppSettings>(AppSettingsNotifier.new);
