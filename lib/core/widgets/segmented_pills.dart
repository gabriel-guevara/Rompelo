import 'package:flutter/material.dart';

import '../constants/app_color.dart';
import '../constants/app_spacing.dart';
import 'chunky_pressable.dart';

/// Una opción de [SegmentedPills].
@immutable
class SegmentOption<T> {
  const SegmentOption({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

/// Selector segmentado de opciones mutuamente excluyentes
/// ("Por equipos / Todos vs todos", "45 s / 60 s / 90 s").
///
/// Es genérico en `T` para que el valor sea tipado (un enum, un int…) y no
/// un índice o un string suelto.
class SegmentedPills<T> extends StatelessWidget {
  const SegmentedPills({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.activeColor = AppColors.secondary,
    this.activeForeground = AppColors.onSecondary,
    this.activeShadow = AppColors.shadowWine,
  });

  final List<SegmentOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;
  final Color activeColor;
  final Color activeForeground;
  final Color activeShadow;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppRadius.inner,
      ),
      child: Row(
        children: [
          for (final (index, option) in options.indexed) ...[
            if (index > 0) const SizedBox(width: AppSpacing.xs),
            Expanded(child: _segment(option, textTheme)),
          ],
        ],
      ),
    );
  }

  Widget _segment(SegmentOption<T> option, TextTheme textTheme) {
    final isSelected = option.value == selected;
    final fg = isSelected ? activeForeground : AppColors.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: ChunkyPressable(
        onTap: () => onChanged(option.value),
        selected: isSelected,
        semanticLabel: option.label,
        builder: (context, pressed) => AnimatedContainer(
          duration: kChunkyPressDuration,
          padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.sm, horizontal: AppSpacing.xs),
          transform:
              Matrix4.translationValues(0, isSelected && pressed ? 2 : 0, 0),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: activeShadow,
                        offset: Offset(0, pressed ? 1 : 3)),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (option.icon != null) ...[
                Icon(option.icon, size: 20, color: fg),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  option.label,
                  style: textTheme.labelLarge?.copyWith(color: fg),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
