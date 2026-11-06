import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../../../core/theme/app_colors.dart';

/// Paints the Moon's disc with its real lit shape.
///
/// The terminator is the half-ellipse that the shadow boundary projects to,
/// so the lit fraction on screen matches [illuminatedFraction]. The disc is
/// turned so the middle of the bright limb points along [brightLimbAngle],
/// a position angle measured from the top of the picture towards the left
/// (east on a north-up sky map), as Meeus defines it.
class MoonPainter extends CustomPainter {
  const MoonPainter({
    required this.illuminatedFraction,
    required this.brightLimbAngle,
    this.rotation = 0,
  });

  /// Lit share of the disc, from 0 to 1.
  final double illuminatedFraction;

  /// Position angle of the bright limb's midpoint, in degrees.
  final double brightLimbAngle;

  /// Turns the whole picture clockwise by this many degrees. Pass the
  /// parallactic angle to show the Moon as it sits in the observer's sky,
  /// with the zenith at the top, or 180 for a southern-hemisphere view.
  final double rotation;

  /// The direction the lit side faces, in radians from the +x axis of the
  /// canvas (y pointing down).
  static double litDirection(double brightLimbAngle) {
    final chi = brightLimbAngle * math.pi / 180;
    // Up is north and left is east, so a position angle χ points along
    // (−sin χ, −cos χ) on screen.
    return math.atan2(-math.cos(chi), -math.sin(chi));
  }

  /// The lit region of a disc of [radius] centred on the origin, with the
  /// bright limb towards +x.
  static Path litPath(double radius, double illuminatedFraction) {
    final k = illuminatedFraction.clamp(0.0, 1.0);
    // The terminator crosses the disc's equator at x = −r·cos(i), where i is
    // the phase angle and k = (1 + cos i) / 2.
    final e = radius * (2 * k - 1);
    final path = Path()
      ..moveTo(0, -radius)
      ..arcTo(
        Rect.fromCircle(center: Offset.zero, radius: radius),
        -math.pi / 2,
        math.pi,
        false,
      );
    const steps = 64;
    for (var s = 0; s <= steps; s++) {
      final t = math.pi / 2 - math.pi * s / steps; // from bottom to top
      final y = radius * math.sin(t);
      final x = -e * math.cos(t);
      path.lineTo(x, y);
    }
    return path..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide / 2 * 0.82;
    final center = size.center(Offset.zero);
    final k = illuminatedFraction.clamp(0.0, 1.0);
    final detailed = r > 40;

    // Halo, stronger the fuller the moon.
    if (detailed) {
      canvas.drawCircle(
        center,
        r * 1.08,
        Paint()
          ..color = AppColors.moonlight.withValues(alpha: 0.04 + 0.18 * k)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.18),
      );
    }

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation * math.pi / 180);

    final disc = Rect.fromCircle(center: Offset.zero, radius: r);
    canvas.clipPath(Path()..addOval(disc));

    // Night side, faintly lit by earthshine.
    canvas.drawRect(disc, Paint()..color = const Color(0xFF1A2039));

    // Day side.
    canvas.save();
    final litAngle = litDirection(brightLimbAngle);
    canvas.rotate(litAngle);
    canvas.clipPath(litPath(r, k));
    canvas.rotate(-litAngle);
    canvas.drawRect(
      disc,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.2, -0.25),
          radius: 1.1,
          colors: [Color(0xFFF7F3E8), AppColors.moonlight, Color(0xFFCFC8B4)],
          stops: [0.0, 0.55, 1.0],
        ).createShader(disc),
    );

    // Maria, in the Moon's own frame so they stay put as the phase changes.
    if (detailed) {
      final maria = Paint()
        ..color = const Color(0xFF6E6A70).withValues(alpha: 0.22)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.05);
      for (final m in _maria) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(m[0] * r, m[1] * r),
            width: m[2] * r,
            height: m[3] * r,
          ),
          maria,
        );
      }
    }
    canvas.restore();

    // Limb darkening, so the disc reads as a sphere.
    canvas.drawRect(
      disc,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0x00000000),
            const Color(0x00000000),
            AppColors.night.withValues(alpha: 0.35),
          ],
          stops: const [0.0, 0.72, 1.0],
        ).createShader(disc),
    );
    canvas.restore();

    // A faint rim so a new moon is still a visible disc.
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = detailed ? 1 : 0.75
        ..color = AppColors.moonlight.withValues(alpha: 0.12),
    );
  }

  @override
  bool shouldRepaint(MoonPainter old) =>
      old.illuminatedFraction != illuminatedFraction ||
      old.brightLimbAngle != brightLimbAngle ||
      old.rotation != rotation;
}

/// Rough places and sizes of the large maria on the near side, north up and
/// east (Mare Crisium) to the right as the Moon is seen in the sky: centre
/// x, centre y, width and height, in disc radii.
const List<List<double>> _maria = [
  [-0.30, -0.42, 0.44, 0.34], // Imbrium
  [-0.18, -0.30, 0.26, 0.22],
  [0.10, -0.38, 0.30, 0.26], // Serenitatis
  [0.30, -0.12, 0.36, 0.30], // Tranquillitatis
  [0.20, -0.02, 0.22, 0.18],
  [0.64, -0.30, 0.20, 0.17], // Crisium
  [-0.58, -0.10, 0.36, 0.50], // Procellarum
  [-0.48, 0.18, 0.30, 0.34],
  [-0.30, -0.66, 0.40, 0.12], // Frigoris
  [0.42, 0.22, 0.24, 0.24], // Fecunditatis
  [0.22, 0.32, 0.18, 0.16], // Nectaris
  [-0.20, 0.32, 0.28, 0.22], // Nubium
  [-0.46, 0.42, 0.18, 0.15], // Humorum
  [-0.06, -0.08, 0.14, 0.12], // Vaporum
];
