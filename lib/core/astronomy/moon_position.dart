/// Geocentric position of the Moon (Meeus ch. 47).
///
/// This is the truncated ELP-2000/82 theory given by Meeus: about 10″ in
/// longitude and 4″ in latitude, far finer than anything the app displays.
library;

import 'astro_math.dart';

/// Geocentric position of the Moon at one instant.
class MoonPosition {
  const MoonPosition({
    required this.longitude,
    required this.latitude,
    required this.distanceKm,
    required this.apparentLongitude,
    required this.obliquity,
    required this.equatorial,
  });

  /// Geometric ecliptic longitude, in degrees, mean equinox of date.
  final double longitude;

  /// Ecliptic latitude, in degrees.
  final double latitude;

  /// Distance between the centres of the Earth and the Moon, in km.
  final double distanceKm;

  /// Longitude corrected for nutation, in degrees.
  final double apparentLongitude;

  /// True obliquity of the ecliptic, in degrees.
  final double obliquity;

  /// Apparent right ascension and declination.
  final Equatorial equatorial;

  /// Equatorial horizontal parallax, in degrees.
  double get horizontalParallax => asinDeg(6378.14 / distanceKm);

  /// Apparent angular radius seen from the centre of the Earth, in degrees.
  double get semiDiameter => asinDeg(1737.4 / distanceKm);
}

// Periodic terms for longitude (Σl) and distance (Σr), Meeus table 47.A.
// Columns: D, M, M', F, coefficient of sine (1e-6 deg), coefficient of
// cosine (1e-3 km).
const List<List<int>> _lrTerms = [
  [0, 0, 1, 0, 6288774, -20905355],
  [2, 0, -1, 0, 1274027, -3699111],
  [2, 0, 0, 0, 658314, -2955968],
  [0, 0, 2, 0, 213618, -569925],
  [0, 1, 0, 0, -185116, 48888],
  [0, 0, 0, 2, -114332, -3149],
  [2, 0, -2, 0, 58793, 246158],
  [2, -1, -1, 0, 57066, -152138],
  [2, 0, 1, 0, 53322, -170733],
  [2, -1, 0, 0, 45758, -204586],
  [0, 1, -1, 0, -40923, -129620],
  [1, 0, 0, 0, -34720, 108743],
  [0, 1, 1, 0, -30383, 104755],
  [2, 0, 0, -2, 15327, 10321],
  [0, 0, 1, 2, -12528, 0],
  [0, 0, 1, -2, 10980, 79661],
  [4, 0, -1, 0, 10675, -34782],
  [0, 0, 3, 0, 10034, -23210],
  [4, 0, -2, 0, 8548, -21636],
  [2, 1, -1, 0, -7888, 24208],
  [2, 1, 0, 0, -6766, 30824],
  [1, 0, -1, 0, -5163, -8379],
  [1, 1, 0, 0, 4987, -16675],
  [2, -1, 1, 0, 4036, -12831],
  [2, 0, 2, 0, 3994, -10445],
  [4, 0, 0, 0, 3861, -11650],
  [2, 0, -3, 0, 3665, 14403],
  [0, 1, -2, 0, -2689, -7003],
  [2, 0, -1, 2, -2602, 0],
  [2, -1, -2, 0, 2390, 10056],
  [1, 0, 1, 0, -2348, 6322],
  [2, -2, 0, 0, 2236, -9884],
  [0, 1, 2, 0, -2120, 5751],
  [0, 2, 0, 0, -2069, 0],
  [2, -2, -1, 0, 2048, -4950],
  [2, 0, 1, -2, -1773, 4130],
  [2, 0, 0, 2, -1595, 0],
  [4, -1, -1, 0, 1215, -3958],
  [0, 0, 2, 2, -1110, 0],
  [3, 0, -1, 0, -892, 3258],
  [2, 1, 1, 0, -810, 2616],
  [4, -1, -2, 0, 759, -1897],
  [0, 2, -1, 0, -713, -2117],
  [2, 2, -1, 0, -700, 2354],
  [2, 1, -2, 0, 691, 0],
  [2, -1, 0, -2, 596, 0],
  [4, 0, 1, 0, 549, -1423],
  [0, 0, 4, 0, 537, -1117],
  [4, -1, 0, 0, 520, -1571],
  [1, 0, -2, 0, -487, -1739],
  [2, 1, 0, -2, -399, 0],
  [0, 0, 2, -2, -381, -4421],
  [1, 1, 1, 0, 351, 0],
  [3, 0, -2, 0, -340, 0],
  [4, 0, -3, 0, 330, 0],
  [2, -1, 2, 0, 327, 0],
  [0, 2, 1, 0, -323, 1165],
  [1, 1, -1, 0, 299, 0],
  [2, 0, 3, 0, 294, 0],
  [2, 0, -1, -2, 0, 8752],
];

