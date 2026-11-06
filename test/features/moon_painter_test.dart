import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moon_cycle/features/moon/widgets/moon_painter.dart';

/// Share of the disc inside [path], by sampling a grid.
double litShare(Path path, double r) {
  var inDisc = 0;
  var lit = 0;
  const n = 200;
  for (var i = 0; i < n; i++) {
    for (var j = 0; j < n; j++) {
      final p = Offset(-r + 2 * r * (i + 0.5) / n, -r + 2 * r * (j + 0.5) / n);
      if (p.distance > r) continue;
      inDisc++;
      if (path.contains(p)) lit++;
    }
  }
  return lit / inDisc;
}

void main() {
  test('the lit area matches the illuminated fraction', () {
    for (final k in [0.02, 0.1, 0.3, 0.5, 0.7, 0.9, 0.98]) {
      final share = litShare(MoonPainter.litPath(100, k), 100);
      expect(share, closeTo(k, 0.01), reason: 'k = $k');
    }
  });

  test('a waxing moon is lit on the right, a waning one on the left', () {
    // Bright limb position angles: about 270° waxing, 90° waning.
    expect(MoonPainter.litDirection(270), closeTo(0, 1e-9));
    expect(MoonPainter.litDirection(90).abs(), closeTo(math.pi, 1e-9));
    // 0° is north, the top of the picture.
    expect(MoonPainter.litDirection(0), closeTo(-math.pi / 2, 1e-9));
  });
}
