import 'package:flutter/material.dart';

import '../constants/app_color.dart';

/// Tamaño del encabezado de sección.
enum SectionHeaderSize {
  /// Etiqueta discreta sobre un bloque de formulario ("Modo de juego").
  label,

  /// Título de bloque en el home ("Explora por vibra").
  title,
}

/// Encabezado de sección con un widget opcional a la derecha
/// (contador "2 seleccionados", badge "3 juegos listos"…).
///
/// Respeta la regla de DESIGN.md: nunca todo en mayúsculas.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.size = SectionHeaderSize.label,
  });

  final String title;
  final Widget? trailing;
  final SectionHeaderSize size;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final style = switch (size) {
      SectionHeaderSize.label =>
        textTheme.labelMedium?.copyWith(color: AppColors.onSurfaceVariant),
      SectionHeaderSize.title => textTheme.headlineSmall,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Expanded(child: Text(title, style: style)),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
