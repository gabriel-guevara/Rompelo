import 'package:flutter/material.dart';

import '../constants/app_color.dart';
import '../constants/app_spacing.dart';
import '../theme/app_theme.dart';

/// Barra superior de las pantallas del shell: logo "Rómpelo ✨ / Party Hub"
/// y acciones a la derecha (mockup `home`).
class RompeloAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RompeloAppBar({
    super.key,
    this.subtitle = 'Party Hub',
    this.actions,
  });

  final String subtitle;

  /// Si es `null` se muestran las acciones por defecto (avatar decorativo);
  /// quien pase las suyas puede reutilizar [RompeloAvatar].
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
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Rómpelo',
                          style: AppTheme.withWeight(
                            textTheme.headlineSmall!,
                            FontWeight.w900,
                          ).copyWith(color: AppColors.secondary, height: 1),
                        ),
                        const SizedBox(width: 4),
                        const Text('✨', style: TextStyle(fontSize: 12)),
                      ],
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
              ...(actions ?? const [RompeloAvatar()]),
            ],
          ),
        ),
      ),
    );
  }
}

/// Avatar decorativo (la app no tiene usuarios: es un solo dispositivo).
class RompeloAvatar extends StatelessWidget {
  const RompeloAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3), width: 2),
      ),
      child: const CircleAvatar(
        radius: 16,
        backgroundColor: AppColors.primary,
        child: Icon(Icons.person_rounded, size: 18, color: AppColors.onPrimary),
      ),
    );
  }
}
