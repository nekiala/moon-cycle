/// Geocentric position of the Sun (Meeus ch. 25, low accuracy method).
///
/// Accurate to about 0.01°, which is all the Moon's phase and illumination
/// need: the Moon moves that far in about one minute.
library;

import 'astro_math.dart';

/// Geocentric position of the Sun at one instant.
class SunPosition {
  const SunPosition({
    required this.apparentLongitude,
    required this.distanceAu,
    required this.equatorial,
  });

  /// Apparent ecliptic longitude, in degrees.
  final double apparentLongitude;

  /// Distance between the Earth and the Sun, in astronomical units.
  final double distanceAu;

  /// Apparent right ascension and declination.
  final Equatorial equatorial;

  double get distanceKm => distanceAu * 149597870.7;
}

/// Position of the Sun for a Julian Ephemeris Day (TT).
SunPosition sunPositionAtJde(double jde) {
  final t = julianCenturies(jde);
  final t2 = t * t;

  final l0 = normalizeDegrees(280.46646 + 36000.76983 * t + 0.0003032 * t2);
  final m = normalizeDegrees(357.52911 + 35999.05029 * t - 0.0001537 * t2);
  final e = 0.016708634 - 0.000042037 * t - 0.0000001267 * t2;

  final c =
      (1.914602 - 0.004817 * t - 0.000014 * t2) * sinDeg(m) +
      (0.019993 - 0.000101 * t) * sinDeg(2 * m) +
      0.000289 * sinDeg(3 * m);

  final trueLongitude = l0 + c;
  final trueAnomaly = m + c;
  final distance = 1.000001018 * (1 - e * e) / (1 + e * cosDeg(trueAnomaly));

  final omega = 125.04 - 1934.136 * t;
  final apparentLongitude = normalizeDegrees(
    trueLongitude - 0.00569 - 0.00478 * sinDeg(omega),
  );
  final epsilon = meanObliquity(t) + 0.00256 * cosDeg(omega);

  return SunPosition(
    apparentLongitude: apparentLongitude,
    distanceAu: distance,
    equatorial: eclipticToEquatorial(apparentLongitude, 0, epsilon),
  );
}

/// Position of the Sun at a UTC instant.
SunPosition sunPositionAt(DateTime time) =>
    sunPositionAtJde(julianEphemerisDay(time));
