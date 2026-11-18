import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_color.dart';
import '../constants/app_spacing.dart';
import '../../features/catalog/widgets/how_to_play.dart';

/// Barra superior de las pantallas del shell: logo "Rómpelo / Party Hub"
/// y acciones a la derecha (mockup `home`).
class RompeloAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RompeloAppBar({
    super.key,
    this.subtitle = 'Party Hub',
    this.actions,
  });

  final String subtitle;

  /// Si es `null` se muestra el botón "¿Cómo se juega?".
  final List<Widget>? actions;

  static const double _height = 64;

  @override
  Size get preferredSize => const Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: _height,
          padding: AppSpacing.screenPadding,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.surfaceContainerHighest),
            ),
          ),
          child: Row(
            children: [
              // Logo del equipo (martillo rompiendo el hielo).
              SvgPicture.asset(
                'assets/branding/logo.svg',
                width: 40,
                height: 40,
                semanticsLabel: 'Logo de Rómpelo',
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre "Rómpelo" con la tipografía del logo.
                    SvgPicture.asset(
                      'assets/branding/wordmark.svg',
                      height: 26,
                      alignment: Alignment.centerLeft,
                      semanticsLabel: 'Rómpelo',
                    ),
                    Text(
                      subtitle,
                      style: textTheme.labelSmall
                          ?.copyWith(color: AppColors.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              ...(actions ?? const [HowToPlayButton()]),
            ],
          ),
        ),
      ),
    );
  }
}
