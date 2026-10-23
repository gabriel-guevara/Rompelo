import 'package:flutter/material.dart';

import '../../../core/constants/app_color.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/chunky_pressable.dart';
import '../data/deck_options.dart';

/// Carrusel de chips "👑 P1 Mateo" editables (RF: ingresar nombres).
///
/// Tocar un chip abre un diálogo para renombrar. El estado no vive aquí:
/// el padre recibe el cambio en [onRename] y lo guarda en su provider.
class PlayerNamesEditor extends StatelessWidget {
  const PlayerNamesEditor({
    super.key,
    required this.names,
    required this.onRename,
    this.tint = AppColors.surfaceContainer,
  });

  final List<String> names;
  final void Function(int index, String name) onRename;
  final Color tint;

  Future<void> _edit(BuildContext context, int index) async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) =>
          _RenameDialog(position: index + 1, initial: names[index]),
    );
    if (name != null && name.isNotEmpty) onRename(index, name);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (index, name) in names.indexed) ...[
            if (index > 0) const SizedBox(width: AppSpacing.xs),
            ChunkyPressable(
              key: ValueKey('player-chip-$index'),
              onTap: () => _edit(context, index),
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
                      Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          shape: BoxShape.circle,
                        ),
                        child: Text(playerEmoji(index),
                            style: const TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text('P${index + 1} ',
                          style: textTheme.labelSmall
                              ?.copyWith(color: AppColors.onSurfaceVariant)),
                      Text(name, style: textTheme.labelMedium),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
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
