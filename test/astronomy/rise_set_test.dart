// Moonrise and moonset checked against PyEphem 4.1 (upper limb on the
// horizon, standard refraction), which agrees with the USNO tables to the
// minute. Local days use a fixed UTC offset.
import 'package:flutter_test/flutter_test.dart';
import 'package:moon_cycle/core/astronomy/astronomy.dart';

const _places = {
  'Kinshasa': GeoLocation(latitude: -4.3217, longitude: 15.3125),
  'Paris': GeoLocation(latitude: 48.8566, longitude: 2.3522),
  'New York': GeoLocation(latitude: 40.7128, longitude: -74.0060),
  'Sydney': GeoLocation(latitude: -33.8688, longitude: 151.2093),
  'Tromso': GeoLocation(latitude: 69.6492, longitude: 18.9553),
};

// Place, local date, UTC offset in hours, rise (UTC), set (UTC).
const _references = [
  ('Kinshasa', 2024, 1, 15, 1, '2024-01-15T08:39:16Z', '2024-01-15T21:06:32Z'),
  ('Kinshasa', 2025, 3, 14, 1, '2025-03-14T17:25:31Z', '2025-03-14T05:04:18Z'),
  ('Kinshasa', 2025, 9, 21, 1, '2025-09-21T04:25:35Z', '2025-09-21T16:44:33Z'),
  ('Kinshasa', 2026, 6, 1, 1, '2026-06-01T17:52:10Z', '2026-06-01T05:45:07Z'),
  ('Kinshasa', 2026, 10, 21, 1, '2026-10-21T13:04:39Z', '2026-10-21T00:50:09Z'),
  ('Paris', 2024, 1, 15, 1, '2024-01-15T10:07:59Z', '2024-01-15T21:41:51Z'),
  ('Paris', 2025, 3, 14, 1, '2025-03-14T18:19:06Z', '2025-03-14T06:11:59Z'),
  ('Paris', 2025, 9, 21, 1, '2025-09-21T05:03:08Z', '2025-09-21T17:37:57Z'),
  ('Paris', 2026, 6, 1, 1, '2026-06-01T21:30:36Z', '2026-06-01T03:55:22Z'),
  ('Paris', 2026, 10, 21, 1, '2026-10-21T14:53:36Z', '2026-10-21T00:30:47Z'),
  ('New York', 2024, 1, 15, -5, '2024-01-15T15:10:36Z', '2024-01-16T03:07:22Z'),
  ('New York', 2025, 3, 14, -5, '2025-03-14T23:37:18Z', '2025-03-14T11:18:09Z'),
  ('New York', 2025, 9, 21, -5, '2025-09-21T10:25:41Z', '2025-09-21T22:47:31Z'),
  ('New York', 2026, 6, 1, -5, '2026-06-02T02:04:04Z', '2026-06-01T09:53:05Z'),
  (
    'New York',
    2026,
    10,
    21,
    -5,
    '2026-10-21T19:50:58Z',
    '2026-10-21T06:07:31Z',
  ),
  ('Sydney', 2024, 1, 15, 10, '2024-01-14T22:51:00Z', '2024-01-15T12:00:40Z'),
  ('Sydney', 2025, 3, 14, 10, '2025-03-14T08:13:33Z', '2025-03-13T19:31:26Z'),
  ('Sydney', 2025, 9, 21, 10, '2025-09-20T19:20:44Z', '2025-09-21T07:18:22Z'),
  ('Sydney', 2026, 6, 1, 10, '2026-06-01T07:12:33Z', '2026-05-31T21:37:42Z'),
  ('Sydney', 2026, 10, 21, 10, '2026-10-21T03:10:07Z', '2026-10-20T16:10:17Z'),
  ('Tromso', 2024, 1, 15, 1, '2024-01-15T09:46:25Z', '2024-01-15T20:04:17Z'),
  ('Tromso', 2025, 3, 14, 1, '2025-03-14T17:08:20Z', '2025-03-14T05:24:04Z'),
  ('Tromso', 2025, 9, 21, 1, '2025-09-21T03:30:34Z', '2025-09-21T16:32:32Z'),
  ('Tromso', 2026, 10, 21, 1, '2026-10-21T15:00:40Z', null),
];

void main() {
  const calc = MoonCalculator();

  void expectNear(DateTime? actual, String? expected) {
    if (expected == null) {
      expect(actual, isNull);
      return;
    }
    expect(actual, isNotNull);
    final error = actual!.difference(DateTime.parse(expected)).inSeconds.abs();
    expect(error, lessThanOrEqualTo(60), reason: 'got $actual, want $expected');
  }

  for (final (place, y, m, d, offset, rise, set) in _references) {
    test('$place $y-$m-$d', () {
      final result = calc.riseSet(
        year: y,
        month: m,
        day: d,
        location: _places[place]!,
        utcOffset: Duration(hours: offset),
      );
      expectNear(result.rise, rise);
      expectNear(result.set, set);
      expect(result.alwaysUp, isFalse);
      expect(result.alwaysDown, isFalse);
    });
  }

  test('polar day without the Moon: Tromso 2026-06-01', () {
    final result = calc.riseSet(
      year: 2026,
      month: 6,
      day: 1,
      location: _places['Tromso']!,
      utcOffset: const Duration(hours: 1),
    );
    expect(result.rise, isNull);
    expect(result.set, isNull);
    expect(result.alwaysDown, isTrue);
  });

  test('the Moon is high at its upper transit and low at rise', () {
    final kinshasa = _places['Kinshasa']!;
    final rise = DateTime.parse('2025-09-21T04:25:35Z');
    final atRise = calc.stateAt(rise, location: kinshasa).horizontal!;
    expect(atRise.altitude, closeTo(0.0, 1.0));
    expect(atRise.azimuth, inInclusiveRange(45, 135)); // rises in the east
  });
}
