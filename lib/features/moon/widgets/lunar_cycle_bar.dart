import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// A track from one new moon to the next, with the quarters marked and a
/// dot for where the Moon is now.
class LunarCycleBar extends StatelessWidget {
  const LunarCycleBar({super.key, required this.fraction});

  /// From 0 at new moon to 1 at the next new moon.
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        height: 18,
        width: double.infinity,
        child: CustomPaint(painter: _CycleBarPainter(fraction)),
      ),
    );
  }
}

class _CycleBarPainter extends CustomPainter {
  const _CycleBarPainter(this.fraction);

  final double fraction;

  @override
  void paint(Canvas canvas, Size size) {
    const dot = 7.0;
    final y = size.height / 2;
    final left = dot;
    final right = size.width - dot;
    final width = right - left;

    final track = Paint()
      ..color = AppColors.outline
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(left, y), Offset(right, y), track);

    final x = left + width * fraction.clamp(0.0, 1.0);
    canvas.drawLine(
      Offset(left, y),
      Offset(x, y),
      track..color = AppColors.moonlight.withValues(alpha: 0.55),
    );

    // New, first quarter, full, last quarter, new.
    const marks = [0.0, 0.25, 0.5, 0.75, 1.0];
    for (final m in marks) {
      final color = m == 0.5
          ? AppColors.gold
          : (m == 0.0 || m == 1.0)
          ? AppColors.lavender
          : AppColors.textSecondary;
      canvas.drawCircle(Offset(left + width * m, y), 3, Paint()..color = color);
    }

    canvas.drawCircle(
      Offset(x, y),
      dot,
      Paint()
        ..color = AppColors.moonlight.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(Offset(x, y), 5, Paint()..color = AppColors.moonlight);
  }

  @override
  bool shouldRepaint(_CycleBarPainter old) => old.fraction != fraction;
}
