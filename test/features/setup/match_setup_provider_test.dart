import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rompelo_app/features/setup/domain/match_setup.dart';
import 'package:rompelo_app/features/setup/providers/match_setup_provider.dart';
import 'package:rompelo_app/features/setup/providers/player_count_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  test('toma los jugadores del selector mágico como valor inicial', () {
    container.read(playerCountProvider.notifier).set(9);
    expect(container.read(triviaSetupProvider).players, 9);
    // El impostor admite 4-10: 9 cabe.
    expect(container.read(impostorSetupProvider).players, 9);
  });

  test('sigue los cambios del home sin perder el resto de ajustes', () {
    final charades = container.read(charadesSetupProvider.notifier);
    charades.setTurnSeconds(90);
    charades.toggleDeck('mimica');

    container.read(playerCountProvider.notifier).set(10);

    final setup = container.read(charadesSetupProvider);
    expect(setup.players, 10);
    expect(setup.turnSeconds, 90);
    expect(setup.selectedDecks, contains('mimica'));
  });

  test('cambiar jugadores en la config no modifica el home', () {
    container.read(impostorSetupProvider.notifier).setPlayers(4);
    expect(container.read(impostorSetupProvider).players, 4);
    expect(container.read(playerCountProvider), PlayerCountNotifier.initial);
  });

  test('seleccionar mazos respeta el mínimo de cada juego', () {
    final trivia = container.read(triviaSetupProvider.notifier);
    // Arranca con {'animales', 'mundo', 'cine_familia'}.
    expect(trivia.toggleDeck('espacio'), isTrue);
    expect(container.read(triviaSetupProvider).selectedDecks, hasLength(4));

    // Quita hasta quedar en 2; el tercero ya no se puede quitar.
    expect(trivia.toggleDeck('espacio'), isTrue);
    expect(trivia.toggleDeck('animales'), isTrue);
    expect(trivia.toggleDeck('mundo'), isFalse);
    expect(container.read(triviaSetupProvider).selectedDecks,
        {'mundo', 'cine_familia'});
  });

  test('las mezclas rápidas no bajan del mínimo', () {
    final trivia = container.read(triviaSetupProvider.notifier);
    expect(trivia.setDecks({'vf'}), isFalse);
    expect(trivia.setDecks({'mates', 'inventos', 'vf'}), isTrue);
    expect(container.read(triviaSetupProvider).selectedDecks,
        {'mates', 'inventos', 'vf'});
  });

  test('dos impostores solo con grupos grandes', () {
    final impostor = container.read(impostorSetupProvider.notifier);
    impostor.setPlayers(5);
    expect(impostor.setImpostors(2), isFalse);
    impostor.setPlayers(7);
    expect(impostor.setImpostors(2), isTrue);
    expect(container.read(impostorSetupProvider).impostors, 2);
  });

  test('renombrar jugadores y equipos', () {
    final charades = container.read(charadesSetupProvider.notifier);
    charades.renamePlayer(0, 'Gabo');
    charades.renameTeam(1, 'Los Pulpos');

    final setup = container.read(charadesSetupProvider);
    expect(setup.playerNames.first, 'Gabo');
    expect(setup.teamNames, ['Team Vino', 'Los Pulpos']);
  });

  test('matchSetupProvider devuelve la config tipada de cada juego', () {
    expect(
        container.read(matchSetupProvider('charadas')), isA<CharadesSetup>());
    expect(container.read(matchSetupProvider('trivia')), isA<TriviaSetup>());
    expect(
        container.read(matchSetupProvider('impostor')), isA<ImpostorSetup>());
  });
}
