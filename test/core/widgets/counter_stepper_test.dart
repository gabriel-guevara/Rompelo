import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rompelo_app/core/theme/app_theme.dart';
import 'package:rompelo_app/core/widgets/counter_stepper.dart';

/// Envuelve el stepper con estado propio, como lo usaría una pantalla real.
class _Host extends StatefulWidget {
  const _Host({required this.initial, required this.min, required this.max});

  final int initial;
  final int min;
  final int max;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late int value = widget.initial;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Center(
          child: CounterStepper(
            value: value,
            min: widget.min,
            max: widget.max,
            onChanged: (v) => setState(() => value = v),
          ),
        ),
      ),
    );
  }
}

void main() {
  final minus = find.byKey(const ValueKey('stepper-minus'));
  final plus = find.byKey(const ValueKey('stepper-plus'));

  testWidgets('incrementa y decrementa', (tester) async {
    await tester.pumpWidget(const _Host(initial: 6, min: 2, max: 24));

    await tester.tap(plus);
    await tester.pump();
    expect(find.text('7'), findsOneWidget);

    // pump() entre toques: el stepper es controlado y necesita reconstruirse
    // con el nuevo `value` antes del siguiente toque.
    await tester.tap(minus);
    await tester.pump();
    await tester.tap(minus);
    await tester.pump();
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('no baja del mínimo ni sube del máximo', (tester) async {
    await tester.pumpWidget(const _Host(initial: 2, min: 2, max: 3));

    await tester.tap(minus);
    await tester.pump();
    expect(find.text('2'), findsOneWidget);

    await tester.tap(plus);
    await tester.pump();
    await tester.tap(plus);
    await tester.pump();
    expect(find.text('3'), findsOneWidget);
  });
}
