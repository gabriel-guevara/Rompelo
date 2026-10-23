import 'package:flutter/material.dart';

/// Base táctil del estilo "chunky": detecta si el dedo está presionando y le
/// pasa ese estado a [builder] para que el widget dibuje su versión hundida.
///
/// Centralizar aquí el gesto evita repetir la misma lógica en botones,
/// chips, tiles y steppers (DRY).
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
    return Semantics(
      button: true,
      enabled: enabled,
      selected: widget.selected,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _setPressed(true) : null,
        onTapUp: enabled ? (_) => _setPressed(false) : null,
        onTapCancel: enabled ? () => _setPressed(false) : null,
        onTap: widget.onTap,
        child: widget.builder(context, enabled && _pressed),
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
