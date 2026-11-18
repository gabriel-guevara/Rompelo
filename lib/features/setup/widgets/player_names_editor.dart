import 'package:flutter/material.dart';

import '../../../core/constants/app_color.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/chunky_pressable.dart';
import '../../../core/widgets/player_avatar.dart';

/// Carrusel deslizable de chips "P1 Mateo" editables (RF: ingresar nombres).
///
/// Tocar un chip abre un diálogo para renombrar. El estado de los nombres no
/// vive aquí: el padre recibe el cambio en [onRename] y lo guarda en su
/// provider. Este widget solo guarda el `ScrollController` del carrusel.
///
/// Para que se note que se desliza: los bordes se desvanecen cuando hay más
/// nombres a ese lado, una pista "Desliza" aparece si no caben todos, y al
/// sumar un jugador el carrusel se mueve solo hasta el nuevo.
class PlayerNamesEditor extends StatefulWidget {
  const PlayerNamesEditor({
    super.key,
    required this.names,
    required this.onRename,
    this.tint = AppColors.surfaceContainer,
  });

  final List<String> names;
  final void Function(int index, String name) onRename;
  final Color tint;

  @override
  State<PlayerNamesEditor> createState() => _PlayerNamesEditorState();
}

class _PlayerNamesEditorState extends State<PlayerNamesEditor> {
  final ScrollController _scroll = ScrollController();

  /// Ancho de los bordes que se desvanecen.
  static const double _fade = 28;

  @override
  void didUpdateWidget(PlayerNamesEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.names.length > oldWidget.names.length) {
      // Se sumó un jugador: tras el próximo frame (ya medido) se lleva el
      // carrusel al final para mostrar el chip nuevo.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scroll.hasClients) return;
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      });
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _edit(int index) async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) =>
          _RenameDialog(position: index + 1, initial: widget.names[index]),
    );
    if (name != null && name.isNotEmpty) widget.onRename(index, name);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final names = widget.names;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ListenableBuilder se redibuja con cada desplazamiento para saber
        // si quedan nombres a la izquierda o a la derecha.
        ListenableBuilder(
          listenable: _scroll,
          builder: (context, child) {
            final measured =
                _scroll.hasClients && _scroll.position.hasContentDimensions;
            final moreLeft = measured && _scroll.offset > 1;
            final moreRight = measured &&
                _scroll.offset < _scroll.position.maxScrollExtent - 1;
            return ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  moreLeft ? Colors.transparent : Colors.black,
                  Colors.black,
                  Colors.black,
                  moreRight ? Colors.transparent : Colors.black,
                ],
                stops: [
                  0,
                  _fade / bounds.width,
                  1 - _fade / bounds.width,
                  1,
                ],
              ).createShader(bounds),
              child: child,
            );
          },
          child: SingleChildScrollView(
            controller: _scroll,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final (index, name) in names.indexed) ...[
                  if (index > 0) const SizedBox(width: AppSpacing.xs),
                  _PlayerChip(
                    key: ValueKey('player-chip-$index'),
                    index: index,
                    name: name,
                    tint: widget.tint,
                    onTap: () => _edit(index),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        ListenableBuilder(
          listenable: _scroll,
          builder: (context, _) {
            final scrollable = _scroll.hasClients &&
                _scroll.position.hasContentDimensions &&
                _scroll.position.maxScrollExtent > 0;
            return Row(
              children: [
                const Icon(Icons.edit_rounded,
                    size: 14, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    scrollable
                        ? 'Desliza para ver a los ${names.length} · toca un '
                            'nombre para cambiarlo'
                        : 'Toca un nombre para cambiarlo',
                    key: const ValueKey('player-names-hint'),
                    style: textTheme.labelSmall
                        ?.copyWith(color: AppColors.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (scrollable)
                  const Icon(Icons.swipe_left_rounded,
                      size: 18, color: AppColors.onSurfaceVariant),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _PlayerChip extends StatelessWidget {
  const _PlayerChip({
    super.key,
    required this.index,
    required this.name,
    required this.tint,
    required this.onTap,
  });

  final int index;
  final String name;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ChunkyPressable(
      onTap: onTap,
      semanticLabel: 'Renombrar jugador ${index + 1}, $name',
      builder: (context, pressed) => AnimatedScale(
        scale: pressed ? 0.95 : 1,
        duration: kChunkyPressDuration,
        child: Container(
          padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
          decoration: BoxDecoration(
            color: tint,
            borderRadius: AppRadius.pill,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PlayerAvatar(index: index, size: 32),
              const SizedBox(width: AppSpacing.xs),
              Text('P${index + 1} ',
                  style: textTheme.labelSmall
                      ?.copyWith(color: AppColors.onSurfaceVariant)),
              Text(name, style: textTheme.labelMedium),
            ],
          ),
        ),
      ),
    );
  }
}

/// Diálogo con su propio `TextEditingController`. Es un `StatefulWidget`
/// para crear y liberar (`dispose`) el controller en el ciclo de vida
/// correcto, como un `useRef` + cleanup en React.
class _RenameDialog extends StatefulWidget {
  const _RenameDialog({required this.position, required this.initial});

  final int position;
  final String initial;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() => Navigator.of(context).pop(_controller.text.trim());

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Jugador ${widget.position}'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 16,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(hintText: 'Nombre o apodo'),
        onSubmitted: (_) => _save(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _save, child: const Text('Guardar')),
      ],
    );
  }
}