// Periodic terms for latitude (Σb), Meeus table 47.B.
// Columns: D, M, M', F, coefficient of sine (1e-6 deg).
const List<List<int>> _bTerms = [
  [0, 0, 0, 1, 5128122],
  [0, 0, 1, 1, 280602],
  [0, 0, 1, -1, 277693],
  [2, 0, 0, -1, 173237],
  [2, 0, -1, 1, 55413],
  [2, 0, -1, -1, 46271],
  [2, 0, 0, 1, 32573],
  [0, 0, 2, 1, 17198],
  [2, 0, 1, -1, 9266],
  [0, 0, 2, -1, 8822],
  [2, -1, 0, -1, 8216],
  [2, 0, -2, -1, 4324],
  [2, 0, 1, 1, 4200],
  [2, 1, 0, -1, -3359],
  [2, -1, -1, 1, 2463],
  [2, -1, 0, 1, 2211],
  [2, -1, -1, -1, 2065],
  [0, 1, -1, -1, -1870],
  [4, 0, -1, -1, 1828],
  [0, 1, 0, 1, -1794],
  [0, 0, 0, 3, -1749],
  [0, 1, -1, 1, -1565],
  [1, 0, 0, 1, -1491],
  [0, 1, 1, 1, -1475],
  [0, 1, 1, -1, -1410],
  [0, 1, 0, -1, -1344],
  [1, 0, 0, -1, -1335],
  [0, 0, 3, 1, 1107],
  [4, 0, 0, -1, 1021],
  [4, 0, -1, 1, 833],
  [0, 0, 1, -3, 777],
  [4, 0, -2, 1, 671],
  [2, 0, 0, -3, 607],
  [2, 0, 2, -1, 596],
  [2, -1, 1, -1, 491],
  [2, 0, -2, 1, -451],
  [0, 0, 3, -1, 439],
  [2, 0, 2, 1, 422],
  [2, 0, -3, -1, 421],
  [2, 1, -1, 1, -366],
  [2, 1, 0, 1, -351],
  [4, 0, 0, 1, 331],
  [2, -1, 1, 1, 315],
  [2, -2, 0, -1, 302],
  [0, 0, 1, 3, -283],
  [2, 1, 1, -1, -229],
  [1, 1, 0, -1, 223],
  [1, 1, 0, 1, 223],
  [0, 1, -2, -1, -220],
  [2, 1, -1, -1, -220],
  [1, 0, 1, 1, -185],
  [2, -1, -2, -1, 181],
  [0, 1, 2, 1, -177],
  [4, 0, -2, -1, 176],
  [4, -1, -1, -1, 166],
  [1, 0, 1, -1, -164],
  [4, 0, 1, -1, 132],
  [1, 0, -1, -1, -119],
  [4, -1, 0, -1, 115],
  [2, -2, 0, 1, 107],
];

/// Position of the Moon for a Julian Ephemeris Day (TT).
MoonPosition moonPositionAtJde(double jde) {
  final t = julianCenturies(jde);
  final t2 = t * t;
  final t3 = t2 * t;
  final t4 = t3 * t;

  // Fundamental arguments (Meeus eqs. 47.1 to 47.5).
  final lp = normalizeDegrees(
    218.3164477 +
        481267.88123421 * t -
        0.0015786 * t2 +
        t3 / 538841.0 -
        t4 / 65194000.0,
  );
  final d = normalizeDegrees(
    297.8501921 +
        445267.1114034 * t -
        0.0018819 * t2 +
        t3 / 545868.0 -
        t4 / 113065000.0,
  );
  final m = normalizeDegrees(
    357.5291092 + 35999.0502909 * t - 0.0001536 * t2 + t3 / 24490000.0,
  );
  final mp = normalizeDegrees(
    134.9633964 +
        477198.8675055 * t +
        0.0087414 * t2 +
        t3 / 69699.0 -
        t4 / 14712000.0,
  );
  final f = normalizeDegrees(
    93.2720950 +
        483202.0175233 * t -
        0.0036539 * t2 -
        t3 / 3526000.0 +
        t4 / 863310000.0,
  );

  final a1 = normalizeDegrees(119.75 + 131.849 * t);
  final a2 = normalizeDegrees(53.09 + 479264.290 * t);
  final a3 = normalizeDegrees(313.45 + 481266.484 * t);
  final e = 1 - 0.002516 * t - 0.0000074 * t2;

  double eFactor(int mCoeff) => switch (mCoeff.abs()) {
    1 => e,
    2 => e * e,
    _ => 1.0,
  };

  var sumL = 0.0;
  var sumR = 0.0;
  for (final term in _lrTerms) {
    final arg = term[0] * d + term[1] * m + term[2] * mp + term[3] * f;
    final k = eFactor(term[1]);
    sumL += term[4] * k * sinDeg(arg);
    sumR += term[5] * k * cosDeg(arg);
  }

  var sumB = 0.0;
  for (final term in _bTerms) {
    final arg = term[0] * d + term[1] * m + term[2] * mp + term[3] * f;
    sumB += term[4] * eFactor(term[1]) * sinDeg(arg);
  }

  // Additive terms for Venus, Jupiter and the flattening of the Earth.
  sumL += 3958 * sinDeg(a1) + 1962 * sinDeg(lp - f) + 318 * sinDeg(a2);
  sumB +=
      -2235 * sinDeg(lp) +
      382 * sinDeg(a3) +
      175 * sinDeg(a1 - f) +
      175 * sinDeg(a1 + f) +
      127 * sinDeg(lp - mp) -
      115 * sinDeg(lp + mp);

  final longitude = normalizeDegrees(lp + sumL / 1e6);
  final latitude = sumB / 1e6;
  final distance = 385000.56 + sumR / 1000.0;

  final nut = nutation(t);
  final apparentLongitude = normalizeDegrees(longitude + nut.dPsi);
  final obliquity = meanObliquity(t) + nut.dEps;

  return MoonPosition(
    longitude: longitude,
    latitude: latitude,
    distanceKm: distance,
    apparentLongitude: apparentLongitude,
    obliquity: obliquity,
    equatorial: eclipticToEquatorial(apparentLongitude, latitude, obliquity),
  );
}

/// Position of the Moon at a UTC instant.
MoonPosition moonPositionAt(DateTime time) =>
    moonPositionAtJde(julianEphemerisDay(time));
