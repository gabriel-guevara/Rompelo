import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:rompelo_app/features/games/charades/tilt_detector.dart';

const double g = 9.8;

/// Simula el móvil inclinado [degrees] respecto a la vertical (0 = en la
/// frente, −90 = pantalla al piso) durante [ms] milisegundos.
TiltGesture? hold(TiltGestureRecognizer r, double degrees, int ms,
    {required List<int> clock, bool landscape = false}) {
  final rad = degrees * math.pi / 180;
  final z = g * math.sin(rad);
  final planar = g * math.cos(rad);
  TiltGesture? result;
  for (var t = 0; t < ms; t += 20) {
    clock[0] += 20;
    final gesture = r.add(landscape ? planar : 0, landscape ? 0 : planar, z,
        Duration(milliseconds: clock[0]));
    result ??= gesture;
  }
  return result;
}

void main() {
  test('no dispara hasta pasar por la frente (neutro)', () {
    final r = TiltGestureRecognizer();
    final clock = [0];
    // Turno empieza con el móvil boca arriba en la mano.
    expect(hold(r, 80, 500, clock: clock), isNull);
  });

  test('abajo = acierto, arriba = pasar, con vuelta a neutro', () {
    final r = TiltGestureRecognizer();
    final clock = [0];
    hold(r, 0, 300, clock: clock);
    expect(hold(r, -70, 400, clock: clock), TiltGesture.down);
    // Sigue abajo: no repite.
    expect(hold(r, -70, 1000, clock: clock), isNull);
    hold(r, 0, 400, clock: clock);
    expect(hold(r, 70, 400, clock: clock), TiltGesture.up);
  });

  test('funciona igual en horizontal', () {
    final r = TiltGestureRecognizer();
    final clock = [0];
    hold(r, 0, 300, clock: clock, landscape: true);
    expect(hold(r, -70, 400, clock: clock, landscape: true), TiltGesture.down);
  });

  test('un pico corto (sacudida) no cuenta', () {
    final r = TiltGestureRecognizer();
    final clock = [0];
    hold(r, 0, 300, clock: clock);
    // Un solo pico enorme en z, como un golpe al actuar.
    clock[0] += 20;
    expect(r.add(0, g, -30, Duration(milliseconds: clock[0])), isNull);
    expect(hold(r, 0, 200, clock: clock), isNull);
  });

  test('inclinación leve no dispara; ~35° sí', () {
    final r = TiltGestureRecognizer();
    final clock = [0];
    hold(r, 0, 300, clock: clock);
    expect(hold(r, -20, 1000, clock: clock), isNull);
    expect(hold(r, -38, 400, clock: clock), TiltGesture.down);
  });

  test('se calibra con el móvil algo inclinado en la frente', () {
    final r = TiltGestureRecognizer();
    final clock = [0];
    // Cabeza echada atrás: la pantalla mira 20° hacia arriba.
    hold(r, 20, 400, clock: clock);
    expect(r.baseline, closeTo(20, 1));
    // 40° es solo +20 respecto a la base: no es "Pasar".
    expect(hold(r, 40, 600, clock: clock), isNull);
    // −15° son 35° hacia abajo desde la base: Acierto.
    expect(hold(r, -15, 400, clock: clock), TiltGesture.down);
  });

  test('acomodarse el móvil desde la mano no dispara', () {
    final r = TiltGestureRecognizer();
    final clock = [0];
    // Leyendo en la mano (boca arriba) y luego a la frente.
    hold(r, 70, 400, clock: clock);
    hold(r, 24, 100, clock: clock);
    expect(hold(r, 0, 600, clock: clock), isNull);
  });
}
