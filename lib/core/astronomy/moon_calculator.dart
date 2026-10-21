import 'astro_math.dart';
import 'geo_location.dart';
import 'lunar_phases.dart' hide nextPhase, phasesBetween, previousPhase;
import 'lunar_phases.dart'
    as lunar
    show nextPhase, phasesBetween, previousPhase;
import 'moon_illumination.dart';
import 'moon_position.dart';
import 'moon_rise_set.dart';
import 'sun_position.dart';

/// The eight phase names shown to people.
enum MoonPhaseName {
  newMoon,
  waxingCrescent,
  firstQuarter,
  waxingGibbous,
  fullMoon,
  waningGibbous,
  lastQuarter,
  waningCrescent;

  bool get isPrincipal => index.isEven;

  /// The name for a position in the cycle, from the Sun–Moon elongation.
  ///
  /// A principal phase is an instant, so its name only covers the Moon's
  /// motion during about half a day either side of it (±6° of elongation;
  /// the Moon gains about 12.2° a day on the Sun).
  static MoonPhaseName fromElongation(double elongation) {
    const window = 6.0;
    final e = normalizeDegrees(elongation);
    if (e < window || e >= 360 - window) return newMoon;
    if ((e - 90).abs() < window) return firstQuarter;
    if ((e - 180).abs() < window) return fullMoon;
    if ((e - 270).abs() < window) return lastQuarter;
    if (e < 90) return waxingCrescent;
    if (e < 180) return waxingGibbous;
    if (e < 270) return waningGibbous;
    return waningCrescent;
  }

  static MoonPhaseName fromPrincipal(PrincipalPhase phase) => switch (phase) {
    PrincipalPhase.newMoon => newMoon,
    PrincipalPhase.firstQuarter => firstQuarter,
    PrincipalPhase.fullMoon => fullMoon,
    PrincipalPhase.lastQuarter => lastQuarter,
  };
}

/// Everything the app shows about the Moon at one instant.
class MoonState {
  const MoonState({
    required this.time,
    required this.phaseName,
    required this.illumination,
    required this.age,
    required this.lunationFraction,
    required this.previousNewMoon,
    required this.nextNewMoon,
    required this.distanceKm,
    required this.angularDiameter,
    this.horizontal,
  });

  final DateTime time;
  final MoonPhaseName phaseName;
  final MoonIllumination illumination;

  /// Time since the previous new moon.
  final Duration age;

  /// Position in the current lunation, from 0 at new moon to 1 at the next.
  final double lunationFraction;

  final DateTime previousNewMoon;
  final DateTime nextNewMoon;

  /// Distance between the centres of the Earth and the Moon, in km.
  final double distanceKm;

  /// Apparent diameter of the Moon, in degrees.
  final double angularDiameter;

  /// The Moon's place in the observer's sky, when a location was given.
  final HorizontalPosition? horizontal;

  /// Illuminated fraction of the disc, from 0 to 1.
  double get illuminatedFraction => illumination.fraction;

  bool get isWaxing => illumination.isWaxing;

  /// Age in days, with a fraction.
  double get ageInDays => age.inMilliseconds / Duration.millisecondsPerDay;

  /// Angle of the bright limb measured from the observer's zenith rather
  /// than from celestial north, in degrees. This is how the lit side is
  /// tilted in the observer's sky, and it already accounts for the
  /// hemisphere. Null without a location.
  double? get brightLimbZenithAngle => horizontal == null
      ? null
      : normalizeDegrees(
          illumination.brightLimbAngle - horizontal!.parallacticAngle,
        );
}

/// Offline lunar calculations. All inputs and outputs are UTC instants.
class MoonCalculator {
  const MoonCalculator();

  /// The Moon's state at [time], with sky position when [location] is given.
  MoonState stateAt(DateTime time, {GeoLocation? location}) {
    final utc = time.toUtc();
    final jde = julianEphemerisDay(utc);
    final moon = moonPositionAtJde(jde);
    final sun = sunPositionAtJde(jde);
    final illumination = moonIllumination(moon, sun);

    final previousNew = lunar.previousPhase(utc, phase: PrincipalPhase.newMoon);
    final nextNew = lunar.nextPhase(utc, phase: PrincipalPhase.newMoon);
    final age = utc.difference(previousNew.time);
    final length = nextNew.time.difference(previousNew.time);

    return MoonState(
      time: utc,
      phaseName: MoonPhaseName.fromElongation(illumination.elongation),
      illumination: illumination,
      age: age,
      lunationFraction: age.inMilliseconds / length.inMilliseconds,
      previousNewMoon: previousNew.time,
      nextNewMoon: nextNew.time,
      distanceKm: moon.distanceKm,
      angularDiameter: 2 * moon.semiDiameter,
      horizontal: location == null
          ? null
          : moonHorizontalPosition(utc, location),
    );
  }

  /// Principal phases with `start <= time < end`, in time order.
  List<LunarPhaseEvent> phasesBetween(DateTime start, DateTime end) =>
      lunar.phasesBetween(start.toUtc(), end.toUtc());

  /// The first principal phase after [time], optionally of one kind.
  LunarPhaseEvent nextPhase(DateTime time, {PrincipalPhase? phase}) =>
      lunar.nextPhase(time.toUtc(), phase: phase);

  /// The last principal phase at or before [time], optionally of one kind.
  LunarPhaseEvent previousPhase(DateTime time, {PrincipalPhase? phase}) =>
      lunar.previousPhase(time.toUtc(), phase: phase);

  /// Moonrise and moonset during the local calendar day [year]-[month]-[day]
  /// at [location], where local time is UTC plus [utcOffset].
  MoonRiseSet riseSet({
    required int year,
    required int month,
    required int day,
    required GeoLocation location,
    required Duration utcOffset,
  }) => moonRiseSet(_localMidnightUtc(year, month, day, utcOffset), location);

  /// The phase name to show for a whole local calendar day, as calendars do:
  /// a principal phase when its exact instant falls within that day,
  /// otherwise the intermediate phase at local noon.
  MoonPhaseName phaseNameForDay({
    required int year,
    required int month,
    required int day,
    required Duration utcOffset,
  }) {
    final start = _localMidnightUtc(year, month, day, utcOffset);
    final events = lunar.phasesBetween(
      start,
      start.add(const Duration(days: 1)),
    );
    if (events.isNotEmpty)
      return MoonPhaseName.fromPrincipal(events.first.phase);

    final noon = start.add(const Duration(hours: 12));
    final jde = julianEphemerisDay(noon);
    final elongation = moonIllumination(
      moonPositionAtJde(jde),
      sunPositionAtJde(jde),
    ).elongation;
    if (elongation < 90) return MoonPhaseName.waxingCrescent;
    if (elongation < 180) return MoonPhaseName.waxingGibbous;
    if (elongation < 270) return MoonPhaseName.waningGibbous;
    return MoonPhaseName.waningCrescent;
  }

  static DateTime _localMidnightUtc(
    int year,
    int month,
    int day,
    Duration utcOffset,
  ) => DateTime.utc(year, month, day).subtract(utcOffset);
}
