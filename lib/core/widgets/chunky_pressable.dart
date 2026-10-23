import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Base táctil del estilo "chunky": detecta si el dedo está presionando y le
/// pasa ese estado a [builder] para que el widget dibuje su versión hundida.
///
/// Centralizar aquí el gesto evita repetir la misma lógica en botones,
/// chips, tiles y steppers (DRY), y también la accesibilidad: el área
/// táctil mínima y la etiqueta para lectores de pantalla se arreglan en un
/// solo lugar.
class ChunkyPressable extends StatefulWidget {
  const ChunkyPressable({
    super.key,
    required this.onTap,
    required this.builder,
    this.semanticLabel,
    this.selected,
  });

  /// `null` deshabilita el control (no reacciona ni se hunde).
  final VoidCallback? onTap;
  final Widget Function(BuildContext context, bool pressed) builder;
  final String? semanticLabel;
  final bool? selected;

  @override
  State<ChunkyPressable> createState() => _ChunkyPressableState();
}

class _ChunkyPressableState extends State<ChunkyPressable> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final hasLabel = widget.semanticLabel != null;
    return Semantics(
      button: true,
      enabled: enabled,
      selected: widget.selected,
      label: widget.semanticLabel,
      // Con etiqueta propia se ignoran los textos hijos: si no, el lector
      // de pantalla diría "Por equipos, Por equipos". Al excluirlos también
      // se pierde la acción del GestureDetector, por eso se repite `onTap`.
      excludeSemantics: hasLabel,
      onTap: hasLabel ? widget.onTap : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _setPressed(true) : null,
        onTapUp: enabled ? (_) => _setPressed(false) : null,
        onTapCancel: enabled ? () => _setPressed(false) : null,
        onTap: widget.onTap,
        // Área táctil mínima de 48 × 48 (guía de Android / Material) sin
        // agrandar el dibujo: un stepper de 40 px se ve igual pero acepta
        // toques en 48.
        child: _MinTapArea(
          child: widget.builder(context, enabled && _pressed),
        ),
      ),
    );
  }
}

/// Duración común de la animación de "hundirse".
const Duration kChunkyPressDuration = Duration(milliseconds: 90);

/// Sombra sólida inferior (sin blur) del sistema de diseño.
List<BoxShadow> chunkyShadow(Color color, double depth) => [
      BoxShadow(color: color, offset: Offset(0, depth)),
    ];

/// Garantiza un área de al menos [kMinInteractiveDimension] (48 px) por eje
/// **sin cambiar cómo se dibuja ni cómo se mide el hijo**.
///
/// Un `ConstrainedBox` + `Align` también llega a 48, pero `Align` afloja las
/// restricciones: un hijo sin ancho propio dentro de un `Expanded` dejaba de
/// estirarse (los botones "Pasar" / "¡Acierto!" se encogían). Aquí el hijo
/// recibe exactamente las restricciones del padre; solo esta caja crece
/// alrededor y lo centra. Es la misma idea que el `_InputPadding` interno de
/// los botones de Material.
class _MinTapArea extends SingleChildRenderObjectWidget {
  const _MinTapArea({required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderMinTapArea();
}

class _RenderMinTapArea extends RenderShiftedBox {
  _RenderMinTapArea() : super(null);

  @override
  void performLayout() {
    final child = this.child!;
    child.layout(constraints, parentUsesSize: true);
    size = constraints.constrain(Size(
      math.max(child.size.width, kMinInteractiveDimension),
      math.max(child.size.height, kMinInteractiveDimension),
    ));
    // Centra el dibujo dentro del área táctil.
    (child.parentData! as BoxParentData).offset =
        Alignment.center.alongOffset(size - child.size as Offset);
  }

  // Los intrínsecos (usados por IntrinsicHeight) también respetan el mínimo.
  @override
  double computeMinIntrinsicHeight(double width) => math.max(
      super.computeMinIntrinsicHeight(width), kMinInteractiveDimension);

  @override
  double computeMaxIntrinsicHeight(double width) => math.max(
      super.computeMaxIntrinsicHeight(width), kMinInteractiveDimension);

  @override
  double computeMinIntrinsicWidth(double height) => math.max(
      super.computeMinIntrinsicWidth(height), kMinInteractiveDimension);

  @override
  double computeMaxIntrinsicWidth(double height) => math.max(
      super.computeMaxIntrinsicWidth(height), kMinInteractiveDimension);

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final childSize = child!.getDryLayout(constraints);
    return constraints.constrain(Size(
      math.max(childSize.width, kMinInteractiveDimension),
      math.max(childSize.height, kMinInteractiveDimension),
    ));
  }
}
