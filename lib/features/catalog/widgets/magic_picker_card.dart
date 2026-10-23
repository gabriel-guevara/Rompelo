import 'package:flutter/material.dart';

import '../../../core/constants/app_color.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/chunky_button.dart';
import '../../../core/widgets/counter_stepper.dart';
import '../../../core/widgets/chunky_pressable.dart';

/// Tarjeta azul "Selector mágico" del home: stepper de jugadores y botón
/// "¡Elegir juego al azar!".
///
/// Como [CounterStepper], es controlada: recibe [players] y avisa con
/// callbacks; el estado real vive en un provider que maneja el home.
class MagicPickerCard extends StatelessWidget {
  const MagicPickerCard({
    super.key,
    required this.players,
    required this.minPlayers,
    required this.maxPlayers,
    required this.onPlayersChanged,
    required this.onPickRandom,
  });

  final int players;
  final int minPlayers;
  final int maxPlayers;
  final ValueChanged<int> onPlayersChanged;
  final VoidCallback onPickRandom;

  /// Tono intermedio del degradado (`via-[#a8cbf6]` en el mockup).
  static const Color _gradientMid = Color(0xFFA8CBF6);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(AppSpacing.margin),
      decoration: BoxDecoration(
        borderRadius: AppRadius.card,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryContainer,
            _gradientMid,
            AppColors.primaryFixed,
          ],
        ),
        boxShadow: chunkyShadow(AppColors.primary, 6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _MagicBadge(),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '¿No saben qué elegir?',
                      style: AppTheme.withWeight(
                        textTheme.headlineLarge!,
                        FontWeight.w800,
                      ).copyWith(color: AppColors.onPrimaryFixed),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gira y deja que el azar elija el rompehielos ideal '
                      'para este grupo.',
                      style: textTheme.bodySmall
                          ?.copyWith(color: AppColors.onPrimaryContainer),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: AppRadius.inner,
                ),
                child: const Icon(Icons.casino_rounded,
                    size: 28, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm, AppSpacing.xs, AppSpacing.xs, AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest.withValues(alpha: 0.9),
              borderRadius: AppRadius.inner,
              border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
            ),
            child: Row(
              children: [
                const Icon(Icons.groups_rounded,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child:
                      Text('Jugadores reunidos', style: textTheme.labelMedium),
                ),
                CounterStepper(
                  value: players,
                  min: minPlayers,
                  max: maxPlayers,
                  accent: AppColors.primary,
                  accentShadow: AppColors.shadowPrimary,
                  onChanged: onPlayersChanged,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ChunkyButton(
            label: '¡Elegir juego al azar!',
            leadingIcon: Icons.shuffle_rounded,
            height: 56,
            onPressed: onPickRandom,
          ),
        ],
      ),
    );
  }
}

/// Píldora "Selector mágico" sobre el título.
class _MagicBadge extends StatelessWidget {
  const _MagicBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: AppRadius.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome_rounded,
              size: 15, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            'Selector mágico',
            style: AppTheme.withWeight(
              Theme.of(context).textTheme.labelSmall!,
              FontWeight.w700,
            ).copyWith(color: AppColors.onPrimaryContainer),
          ),
        ],
      ),
    );
  }
}
