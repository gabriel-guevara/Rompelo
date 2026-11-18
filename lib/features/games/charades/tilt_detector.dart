import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Gesto reconocido por [TiltGestureRecognizer].
enum TiltGesture {
  /// La pantalla mira al piso → Acierto.
  down,

  /// La pantalla mira al techo → Pasar.
  up,
}

/// Lógica pura del gesto de Charadas (sin sensores, para poder testearla).
///
/// Con el móvil en la frente la pantalla queda vertical. En vez de mirar el
/// valor crudo de `z` (que salta con cada sacudida al actuar o caminar), se
/// calcula el **ángulo de la pantalla respecto a la vertical** a partir de la
/// gravedad filtrada:
///
/// `ángulo = atan2(z, √(x² + y²))`
///
/// - 0° → pantalla vertical (en la frente, posición neutra).
/// - −90° → pantalla hacia el piso. +90° → pantalla hacia el techo.
///
/// El ángulo no depende de si el móvil está en vertical u horizontal ni de la
/// fuerza del movimiento, solo de la inclinación. Además:
///
/// - Un filtro paso bajo suaviza los picos de aceleración.
/// - **Calibración:** nadie se pone el móvil perfectamente vertical. La
///   posición "en la frente" se toma como referencia (base) cuando el móvil
///   se queda quieto cerca de la vertical ([armDegrees] durante [armTime]),
///   y los gestos se miden respecto a ella. La base sigue despacio los
///   pequeños cambios de postura mientras está en neutro.
/// - El ángulo tiene que mantenerse pasado el umbral [holdTime] para contar.
/// - Tras un gesto hay que volver cerca de la base (< [neutralDegrees]) para
///   que cuente el siguiente.
class TiltGestureRecognizer {
  TiltGestureRecognizer({
    this.triggerDegrees = 30,
    this.neutralDegrees = 15,
    this.armDegrees = 25,
    this.armTime = const Duration(milliseconds: 250),
    this.holdTime = const Duration(milliseconds: 80),
    this.cooldown = const Duration(milliseconds: 500),
    this.smoothing = 0.3,
  });

  /// Inclinación (respecto a la base) necesaria para disparar el gesto.
  final double triggerDegrees;

  /// Distancia a la base por debajo de la cual se considera "en la frente".
  final double neutralDegrees;

  /// Para fijar la base al empezar, el móvil debe estar a menos de esto de
  /// la vertical. Es menor que [triggerDegrees]: así acomodarse el móvil en
  /// la frente nunca dispara un gesto.
  final double armDegrees;

  /// Tiempo que el móvil debe quedarse quieto para fijar la base.
  final Duration armTime;

  /// Tiempo que hay que sostener la inclinación.
  final Duration holdTime;

  /// Tiempo mínimo entre dos gestos.
  final Duration cooldown;

  /// Peso de cada muestra nueva en el filtro (0–1; menor = más suave).
  final double smoothing;

  double? _x, _y, _z;

  /// Ángulo de referencia "en la frente"; `null` hasta calibrar.
  double? _baseline;
  Duration? _steadySince;

  /// `false` hasta que el móvil vuelve a la base tras un gesto.
  bool _armed = false;
  TiltGesture? _pending;
  Duration? _pendingSince;
  Duration? _lastGesture;

  /// Base actual (grados) o `null` si aún no se calibró.
  double? get baseline => _baseline;

  /// Ángulo actual (grados) tras el filtro; útil para depurar.
  double get angle {
    final x = _x, y = _y, z = _z;
    if (x == null || y == null || z == null) return 0;
    return math.atan2(z, math.sqrt(x * x + y * y)) * 180 / math.pi;
  }

  void reset() {
    _x = _y = _z = null;
    _baseline = null;
    _steadySince = null;
    _armed = false;
    _pending = null;
    _pendingSince = null;
  }

  /// Procesa una muestra del acelerómetro tomada en [time] (cualquier reloj
  /// monótono). Devuelve el gesto si se acaba de completar.
  TiltGesture? add(double x, double y, double z, Duration time) {
    if (_x == null) {
      _x = x;
      _y = y;
      _z = z;
    } else {
      _x = _x! + smoothing * (x - _x!);
      _y = _y! + smoothing * (y - _y!);
      _z = _z! + smoothing * (z - _z!);
    }

    final a = angle;

    // 1) Calibración: esperar al móvil quieto cerca de la vertical.
    final base = _baseline;
    if (base == null) {
      if (a.abs() >= armDegrees) {
        _steadySince = null;
        return null;
      }
      _steadySince ??= time;
      if (time - _steadySince! >= armTime) {
        _baseline = a;
        _armed = true;
      }
      return null;
    }

    // 2) Neutro: re-armar y seguir despacio la postura.
    final rel = a - base;
    if (rel.abs() < neutralDegrees) {
      _armed = true;
      _pending = null;
      _baseline = base + 0.02 * rel;
      return null;
    }
    if (!_armed) return null;

    final candidate = rel <= -triggerDegrees
        ? TiltGesture.down
        : rel >= triggerDegrees
            ? TiltGesture.up
            : null;
    if (candidate == null) {
      _pending = null;
      return null;
    }
    if (_pending != candidate) {
      _pending = candidate;
      _pendingSince = time;
    }
    final last = _lastGesture;
    if (last != null && time - last < cooldown) return null;
    if (time - _pendingSince! < holdTime) return null;

    _armed = false;
    _pending = null;
    _lastGesture = time;
    return candidate;
  }
}

/// Detecta el gesto de Charadas con el móvil en la frente (pantalla hacia
/// el grupo) usando el acelerómetro: inclinar hacia abajo → [onDown]
/// (Acierto), hacia arriba → [onUp] (Pasar). Ver [TiltGestureRecognizer].
class TiltDetector extends StatefulWidget {
  const TiltDetector({
    super.key,
    required this.enabled,
    required this.onDown,
    required this.onUp,
    required this.child,
  });

  /// Solo escucha el sensor mientras es `true` (fase de juego, sin pausa).
  final bool enabled;
  final VoidCallback onDown;
  final VoidCallback onUp;
  final Widget child;

  @override
  State<TiltDetector> createState() => _TiltDetectorState();
}

class _TiltDetectorState extends State<TiltDetector> {
  StreamSubscription<AccelerometerEvent>? _subscription;
  final TiltGestureRecognizer _recognizer = TiltGestureRecognizer();
  final Stopwatch _clock = Stopwatch()..start();

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(TiltDetector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled) _sync();
  }

  void _sync() {
    if (widget.enabled && _subscription == null) {
      _recognizer.reset();
      _subscription = accelerometerEventStream(
        samplingPeriod: SensorInterval.gameInterval,
      ).listen(
        _onEvent,
        // Sin acelerómetro (emulador, algunos equipos): quedan los botones.
        onError: (Object _) => _stop(),
        cancelOnError: true,
      );
    } else if (!widget.enabled) {
      _stop();
    }
  }

  void _stop() {
    _subscription?.cancel();
    _subscription = null;
  }

  void _onEvent(AccelerometerEvent event) {
    final gesture =
        _recognizer.add(event.x, event.y, event.z, _clock.elapsed);
    switch (gesture) {
      case TiltGesture.down:
        widget.onDown();
      case TiltGesture.up:
        widget.onUp();
      case null:
        break;
    }
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
