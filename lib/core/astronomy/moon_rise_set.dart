/// Moonrise, moonset and the Moon's place in the local sky.
library;

import 'astro_math.dart';
import 'geo_location.dart';
import 'moon_position.dart';

/// Altitude and azimuth of the Moon for an observer, in degrees.
class HorizontalPosition {
  const HorizontalPosition({
    required this.altitude,
    required this.azimuth,
    required this.parallacticAngle,
  });

  /// Geocentric altitude of the Moon's centre above the horizon, with no
  /// refraction.
  final double altitude;

  /// Azimuth measured from north towards east, in [0, 360).
  final double azimuth;

  /// Angle between the direction to the celestial north pole and the
  /// direction to the zenith, at the Moon (Meeus eq. 14.1). Subtract it from
  /// a position angle to measure from the zenith instead of from north.
  final double parallacticAngle;
}

/// Hour angle of the Moon in degrees, for a Julian Day (UT).
double _hourAngle(double jd, MoonPosition moon, GeoLocation location) {
  final t = (jd - j2000) / 36525.0;
  final apparentSidereal =
      greenwichMeanSiderealTime(jd) + nutation(t).dPsi * cosDeg(moon.obliquity);
  return normalizeDegrees(
    apparentSidereal + location.longitude - moon.equatorial.rightAscension,
  );
}

HorizontalPosition moonHorizontalPosition(DateTime time, GeoLocation location) {
  final jd = julianDayFromDateTime(time);
  final moon = moonPositionAt(time);
  final h = _hourAngle(jd, moon, location);
  final phi = location.latitude;
  final dec = moon.equatorial.declination;

  final altitude = asinDeg(
    sinDeg(phi) * sinDeg(dec) + cosDeg(phi) * cosDeg(dec) * cosDeg(h),
  );
  final azimuth = normalizeDegrees(
    atan2Deg(sinDeg(h), cosDeg(h) * sinDeg(phi) - tanDeg(dec) * cosDeg(phi)) +
        180.0,
  );
  final q = atan2Deg(
    sinDeg(h),
    tanDeg(phi) * cosDeg(dec) - sinDeg(dec) * cosDeg(h),
  );
  return HorizontalPosition(
    altitude: altitude,
    azimuth: azimuth,
    parallacticAngle: q,
  );
}

/// Moonrise and moonset for one local calendar day.
class MoonRiseSet {
  const MoonRiseSet({
    this.rise,
    this.set,
    this.alwaysUp = false,
    this.alwaysDown = false,
  });

  /// When the Moon's upper limb rises above the horizon, in UTC, or null when
  /// it does not rise during this day.
  final DateTime? rise;

  /// When the Moon's upper limb sets below the horizon, in UTC, or null when
  /// it does not set during this day.
  final DateTime? set;

  /// The Moon stays above the horizon all day (polar regions).
  final bool alwaysUp;

  /// The Moon stays below the horizon all day (polar regions).
  final bool alwaysDown;
}

/// Altitude of the Moon's centre above the altitude at which its upper limb
/// touches the horizon, in degrees. Positive means the Moon is up.
///
/// The standard altitude is h0 = 0.7275π − 34′ (Meeus ch. 15): the
/// horizontal parallax π, less the semi-diameter (0.2725π), less 34′ of
/// atmospheric refraction. This is the convention used by the USNO.
double _altitudeAboveHorizon(DateTime time, GeoLocation location) {
  final jd = julianDayFromDateTime(time);
  final moon = moonPositionAt(time);
  final h = _hourAngle(jd, moon, location);
  final phi = location.latitude;
  final dec = moon.equatorial.declination;
  final altitude = asinDeg(
    sinDeg(phi) * sinDeg(dec) + cosDeg(phi) * cosDeg(dec) * cosDeg(h),
  );
  final h0 = 0.7275 * moon.horizontalParallax - 34.0 / 60.0;
  return altitude - h0;
}

const Duration _step = Duration(minutes: 20);

/// Moonrise and moonset during the local day that starts at
/// [localMidnightUtc] and lasts 24 hours.
///
/// The altitude is sampled every 20 minutes and each change of sign is
/// refined by bisection to under one second. The Moon cannot rise or set
/// twice within 20 minutes outside the polar circles, where the result is
/// still reliable to the minute in practice.
MoonRiseSet moonRiseSet(DateTime localMidnightUtc, GeoLocation location) {
  final start = localMidnightUtc.toUtc();
  final end = start.add(const Duration(days: 1));

  DateTime? rise;
  DateTime? set;
  var t0 = start;
  var a0 = _altitudeAboveHorizon(t0, location);
  final startsUp = a0 > 0;
  var everCrossed = false;

  while (t0.isBefore(end)) {
    var t1 = t0.add(_step);
    if (t1.isAfter(end)) t1 = end;
    final a1 = _altitudeAboveHorizon(t1, location);
    if ((a0 > 0) != (a1 > 0)) {
      everCrossed = true;
      final crossing = _bisect(t0, t1, a0, location);
      if (a1 > 0) {
        rise ??= crossing;
      } else {
        set ??= crossing;
      }
    }
    t0 = t1;
    a0 = a1;
  }

  if (!everCrossed) {
    return MoonRiseSet(alwaysUp: startsUp, alwaysDown: !startsUp);
  }
  return MoonRiseSet(rise: rise, set: set);
}

DateTime _bisect(DateTime lo, DateTime hi, double aLo, GeoLocation location) {
  var loMs = lo.millisecondsSinceEpoch;
  var hiMs = hi.millisecondsSinceEpoch;
  final loUp = aLo > 0;
  while (hiMs - loMs > 500) {
    final midMs = (loMs + hiMs) ~/ 2;
    final mid = DateTime.fromMillisecondsSinceEpoch(midMs, isUtc: true);
    if ((_altitudeAboveHorizon(mid, location) > 0) == loUp) {
      loMs = midMs;
    } else {
      hiMs = midMs;
    }
  }
  return DateTime.fromMillisecondsSinceEpoch(
    ((loMs + hiMs) / 2 / 1000).round() * 1000,
    isUtc: true,
  );
}
