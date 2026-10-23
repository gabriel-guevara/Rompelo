import 'package:flutter/material.dart';

import '../constants/app_color.dart';
import '../constants/app_spacing.dart';
import '../theme/app_theme.dart';

/// Cuenta regresiva visual basada en un [AnimationController].
///
/// El controlador va de 0 a 1 en [duration]; el [builder] recibe el tiempo
/// restante y la fracción que queda (1 → 0) para dibujar lo que quiera.
/// Reiniciarla = darle una `key` nueva (p. ej. por turno): Flutter crea un
/// `State` nuevo y con él un controlador nuevo.
class CountdownBuilder extends StatefulWidget {
  const CountdownBuilder({
    super.key,
    required this.duration,
    required this.builder,
    this.running = true,
    this.onFinished,
  });

  final Duration duration;
  final Widget Function(
      BuildContext context, Duration remaining, double fraction) builder;

  /// `false` congela la cuenta (pausa o tests).
  final bool running;

  /// Se llama una sola vez cuando llega a cero.
  final VoidCallback? onFinished;

  @override
  State<CountdownBuilder> createState() => _CountdownBuilderState();
}

/// `SingleTickerProviderStateMixin` le da al controlador un `Ticker`
/// sincronizado con los frames de la pantalla (y que se silencia solo si la
/// ruta queda oculta).
class _CountdownBuilderState extends State<CountdownBuilder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..addStatusListener(_onStatus);

  @override
  void initState() {
    super.initState();
    if (widget.running) _controller.forward();
  }

  @override
  void didUpdateWidget(CountdownBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.running == oldWidget.running) return;
    // forward() continúa desde el valor actual: pausar y reanudar no
    // reinicia la cuenta.
    widget.running ? _controller.forward() : _controller.stop();
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) widget.onFinished?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // AnimatedBuilder redibuja solo este subárbol en cada tick, no la
    // pantalla entera (sería como un `useEffect` con requestAnimationFrame
    // que solo actualiza un componente hijo).
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final fraction = 1 - _controller.value;
        final remaining = widget.duration * fraction;
        return widget.builder(context, remaining, fraction);
      },
    );
  }
}

/// "0:38" (o "02:15" con [padMinutes]). Redondea hacia arriba: el reloj
/// muestra 0:01 hasta el último instante, como un cronómetro real.
String formatCountdown(Duration remaining, {bool padMinutes = false}) {
  final totalSeconds = (remaining.inMicroseconds / 1e6).ceil();
  final minutes = totalSeconds ~/ 60;
  final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
  return '${padMinutes ? minutes.toString().padLeft(2, '0') : minutes}:$seconds';
}

/// Estilos de la barra de tiempo de los mockups.
enum TimerBarStyle {
  /// Charadas: círculo con alarma, "Tiempo restante", cifra y barra.
  card,

  /// Trivia: cápsula compacta; bajo el umbral crítico cambia a
  /// "Tiempo crítico".
  compact,
}

/// Barra de tiempo de las partidas (`DESIGN.md`: el vino marca la tensión).
class TimerBar extends StatelessWidget {
  const TimerBar({
    super.key,
    required this.duration,
    this.style = TimerBarStyle.card,
    this.running = true,
    this.onFinished,
    this.criticalFraction = 1 / 3,
  });

  final Duration duration;
  final TimerBarStyle style;
  final bool running;
  final VoidCallback? onFinished;

  /// Por debajo de esta fracción el estilo compacto pasa a "Tiempo crítico".
  final double criticalFraction;

  @override
  Widget build(BuildContext context) {
    return CountdownBuilder(
      duration: duration,
      running: running,
      onFinished: onFinished,
      builder: (context, remaining, fraction) => switch (style) {
        TimerBarStyle.card =>
          _CardTimer(remaining: remaining, fraction: fraction),
        TimerBarStyle.compact => _CompactTimer(
            remaining: remaining,
            fraction: fraction,
            critical: fraction <= criticalFraction,
          ),
      },
    );
  }
}

class _CardTimer extends StatelessWidget {
  const _CardTimer({required this.remaining, required this.fraction});

  final Duration remaining;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.secondaryFixed,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: AppColors.secondaryFixedDim, offset: Offset(0, 3)),
              ],
            ),
            child: const Icon(Icons.alarm_rounded,
                size: 20, color: AppColors.secondary),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Tiempo restante',
                        style: textTheme.labelSmall
                            ?.copyWith(color: AppColors.outline),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      formatCountdown(remaining),
                      style: AppTheme.tabular(textTheme.headlineSmall!)
                          .copyWith(color: AppColors.secondary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                _Track(
                  fraction: fraction,
                  fill: const BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: AppRadius.pill,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactTimer extends StatelessWidget {
  const _CompactTimer({
    required this.remaining,
    required this.fraction,
    required this.critical,
  });

  final Duration remaining;
  final double fraction;
  final bool critical;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = critical ? AppColors.secondary : AppColors.primary;

    return Container(
      padding: const EdgeInsets.fromLTRB(4, 6, 4, 4),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.lg)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              children: [
                Icon(
                  critical
                      ? Icons.hourglass_bottom_rounded
                      : Icons.hourglass_top_rounded,
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    critical ? 'Tiempo crítico' : 'Tiempo restante',
                    style: AppTheme.withWeight(
                            textTheme.labelSmall!, FontWeight.w800)
                        .copyWith(color: color),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  formatCountdown(remaining),
                  style: AppTheme.tabular(AppTheme.withWeight(
                          textTheme.labelMedium!, FontWeight.w800))
                      .copyWith(color: color),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          _Track(
            fraction: fraction,
            fill: BoxDecoration(
              borderRadius: AppRadius.pill,
              gradient: critical
                  ? const LinearGradient(colors: [
                      AppColors.secondary,
                      AppColors.secondaryContainer,
                    ])
                  : null,
              color: critical ? null : AppColors.primaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

/// Riel de 12 px con el relleno proporcional al tiempo que queda.
class _Track extends StatelessWidget {
  const _Track({required this.fraction, required this.fill});

  final double fraction;
  final BoxDecoration fill;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 12,
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: AppRadius.pill,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        // FractionallySizedBox: el ancho es un % del padre, como `width: 63%`.
        child: FractionallySizedBox(
          widthFactor: fraction.clamp(0.0, 1.0),
          heightFactor: 1,
          child: DecoratedBox(decoration: fill),
        ),
      ),
    );
  }
}
