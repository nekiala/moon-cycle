import 'package:flutter_test/flutter_test.dart';
import 'package:moon_cycle/core/astronomy/astronomy.dart';

void main() {
  const calc = MoonCalculator();

  // Illuminated fraction and distance from PyEphem 4.1 at the same instants.
  final references = <(DateTime, double, double)>[
    (DateTime.utc(2024, 1, 1), 0.77993, 404668),
    (DateTime.utc(2024, 6, 15, 12), 0.62174, 403523),
    (DateTime.utc(2025, 3, 14, 6, 55), 1.0, 401500),
    (DateTime.utc(2025, 11, 5, 13, 19), 0.99866, 356978),
    (DateTime.utc(2026, 10, 21, 21), 0.79442, 390176),
  ];

  for (final (time, fraction, distance) in references) {
    test('illumination and distance at ${time.toIso8601String()}', () {
      final state = calc.stateAt(time);
      expect(state.illuminatedFraction, closeTo(fraction, 0.002));
      expect(state.distanceKm, closeTo(distance, 30));
    });
  }

  test('age and lunation fraction', () {
    // New moon 2025 September 21, 19:54 UTC; next 2025 October 21, 12:25.
    final state = calc.stateAt(DateTime.utc(2025, 9, 28, 19, 54));
    expect(state.ageInDays, closeTo(7.0, 0.01));
    expect(
      state.previousNewMoon
          .difference(DateTime.utc(2025, 9, 21, 19, 54))
          .inMinutes
          .abs(),
      lessThanOrEqualTo(1),
    );
    expect(state.lunationFraction, closeTo(7.0 / 29.69, 0.01));
    expect(state.isWaxing, isTrue);
    expect(state.phaseName, MoonPhaseName.waxingCrescent);
  });

  test('phase names around a full moon', () {
    final full = DateTime.utc(2025, 3, 14, 6, 55);
    expect(calc.stateAt(full).phaseName, MoonPhaseName.fullMoon);
    expect(
      calc.stateAt(full.subtract(const Duration(days: 3))).phaseName,
      MoonPhaseName.waxingGibbous,
    );
    expect(
      calc.stateAt(full.add(const Duration(days: 3))).phaseName,
      MoonPhaseName.waningGibbous,
    );
  });

  test('bright limb points west while waxing and east while waning', () {
    final waxing = calc.stateAt(DateTime.utc(2025, 9, 25));
    final waning = calc.stateAt(DateTime.utc(2025, 10, 15));
    expect(waxing.illumination.brightLimbAngle, inInclusiveRange(225, 315));
    expect(waning.illumination.brightLimbAngle, inInclusiveRange(45, 135));
  });

  test('the lit side tilts the other way in the southern hemisphere', () {
    // An evening crescent, seen from Paris and from Sydney.
    const paris = GeoLocation(latitude: 48.8566, longitude: 2.3522);
    const sydney = GeoLocation(latitude: -33.8688, longitude: 151.2093);
    final north = calc.stateAt(DateTime.utc(2025, 9, 25, 18), location: paris);
    final south = calc.stateAt(DateTime.utc(2025, 9, 25, 9), location: sydney);
    // Measured from the zenith: lit on the right (west) in the north, on the
    // left in the south.
    final n = north.brightLimbZenithAngle!;
    final s = south.brightLimbZenithAngle!;
    expect(n > 180, isTrue, reason: 'north $n');
    expect(s < 180, isTrue, reason: 'south $s');
  });

  group('phase name for a calendar day', () {
    test('the day of the exact full moon', () {
      // Full moon 2025 March 14, 06:55 UTC.
      expect(
        calc.phaseNameForDay(
          year: 2025,
          month: 3,
          day: 14,
          utcOffset: Duration.zero,
        ),
        MoonPhaseName.fullMoon,
      );
      expect(
        calc.phaseNameForDay(
          year: 2025,
          month: 3,
          day: 13,
          utcOffset: Duration.zero,
        ),
        MoonPhaseName.waxingGibbous,
      );
    });

    test('depends on the time zone', () {
      // New moon 2026 February 17, 12:01 UTC is February 18 in Kiribati
      // (UTC+14) but February 17 in Hawaii (UTC-10).
      expect(
        calc.phaseNameForDay(
          year: 2026,
          month: 2,
          day: 18,
          utcOffset: const Duration(hours: 14),
        ),
        MoonPhaseName.newMoon,
      );
      expect(
        calc.phaseNameForDay(
          year: 2026,
          month: 2,
          day: 17,
          utcOffset: const Duration(hours: -10),
        ),
        MoonPhaseName.newMoon,
      );
      expect(
        calc.phaseNameForDay(
          year: 2026,
          month: 2,
          day: 17,
          utcOffset: const Duration(hours: 14),
        ),
        MoonPhaseName.waningCrescent,
      );
    });
  });
}
