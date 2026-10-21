/// Shared math and time helpers for the astronomy engine.
///
/// Algorithms follow Jean Meeus, "Astronomical Algorithms", 2nd edition
/// (Willmann-Bell, 1998). Chapter numbers are cited next to each routine.
library;

import 'dart:math' as math;

const double degToRad = math.pi / 180.0;
const double radToDeg = 180.0 / math.pi;

/// Julian Day of the J2000.0 epoch (2000 January 1, 12h TT).
const double j2000 = 2451545.0;

/// Julian Day of the Unix epoch (1970 January 1, 0h UTC).
const double _unixEpochJd = 2440587.5;

const double _msPerDay = 86400000.0;

double sinDeg(double deg) => math.sin(deg * degToRad);
double cosDeg(double deg) => math.cos(deg * degToRad);
double tanDeg(double deg) => math.tan(deg * degToRad);
double asinDeg(double x) => math.asin(x.clamp(-1.0, 1.0)) * radToDeg;
double acosDeg(double x) => math.acos(x.clamp(-1.0, 1.0)) * radToDeg;
double atan2Deg(double y, double x) => math.atan2(y, x) * radToDeg;

/// Reduces an angle to the range [0, 360).
double normalizeDegrees(double deg) {
  final r = deg % 360.0;
  return r < 0 ? r + 360.0 : r;
}

/// Reduces an angle to the range [-180, 180).
double normalizeDegreesSigned(double deg) {
  final r = normalizeDegrees(deg);
  return r >= 180.0 ? r - 360.0 : r;
}

/// Julian Day (UT) for an instant. The instant is read as UTC whatever its
/// time zone.
double julianDayFromDateTime(DateTime time) =>
    time.toUtc().millisecondsSinceEpoch / _msPerDay + _unixEpochJd;

/// UTC instant for a Julian Day (UT).
DateTime dateTimeFromJulianDay(double jd) =>
    DateTime.fromMillisecondsSinceEpoch(
      ((jd - _unixEpochJd) * _msPerDay).round(),
      isUtc: true,
    );

/// Julian centuries since J2000.0 for a Julian Ephemeris Day.
double julianCenturies(double jde) => (jde - j2000) / 36525.0;

/// Fractional year for an instant, used by [deltaTSeconds].
double decimalYear(DateTime time) {
  final t = time.toUtc();
  final start = DateTime.utc(t.year);
  final end = DateTime.utc(t.year + 1);
  return t.year +
      t.difference(start).inMilliseconds / end.difference(start).inMilliseconds;
}

/// Measured values of ΔT = TT − UT in seconds (IERS, Astronomical Almanac),
/// one per decade, used for interpolation between 1900 and 2025.
const List<double> _deltaTByDecade = [
  -2.7, 10.4, 21.2, 24.0, 24.3, 29.1, 33.2, 40.2, 50.5, 56.9, 63.8, 66.1, //
  69.4,
];

/// ΔT = TT − UT in seconds for a decimal year.
///
/// Between 1900 and 2020 this interpolates measured values; 2020 to 2025 is
/// close to flat at about 69 s. After 2025 it uses a slow linear drift, which
/// is a prediction: an error of a few seconds shifts phase times by the same
/// few seconds and has no visible effect in the app. Outside 1900 to 2150 it
/// falls back on the Morrison and Stephenson long-term parabola.
double deltaTSeconds(double year) {
  if (year >= 1900 && year < 2020) {
    final x = (year - 1900) / 10.0;
    final i = x.floor();
    final f = x - i;
    return _deltaTByDecade[i] +
        (_deltaTByDecade[i + 1] - _deltaTByDecade[i]) * f;
  }
  if (year >= 2020 && year < 2025) return 69.4 - 0.04 * (year - 2020);
  if (year >= 2025 && year <= 2150) return 69.2 + 0.2 * (year - 2025);
  final u = (year - 1820) / 100.0;
  return -20 + 32 * u * u;
}

/// Julian Ephemeris Day (TT) for a UTC instant.
double julianEphemerisDay(DateTime time) =>
    julianDayFromDateTime(time) + deltaTSeconds(decimalYear(time)) / 86400.0;

/// UTC instant for a Julian Ephemeris Day (TT).
DateTime dateTimeFromJulianEphemerisDay(double jde) {
  final approx = dateTimeFromJulianDay(jde);
  return dateTimeFromJulianDay(
    jde - deltaTSeconds(decimalYear(approx)) / 86400.0,
  );
}

/// Nutation in longitude and obliquity, in degrees (Meeus ch. 22, the
/// abridged series accurate to 0.5″ in Δψ and 0.1″ in Δε).
({double dPsi, double dEps}) nutation(double t) {
  final omega = 125.04452 - 1934.136261 * t;
  final l = 280.4665 + 36000.7698 * t;
  final lp = 218.3165 + 481267.8813 * t;
  final dPsi =
      -17.20 * sinDeg(omega) -
      1.32 * sinDeg(2 * l) -
      0.23 * sinDeg(2 * lp) +
      0.21 * sinDeg(2 * omega);
  final dEps =
      9.20 * cosDeg(omega) +
      0.57 * cosDeg(2 * l) +
      0.10 * cosDeg(2 * lp) -
      0.09 * cosDeg(2 * omega);
  return (dPsi: dPsi / 3600.0, dEps: dEps / 3600.0);
}

/// Mean obliquity of the ecliptic in degrees (Meeus eq. 22.2).
double meanObliquity(double t) {
  final seconds = 21.448 - t * (46.8150 + t * (0.00059 - t * 0.001813));
  return 23.0 + (26.0 + seconds / 60.0) / 60.0;
}

/// Greenwich mean sidereal time in degrees for a Julian Day (UT)
/// (Meeus eq. 12.4).
double greenwichMeanSiderealTime(double jd) {
  final t = (jd - j2000) / 36525.0;
  return normalizeDegrees(
    280.46061837 +
        360.98564736629 * (jd - j2000) +
        t * t * (0.000387933 - t / 38710000.0),
  );
}

/// Equatorial coordinates, in degrees.
class Equatorial {
  const Equatorial(this.rightAscension, this.declination);

  final double rightAscension;
  final double declination;
}

/// Converts ecliptic longitude and latitude to equatorial coordinates
/// (Meeus eqs. 13.3 and 13.4).
Equatorial eclipticToEquatorial(double lambda, double beta, double epsilon) {
  final ra = atan2Deg(
    sinDeg(lambda) * cosDeg(epsilon) - tanDeg(beta) * sinDeg(epsilon),
    cosDeg(lambda),
  );
  final dec = asinDeg(
    sinDeg(beta) * cosDeg(epsilon) +
        cosDeg(beta) * sinDeg(epsilon) * sinDeg(lambda),
  );
  return Equatorial(normalizeDegrees(ra), dec);
}
