/// Instants of the principal lunar phases (Meeus ch. 49).
///
/// Meeus gives the error of this method as a few seconds, and never more than
/// about 17 seconds, against the full ELP-2000/82 theory.
library;

import 'astro_math.dart';

/// The four principal phases, the instants the app announces.
enum PrincipalPhase {
  newMoon(0.0),
  firstQuarter(0.25),
  fullMoon(0.5),
  lastQuarter(0.75);

  const PrincipalPhase(this.fraction);

  /// Fraction of a lunation at which this phase occurs.
  final double fraction;

  static PrincipalPhase fromFraction(double fraction) =>
      values.firstWhere((p) => (p.fraction - fraction).abs() < 1e-6);
}

/// One occurrence of a principal phase.
class LunarPhaseEvent {
  const LunarPhaseEvent({
    required this.phase,
    required this.time,
    required this.lunation,
  });

  final PrincipalPhase phase;

  /// The exact instant, in UTC.
  final DateTime time;

  /// Meeus lunation number: 0 is the new moon of 2000 January 6, and each
  /// lunation counts up from its new moon.
  final int lunation;

  @override
  bool operator ==(Object other) =>
      other is LunarPhaseEvent &&
      other.phase == phase &&
      other.time == time &&
      other.lunation == lunation;

  @override
  int get hashCode => Object.hash(phase, time, lunation);

  @override
  String toString() =>
      'LunarPhaseEvent(${phase.name}, ${time.toIso8601String()})';
}

/// Mean length of a synodic month, in days.
const double synodicMonth = 29.530588861;

const double _epochJde = 2451550.09766;

/// Julian Ephemeris Day of a principal phase.
///
/// [k] is an integer for a new moon, and adds 0.25, 0.5 or 0.75 for the first
/// quarter, full moon and last quarter of the same lunation.
double phaseJde(double k) {
  final t = k / 1236.85;
  final t2 = t * t;
  final t3 = t2 * t;
  final t4 = t3 * t;

  var jde =
      _epochJde +
      synodicMonth * k +
      0.00015437 * t2 -
      0.000000150 * t3 +
      0.00000000073 * t4;

  final e = 1 - 0.002516 * t - 0.0000074 * t2;
  final e2 = e * e;
  final m = normalizeDegrees(
    2.5534 + 29.10535670 * k - 0.0000014 * t2 - 0.00000011 * t3,
  );
  final mp = normalizeDegrees(
    201.5643 +
        385.81693528 * k +
        0.0107582 * t2 +
        0.00001238 * t3 -
        0.000000058 * t4,
  );
  final f = normalizeDegrees(
    160.7108 +
        390.67050284 * k -
        0.0016118 * t2 -
        0.00000227 * t3 +
        0.000000011 * t4,
  );
  final omega = normalizeDegrees(
    124.7746 - 1.56375588 * k + 0.0020672 * t2 + 0.00000215 * t3,
  );

  final fraction = k - k.floorToDouble();
  final phase = PrincipalPhase.fromFraction(fraction);

  double s(double deg) => sinDeg(deg);

  // The small terms shared by new and full moon.
  double sharedSmallTerms() =>
      -0.00007 * s(mp + 2 * m) +
      0.00004 * s(2 * mp - 2 * f) +
      0.00004 * s(3 * m) +
      0.00003 * s(mp + m - 2 * f) +
      0.00003 * s(2 * mp + 2 * f) -
      0.00003 * s(mp + m + 2 * f) +
      0.00003 * s(mp - m + 2 * f) -
      0.00002 * s(mp - m - 2 * f) -
      0.00002 * s(3 * mp + m) +
      0.00002 * s(4 * mp);

  switch (phase) {
    case PrincipalPhase.newMoon:
      jde +=
          -0.40720 * s(mp) +
          0.17241 * e * s(m) +
          0.01608 * s(2 * mp) +
          0.01039 * s(2 * f) +
          0.00739 * e * s(mp - m) -
          0.00514 * e * s(mp + m) +
          0.00208 * e2 * s(2 * m) -
          0.00111 * s(mp - 2 * f) -
          0.00057 * s(mp + 2 * f) +
          0.00056 * e * s(2 * mp + m) -
          0.00042 * s(3 * mp) +
          0.00042 * e * s(m + 2 * f) +
          0.00038 * e * s(m - 2 * f) -
          0.00024 * e * s(2 * mp - m) -
          0.00017 * s(omega) +
          sharedSmallTerms();
    case PrincipalPhase.fullMoon:
      jde +=
          -0.40614 * s(mp) +
          0.17302 * e * s(m) +
          0.01614 * s(2 * mp) +
          0.01043 * s(2 * f) +
          0.00734 * e * s(mp - m) -
          0.00515 * e * s(mp + m) +
          0.00209 * e2 * s(2 * m) -
          0.00111 * s(mp - 2 * f) -
          0.00057 * s(mp + 2 * f) +
          0.00056 * e * s(2 * mp + m) -
          0.00042 * s(3 * mp) +
          0.00042 * e * s(m + 2 * f) +
          0.00038 * e * s(m - 2 * f) -
          0.00024 * e * s(2 * mp - m) -
          0.00017 * s(omega) +
          sharedSmallTerms();
    case PrincipalPhase.firstQuarter:
    case PrincipalPhase.lastQuarter:
      jde +=
          -0.62801 * s(mp) +
          0.17172 * e * s(m) -
          0.01183 * e * s(mp + m) +
          0.00862 * s(2 * mp) +
          0.00804 * s(2 * f) +
          0.00454 * e * s(mp - m) +
          0.00204 * e2 * s(2 * m) -
          0.00180 * s(mp - 2 * f) -
          0.00070 * s(mp + 2 * f) -
          0.00040 * s(3 * mp) -
          0.00034 * e * s(2 * mp - m) +
          0.00032 * e * s(m + 2 * f) +
          0.00032 * e * s(m - 2 * f) -
          0.00028 * e2 * s(mp + 2 * m) +
          0.00027 * e * s(2 * mp + m) -
          0.00017 * s(omega) -
          0.00005 * s(mp - m - 2 * f) +
          0.00004 * s(2 * mp + 2 * f) -
          0.00004 * s(mp + m + 2 * f) +
          0.00004 * s(mp - 2 * m) +
          0.00003 * s(mp + m - 2 * f) +
          0.00003 * s(3 * m) +
          0.00002 * s(2 * mp - 2 * f) +
          0.00002 * s(mp - m + 2 * f) -
          0.00002 * s(3 * mp + m);
      final w =
          0.00306 -
          0.00038 * e * cosDeg(m) +
          0.00026 * cosDeg(mp) -
          0.00002 * cosDeg(mp - m) +
          0.00002 * cosDeg(mp + m) +
          0.00002 * cosDeg(2 * f);
      jde += phase == PrincipalPhase.firstQuarter ? w : -w;
  }

  // Planetary arguments, common to all phases.
  const coefficients = [
    325, 165, 164, 126, 110, 62, 60, 56, 47, 42, 40, 37, 35, 23, //
  ];
  final args = [
    299.77 + 0.107408 * k - 0.009173 * t2,
    251.88 + 0.016321 * k,
    251.83 + 26.651886 * k,
    349.42 + 36.412478 * k,
    84.66 + 18.206239 * k,
    141.74 + 53.303771 * k,
    207.14 + 2.453732 * k,
    154.84 + 7.306860 * k,
    34.52 + 27.261239 * k,
    207.19 + 0.121824 * k,
    291.34 + 1.844379 * k,
    161.72 + 24.198154 * k,
    239.56 + 25.513099 * k,
    331.55 + 3.592518 * k,
  ];
  for (var i = 0; i < args.length; i++) {
    jde += coefficients[i] * 1e-6 * s(args[i]);
  }

  return jde;
}

