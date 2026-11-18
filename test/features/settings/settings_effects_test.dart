import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rompelo_app/core/feedback/game_feedback.dart';
import 'package:rompelo_app/features/settings/providers/app_settings_provider.dart';
import 'package:rompelo_app/features/setup/domain/match_setup.dart';
import 'package:rompelo_app/features/setup/providers/match_setup_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../test_utils.dart';

/// Guarda qué sonidos se pidieron reproducir.
class _RecordingPlayer implements SoundPlayer {
  final List<GameSound> played = [];

  @override
  void play(GameSound sound) => played.add(sound);
}

void main() {
  test('los ajustes se guardan en el teléfono y se recuperan', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final first = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]);
    first.read(appSettingsProvider.notifier)
      ..setSounds(false)
      ..setKeepScreenOn(false);
    first.dispose();

    // "Reabrir la app": un contenedor nuevo lee lo guardado.
    final second = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]);
    addTearDown(second.dispose);
    final settings = second.read(appSettingsProvider);
    expect(settings.sounds, isFalse);
    expect(settings.keepScreenOn, isFalse);
    expect(settings.vibration, isTrue);
  });

  test('con "Sonidos" apagado no se reproduce nada', () {
    final player = _RecordingPlayer();
    final container = ProviderContainer(
        overrides: [soundPlayerProvider.overrideWithValue(player)]);
    addTearDown(container.dispose);
    final fx = container.read(gameFeedbackProvider);

    fx.sound(GameSound.correct);
    expect(player.played, [GameSound.correct]);

    container.read(appSettingsProvider.notifier).setSounds(false);
    fx.sound(GameSound.timeUp);
    expect(player.played, [GameSound.correct]);
  });

  testWidgets('la pantalla queda encendida solo durante la partida',
      (tester) async {
    final calls = <bool>[];
    final container = await pumpAppAt(tester, '/partida/charadas',
        screenWake: calls.add);
    expect(calls, [true]);

    // Al apagar el ajuste se libera en el momento.
    container.read(appSettingsProvider.notifier).setKeepScreenOn(false);
    await tester.pump();
    expect(calls, [true, false]);
  });

  testWidgets('Trivia: nombres de equipos o de jugadores según el modo',
      (tester) async {
    final container = await pumpAppAt(tester, '/configurar/trivia');

    // Pulsador (por defecto): dos equipos editables.
    expect(find.text('Nombres de los equipos'), findsOneWidget);
    await tester.enterText(
        find.descendant(
            of: find.byKey(const ValueKey('team-name-0')),
            matching: find.byType(EditableText)),
        'Los Genios');
    expect(container.read(triviaSetupProvider).teamNames.first, 'Los Genios');

    container
        .read(triviaSetupProvider.notifier)
        .setAnswerMode(TriviaAnswerMode.turns);
    await tester.pumpAndSettle();
    expect(find.text('Nombres de jugadores'), findsOneWidget);
    expect(find.byKey(const ValueKey('player-chip-0')), findsOneWidget);
  });

  test('un nombre borrado no deja huecos en el marcador', () {
    expect(displayTeamNames(['', 'Burbujas']), ['Equipo A', 'Burbujas']);
    expect(displayPlayerNames(['Ana', '  ']), ['Ana', 'Jugador 2']);
  });
}
