import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/constants/app_color.dart';

/// Confeti **estático** detrás del título: decorativo, sin animación
/// infinita (no gasta batería ni rompe `pumpAndSettle` en los tests).
///
/// Usa un `Random` con semilla fija: el confeti sale igual en cada frame y
/// en cada dispositivo, así no "salta" al redibujar.
class ConfettiBackdrop extends StatelessWidget {
  const ConfettiBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: CustomPaint(painter: _ConfettiPainter(), size: Size.infinite),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter();

  static const _colors = [
    AppColors.secondaryContainer,
    AppColors.primaryContainer,
    AppColors.primary,
    AppColors.secondaryFixedDim,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(7);
    final paint = Paint();
    for (var i = 0; i < 22; i++) {
      paint.color = _colors[i % _colors.length].withValues(alpha: 0.85);
      canvas
        ..save()
        ..translate(
            random.nextDouble() * size.width, random.nextDouble() * size.height)
        ..rotate(random.nextDouble() * pi)
        ..drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset.zero,
                width: 6 + random.nextDouble() * 6,
                height: 4 + random.nextDouble() * 3),
            const Radius.circular(1.5),
          ),
          paint,
        )
        ..restore();
    }
  }

  // Siempre igual: nunca hace falta repintar.
  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => false;
}
