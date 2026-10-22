/// Illuminated fraction and bright limb of the Moon (Meeus ch. 48).
library;

import 'astro_math.dart';
import 'moon_position.dart';
import 'sun_position.dart';

/// Lit fraction and orientation of the Moon's disc at one instant.
class MoonIllumination {
  const MoonIllumination({
    required this.elongation,
    required this.phaseAngle,
    required this.fraction,
    required this.brightLimbAngle,
  });

  /// Ecliptic longitude of the Moon minus that of the Sun, in [0, 360).
  /// It is 0 at new moon, 90 at first quarter, 180 at full moon and 270 at
  /// last quarter, so it also gives the position in the cycle.
  final double elongation;

  /// Sun–Moon–Earth angle, in degrees: 180 at new moon and 0 at full moon.
  final double phaseAngle;

  /// Illuminated fraction of the disc, from 0 to 1.
  final double fraction;

  /// Position angle of the midpoint of the bright limb, in degrees, measured
  /// from the north point of the disc towards the east (Meeus eq. 48.5).
  /// About 270 while the Moon waxes and 90 while it wanes.
  final double brightLimbAngle;

  /// True from new moon to full moon.
  bool get isWaxing => elongation < 180.0;
}

MoonIllumination moonIllumination(MoonPosition moon, SunPosition sun) {
  final elongation = normalizeDegrees(
    moon.apparentLongitude - sun.apparentLongitude,
  );

  // Geocentric elongation ψ (eq. 48.2) and phase angle i (eq. 48.3).
  final cosPsi =
      cosDeg(moon.latitude) *
      cosDeg(moon.apparentLongitude - sun.apparentLongitude);
  final psi = acosDeg(cosPsi);
  final r = sun.distanceKm;
  final phaseAngle = atan2Deg(r * sinDeg(psi), moon.distanceKm - r * cosPsi);
  final fraction = (1 + cosDeg(phaseAngle)) / 2;

  final a0 = sun.equatorial.rightAscension;
  final d0 = sun.equatorial.declination;
  final a = moon.equatorial.rightAscension;
  final d = moon.equatorial.declination;
  final chi = atan2Deg(
    cosDeg(d0) * sinDeg(a0 - a),
    sinDeg(d0) * cosDeg(d) - cosDeg(d0) * sinDeg(d) * cosDeg(a0 - a),
  );

  return MoonIllumination(
    elongation: elongation,
    phaseAngle: phaseAngle,
    fraction: fraction,
    brightLimbAngle: normalizeDegrees(chi),
  );
}
