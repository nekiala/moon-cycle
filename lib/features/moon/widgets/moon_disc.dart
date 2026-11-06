import 'package:flutter/material.dart';

import '../../../core/astronomy/astronomy.dart';
import 'moon_painter.dart';

/// The Moon as it looks at one instant, turned as it sits in the sky.
class MoonDisc extends StatelessWidget {
  const MoonDisc({
    super.key,
    required this.state,
    required this.rotation,
    required this.semanticLabel,
  });

  final MoonState state;

  /// Clockwise turn of the north-up picture, in degrees.
  final double rotation;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: semanticLabel,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: MoonPainter(
            illuminatedFraction: state.illuminatedFraction,
            brightLimbAngle: state.illumination.brightLimbAngle,
            rotation: rotation,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

/// A small moon for lists, with no time attached.
class MoonGlyph extends StatelessWidget {
  const MoonGlyph({
    super.key,
    required this.fraction,
    required this.brightLimbAngle,
    this.rotation = 0,
  });

  final double fraction;
  final double brightLimbAngle;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        painter: MoonPainter(
          illuminatedFraction: fraction,
          brightLimbAngle: brightLimbAngle,
          rotation: rotation,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}
