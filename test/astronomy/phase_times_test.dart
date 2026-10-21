// Principal phase times checked against published tables.
//
// Reference: NASA GSFC "Six Millennium Catalog of Phases of the Moon"
// (Espenak) and the USNO phases of the Moon tables, both given to the
// minute in UTC. Each value was also confirmed with PyEphem 4.1, which uses
// an independent lunar theory, to the minute.
import 'package:flutter_test/flutter_test.dart';
import 'package:moon_cycle/core/astronomy/astronomy.dart';

void main() {
  const calc = MoonCalculator();

  final published = <(PrincipalPhase, DateTime)>[
    (PrincipalPhase.lastQuarter, DateTime.utc(2024, 1, 4, 3, 30)),
    (PrincipalPhase.newMoon, DateTime.utc(2024, 1, 11, 11, 57)),
    (PrincipalPhase.firstQuarter, DateTime.utc(2024, 1, 18, 3, 53)),
    (PrincipalPhase.fullMoon, DateTime.utc(2024, 1, 25, 17, 54)),
    // Total solar eclipse.
    (PrincipalPhase.newMoon, DateTime.utc(2024, 4, 8, 18, 21)),
    (PrincipalPhase.fullMoon, DateTime.utc(2024, 9, 18, 2, 34)),
    // Total lunar eclipse.
    (PrincipalPhase.fullMoon, DateTime.utc(2025, 3, 14, 6, 55)),
    (PrincipalPhase.lastQuarter, DateTime.utc(2025, 3, 22, 11, 29)),
    (PrincipalPhase.newMoon, DateTime.utc(2025, 3, 29, 10, 58)),
    (PrincipalPhase.fullMoon, DateTime.utc(2025, 9, 7, 18, 9)),
    (PrincipalPhase.newMoon, DateTime.utc(2025, 9, 21, 19, 54)),
    (PrincipalPhase.newMoon, DateTime.utc(2026, 2, 17, 12, 1)),
    (PrincipalPhase.fullMoon, DateTime.utc(2026, 3, 3, 11, 38)),
    (PrincipalPhase.newMoon, DateTime.utc(2026, 8, 12, 17, 37)),
    (PrincipalPhase.fullMoon, DateTime.utc(2026, 8, 28, 4, 18)),
  ];

  for (final (phase, expected) in published) {
    test('${phase.name} at ${expected.toIso8601String()}', () {
      final event = calc.nextPhase(
        expected.subtract(const Duration(days: 2)),
        phase: phase,
      );
      final error = event.time.difference(expected).inSeconds.abs();
      // Published times are rounded to the minute.
      expect(error, lessThanOrEqualTo(60), reason: 'got ${event.time}');
    });
  }

  test('2026 has 13 full moons, with a blue moon on May 31', () {
    final fulls = calc
        .phasesBetween(DateTime.utc(2026), DateTime.utc(2027))
        .where((e) => e.phase == PrincipalPhase.fullMoon)
        .toList();
    expect(fulls, hasLength(13));
    final may = fulls.where((e) => e.time.month == 5).toList();
    expect(may.map((e) => e.time.day), [1, 31]);
  });

  test('phases cycle in order and are spaced about a week apart', () {
    final events = calc.phasesBetween(DateTime.utc(1990), DateTime.utc(2060));
    for (var i = 1; i < events.length; i++) {
      expect(events[i].phase.index, (events[i - 1].phase.index + 1) % 4);
      final gap = events[i].time.difference(events[i - 1].time).inHours;
      expect(gap, inInclusiveRange(140, 214));
    }
  });

  test('phasesBetween includes start and excludes end', () {
    final full = DateTime.utc(2025, 3, 14, 6, 54, 35);
    final event = calc.nextPhase(full.subtract(const Duration(hours: 1)));
    expect(
      calc.phasesBetween(
        event.time,
        event.time.add(const Duration(seconds: 1)),
      ),
      [event],
    );
    expect(
      calc.phasesBetween(
        event.time.subtract(const Duration(days: 1)),
        event.time,
      ),
      isEmpty,
    );
  });

  test('previousPhase and nextPhase bracket an instant', () {
    final now = DateTime.utc(2026, 10, 21, 22);
    final prev = calc.previousPhase(now);
    final next = calc.nextPhase(now);
    expect(prev.time.isAfter(now), isFalse);
    expect(next.time.isAfter(now), isTrue);
    expect(next.phase.index, (prev.phase.index + 1) % 4);
  });
}
