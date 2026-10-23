import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_color.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/chunky_button.dart';
import '../../../core/widgets/rompelo_app_bar.dart';
import '../../games/providers/match_result_provider.dart';
import '../../setup/presentation/config_feedback.dart';
import '../../setup/widgets/config_section.dart';
import '../providers/app_settings_provider.dart';

/// Tab Ajustes (`/ajustes`). No tiene mockup: reutiliza `ConfigSection` y
/// `RuleSwitch` de la configuración para verse coherente con el resto.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const String version = '1.0.0';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);
    final hasResult = ref.watch(lastMatchResultProvider) != null;

    return Scaffold(
      appBar: const RompeloAppBar(subtitle: 'Ajustes'),
      body: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.margin, AppSpacing.lg,
                AppSpacing.margin, AppSpacing.xl),
            children: [
              Text('Ajustes', style: textTheme.displayMedium),
              const SizedBox(height: AppSpacing.lg),
              ConfigSection(
                title: 'Durante la partida',
                subtitle: 'Se aplican a todos los juegos',
                trailing:
                    const Icon(Icons.tune_rounded, color: AppColors.primary),
                children: [
                  RuleSwitch(
                    title: 'Sonidos',
                    subtitle: 'Pitidos al acertar y al acabar el tiempo',
                    value: settings.sounds,
                    onChanged: notifier.setSounds,
                    accent: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  RuleSwitch(
                    title: 'Vibración',
                    subtitle: 'Aviso háptico al cambiar de turno',
                    value: settings.vibration,
                    onChanged: notifier.setVibration,
                    accent: AppColors.primary,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  RuleSwitch(
                    title: 'Pantalla siempre encendida',
                    subtitle: 'Que no se apague en plena charada',
                    value: settings.keepScreenOn,
                    onChanged: notifier.setKeepScreenOn,
                    accent: AppColors.primary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              ConfigSection(
                title: 'Marcador',
                subtitle: hasResult
                    ? 'Hay una partida guardada en el marcador'
                    : 'Todavía no hay partidas guardadas',
                trailing: const Icon(Icons.emoji_events_outlined,
                    color: AppColors.secondary),
                children: [
                  ChunkyButton(
                    label: 'Borrar el último marcador',
                    variant: ChunkyButtonVariant.soft,
                    leadingIcon: Icons.delete_outline_rounded,
                    height: 48,
                    depth: 4,
                    onPressed: hasResult
                        ? () {
                            ref.read(lastMatchResultProvider.notifier).clear();
                            showConfigMessage(context, 'Marcador borrado');
                          }
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              ConfigSection(
                title: 'Acerca de Rómpelo',
                subtitle: 'Versión $version',
                trailing: const Text('✨', style: TextStyle(fontSize: 22)),
                children: [
                  Text(
                    'Rómpelo funciona 100 % offline y sin registro: nada de lo '
                    'que juegan sale de este teléfono.',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Hecho por Gabriel Guevara, Lesly Galindo y Mateo Leal · '
                    'Ingeniería de Software, UCompensar.',
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
