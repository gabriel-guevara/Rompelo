import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/providers/app_settings_provider.dart';

/// Efectos de sonido de la app (archivos en `assets/sounds/`).
enum GameSound {
  correct,
  pass,
  countdown,
  timeUp('time_up'),
  reveal,
  win,
  tap;

  const GameSound([this._file]);

  final String? _file;

  String get asset => 'sounds/${_file ?? name}.wav';
}

/// Intensidad de la vibración.
enum Haptic { light, medium, heavy, selection }

/// Reproductor de sonidos. Es una interfaz para que los tests usen uno
/// silencioso (en el entorno de test no hay audio).
abstract interface class SoundPlayer {
  void play(GameSound sound);
}

class AudioSoundPlayer implements SoundPlayer {
  /// Un reproductor por sonido, en modo baja latencia (efectos cortos).
  final Map<GameSound, AudioPlayer> _players = {};

  @override
  void play(GameSound sound) {
    final player = _players.putIfAbsent(sound, () {
      return AudioPlayer()
        ..setPlayerMode(PlayerMode.lowLatency)
        ..setReleaseMode(ReleaseMode.stop);
    });
    // Sin `await`: el juego no espera al audio. Un error de audio nunca
    // debe romper la partida.
    player.stop().then((_) => player.play(AssetSource(sound.asset))).catchError(
          (Object _) {},
        );
  }

  void dispose() {
    for (final p in _players.values) {
      p.dispose();
    }
  }
}

class SilentSoundPlayer implements SoundPlayer {
  const SilentSoundPlayer();

  @override
  void play(GameSound sound) {}
}

final soundPlayerProvider = Provider<SoundPlayer>((ref) {
  final player = AudioSoundPlayer();
  ref.onDispose(player.dispose);
  return player;
});

/// Punto único para sonidos y vibración de las partidas: respeta los
/// ajustes "Sonidos" y "Vibración" de la pestaña Ajustes.
class GameFeedback {
  GameFeedback(this._ref);

  final Ref _ref;

  AppSettings get _settings => _ref.read(appSettingsProvider);

  void sound(GameSound sound) {
    if (_settings.sounds) _ref.read(soundPlayerProvider).play(sound);
  }

  void vibrate(Haptic haptic) {
    if (!_settings.vibration) return;
    switch (haptic) {
      case Haptic.light:
        HapticFeedback.lightImpact();
      case Haptic.medium:
        HapticFeedback.mediumImpact();
      case Haptic.heavy:
        HapticFeedback.heavyImpact();
      case Haptic.selection:
        HapticFeedback.selectionClick();
    }
  }

  /// Sonido + vibración juntos (lo más común en las partidas).
  void both(GameSound sound, Haptic haptic) {
    this.sound(sound);
    vibrate(haptic);
  }
}

final gameFeedbackProvider = Provider<GameFeedback>(GameFeedback.new);