/// The principal phase for lunation number [k] plus [phase], as a UTC event.
LunarPhaseEvent phaseEvent(int lunation, PrincipalPhase phase) =>
    LunarPhaseEvent(
      phase: phase,
      time: dateTimeFromJulianEphemerisDay(phaseJde(lunation + phase.fraction)),
      lunation: lunation,
    );

/// All principal phases with `start <= time < end`, in time order.
List<LunarPhaseEvent> phasesBetween(DateTime start, DateTime end) {
  final events = <LunarPhaseEvent>[];
  if (!end.isAfter(start)) return events;
  // Start one lunation early: the mean phase can differ from the true phase
  // by more than half a day.
  var lunation =
      ((julianEphemerisDay(start) - _epochJde) / synodicMonth).floor() - 1;
  while (true) {
    for (final phase in PrincipalPhase.values) {
      final event = phaseEvent(lunation, phase);
      if (!event.time.isBefore(end)) return events;
      if (!event.time.isBefore(start)) events.add(event);
    }
    lunation++;
  }
}

/// The first principal phase strictly after [time], optionally of one kind.
LunarPhaseEvent nextPhase(DateTime time, {PrincipalPhase? phase}) {
  var lunation =
      ((julianEphemerisDay(time) - _epochJde) / synodicMonth).floor() - 1;
  while (true) {
    for (final p in PrincipalPhase.values) {
      if (phase != null && p != phase) continue;
      final event = phaseEvent(lunation, p);
      if (event.time.isAfter(time)) return event;
    }
    lunation++;
  }
}

/// The last principal phase at or before [time], optionally of one kind.
LunarPhaseEvent previousPhase(DateTime time, {PrincipalPhase? phase}) {
  var lunation =
      ((julianEphemerisDay(time) - _epochJde) / synodicMonth).floor() + 1;
  while (true) {
    for (final p in PrincipalPhase.values.reversed) {
      if (phase != null && p != phase) continue;
      final event = phaseEvent(lunation, p);
      if (!event.time.isAfter(time)) return event;
    }
    lunation--;
  }
}
