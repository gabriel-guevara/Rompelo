import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/rompelo_app_bar.dart';

/// Esqueleto común de las 3 pantallas de configuración: app bar
/// "Rómpelo / Configurar", contenido desplazable y CTA al final con una
/// nota opcional debajo.
///
/// Es el equivalente a un *layout* de Angular/React: las pantallas solo
/// aportan sus secciones y no repiten paddings ni anchos máximos (DRY).
class ConfigScaffold extends StatelessWidget {
  const ConfigScaffold({
    super.key,
    required this.children,
    required this.cta,
    this.footnote,
  });

  final List<Widget> children;
  final Widget cta;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const RompeloAppBar(subtitle: 'Configurar'),
      body: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.margin, AppSpacing.md,
                AppSpacing.margin, AppSpacing.xl),
            children: [
              for (final child in children) ...[
                child,
                const SizedBox(height: AppSpacing.lg),
              ],
              cta,
              if (footnote != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  footnote!,
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
