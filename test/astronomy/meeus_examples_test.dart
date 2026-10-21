// Worked examples from Jean Meeus, "Astronomical Algorithms", 2nd edition.
import 'package:flutter_test/flutter_test.dart';
import 'package:moon_cycle/core/astronomy/astro_math.dart';
import 'package:moon_cycle/core/astronomy/lunar_phases.dart';
import 'package:moon_cycle/core/astronomy/moon_illumination.dart';
import 'package:moon_cycle/core/astronomy/moon_position.dart';
import 'package:moon_cycle/core/astronomy/sun_position.dart';

void main() {
  group('Julian Day (ch. 7)', () {
    test('J2000.0 is 2000 January 1, 12h', () {
      expect(julianDayFromDateTime(DateTime.utc(2000, 1, 1, 12)), 2451545.0);
    });

    test('example 7.a: 1957 October 4.81 is JD 2436116.31', () {
      final sputnik = DateTime.utc(1957, 10, 4).add(
        const Duration(milliseconds: 69984000), // 0.81 day
      );
      expect(julianDayFromDateTime(sputnik), closeTo(2436116.31, 1e-6));
    });

    test('round trip', () {
      final t = DateTime.utc(2026, 10, 21, 21, 52, 57);
      expect(dateTimeFromJulianDay(julianDayFromDateTime(t)), t);
    });
  });

  test('example 12.a: sidereal time 1987 April 10, 0h UT', () {
    // 13h10m46.3668s
    expect(
      greenwichMeanSiderealTime(2446895.5),
      closeTo((13 + 10 / 60 + 46.3668 / 3600) * 15, 1e-5),
    );
  });

  test('example 22.a: nutation and obliquity 1987 April 10', () {
    final t = julianCenturies(2446895.5);
    final nut = nutation(t);
    expect(nut.dPsi * 3600, closeTo(-3.788, 0.5));
    expect(nut.dEps * 3600, closeTo(9.443, 0.1));
    expect(meanObliquity(t), closeTo(23 + 26 / 60 + 27.407 / 3600, 1e-5));
  });

  test('example 25.a: the Sun on 1992 October 13, 0h TD', () {
    final sun = sunPositionAtJde(2448908.5);
    expect(sun.apparentLongitude, closeTo(199.90895, 0.0005));
    expect(sun.distanceAu, closeTo(0.99766, 0.00001));
    expect(sun.equatorial.rightAscension, closeTo(198.38083, 0.0005));
    expect(sun.equatorial.declination, closeTo(-7.78507, 0.0005));
  });

  test('example 47.a: the Moon on 1992 April 12, 0h TD', () {
    final moon = moonPositionAtJde(2448724.5);
    expect(moon.longitude, closeTo(133.162655, 1e-6));
    expect(moon.latitude, closeTo(-3.229126, 1e-6));
    expect(moon.distanceKm, closeTo(368409.7, 0.1));
    expect(moon.horizontalParallax, closeTo(0.991990, 1e-5));
    // Meeus uses the full nutation series; the abridged one is within 0.5″.
    expect(moon.apparentLongitude, closeTo(133.167265, 0.5 / 3600));
    expect(moon.equatorial.rightAscension, closeTo(134.688470, 0.0005));
    expect(moon.equatorial.declination, closeTo(13.768368, 0.0005));
  });

  test('example 48.a: illuminated fraction 1992 April 12, 0h TD', () {
    final ill = moonIllumination(
      moonPositionAtJde(2448724.5),
      sunPositionAtJde(2448724.5),
    );
    expect(ill.phaseAngle, closeTo(69.0756, 0.01));
    expect(ill.fraction, closeTo(0.6786, 0.0005));
    expect(ill.brightLimbAngle, closeTo(285.0, 0.1));
    expect(ill.isWaxing, isTrue);
  });

  group('lunar phases (ch. 49)', () {
    test('example 49.a: new moon of 1977 February', () {
      // 1977 February 18, 3h37m42s TD
      expect(phaseJde(-283), closeTo(2443192.65118, 1e-5));
    });

    test('example 49.b: first last quarter of 2044 January', () {
      // 2044 January 21, 23h47m TD
      expect(phaseJde(544.75), closeTo(2467636.49186, 1e-5));
    });
  });
}
