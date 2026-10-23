import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rompelo_app/core/theme/app_theme.dart';
import 'package:rompelo_app/core/widgets/timer_bar.dart';

Future<void> pumpTimer(WidgetTester tester, Widget timer) =>
    tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: timer),
    ));

void main() {
  test('formatCountdown redondea hacia arriba', () {
    expect(formatCountdown(const Duration(seconds: 60)), '1:00');
    expect(formatCountdown(const Duration(milliseconds: 38200)), '0:39');
    expect(formatCountdown(Duration.zero), '0:00');
    expect(formatCountdown(const Duration(seconds: 135), padMinutes: true),
        '02:15');
  });

  // Con el timer corriendo se usa `pump(duración)`: `pumpAndSettle`
  // esperaría hasta el final de la animación.
  testWidgets('cuenta hacia atrás y avisa al llegar a cero', (tester) async {
    var finished = 0;
    await pumpTimer(
      tester,
      TimerBar(
        duration: const Duration(seconds: 10),
        onFinished: () => finished++,
      ),
    );
    expect(find.text('0:10'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    expect(find.text('0:06'), findsOneWidget);
    expect(finished, 0);

    await tester.pump(const Duration(seconds: 6));
    expect(find.text('0:00'), findsOneWidget);
    // La simulación se da por terminada cuando el tiempo *supera* la
    // duración: el aviso llega en el frame siguiente.
    await tester.pump(const Duration(milliseconds: 16));
    expect(finished, 1);
  });

  testWidgets('el estilo compacto pasa a "Tiempo crítico"', (tester) async {
    await pumpTimer(
      tester,
      const TimerBar(
        duration: Duration(seconds: 15),
        style: TimerBarStyle.compact,
      ),
    );
    expect(find.text('Tiempo restante'), findsOneWidget);

    await tester.pump(const Duration(seconds: 11));
    expect(find.text('Tiempo crítico'), findsOneWidget);
    expect(find.text('0:04'), findsOneWidget);
  });

  testWidgets('con running: false no avanza', (tester) async {
    await pumpTimer(
      tester,
      const TimerBar(duration: Duration(seconds: 45), running: false),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5));
    expect(find.text('0:45'), findsOneWidget);
  });
}
