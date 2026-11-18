import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferencias de la app. Se guardan en el teléfono (`shared_preferences`)
/// y las lee `GameFeedback` (sonidos y vibración) y `KeepScreenOn`.
@immutable
class AppSettings {
  const AppSettings({
    this.sounds = true,
    this.vibration = true,
    this.keepScreenOn = true,
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

/// Almacén local. `main()` lo carga antes de arrancar la app; si es `null`
/// (tests), los ajustes solo viven en memoria.
final sharedPreferencesProvider = Provider<SharedPreferences?>((ref) => null);

class AppSettingsNotifier extends Notifier<AppSettings> {
  static const _soundsKey = 'settings.sounds';
  static const _vibrationKey = 'settings.vibration';
  static const _keepScreenOnKey = 'settings.keepScreenOn';

  SharedPreferences? get _prefs => ref.read(sharedPreferencesProvider);

  @override
  AppSettings build() {
    const defaults = AppSettings();
    final prefs = _prefs;
    if (prefs == null) return defaults;
    return AppSettings(
      sounds: prefs.getBool(_soundsKey) ?? defaults.sounds,
      vibration: prefs.getBool(_vibrationKey) ?? defaults.vibration,
      keepScreenOn: prefs.getBool(_keepScreenOnKey) ?? defaults.keepScreenOn,
    );
  }

  void setSounds(bool value) {
    state = state.copyWith(sounds: value);
    _prefs?.setBool(_soundsKey, value);
  }

  void setVibration(bool value) {
    state = state.copyWith(vibration: value);
    _prefs?.setBool(_vibrationKey, value);
  }

  void setKeepScreenOn(bool value) {
    state = state.copyWith(keepScreenOn: value);
    _prefs?.setBool(_keepScreenOnKey, value);
  }
}

final appSettingsProvider =
    NotifierProvider<AppSettingsNotifier, AppSettings>(AppSettingsNotifier.new);
