import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/astronomy/astronomy.dart';
import '../location/location_controller.dart';

/// The current time, updated every minute so the live view stays current.
class Clock extends Notifier<DateTime> {
  @override
  DateTime build() {
    final timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => state = DateTime.now(),
    );
    ref.onDispose(timer.cancel);
    return DateTime.now();
  }

  /// Catches up after the app comes back from the background.
  void refresh() => state = DateTime.now();
}

final clockProvider = NotifierProvider<Clock, DateTime>(Clock.new);

/// How far from now the user has moved the view. Zero means live.
class ViewOffset extends Notifier<Duration> {
  @override
  Duration build() => Duration.zero;

  void shiftBy(Duration delta) => state += delta;

  /// Moves a whole calendar day, keeping the time of day.
  void shiftDays(int days) => state += Duration(days: days);

  void reset() => state = Duration.zero;
}

final viewOffsetProvider = NotifierProvider<ViewOffset, Duration>(
  ViewOffset.new,
);

/// The instant the moon screen shows, in local time.
final viewTimeProvider = Provider<DateTime>(
  (ref) =>
      ref.watch(clockProvider).add(ref.watch(viewOffsetProvider)).toLocal(),
);

final moonCalculatorProvider = Provider<MoonCalculator>(
  (ref) => const MoonCalculator(),
);

/// A local calendar day, with the UTC offset in force on it.
typedef LocalDay = ({int year, int month, int day, Duration utcOffset});

final viewDayProvider = Provider<LocalDay>((ref) {
  final t = ref.watch(viewTimeProvider);
  return (
    year: t.year,
    month: t.month,
    day: t.day,
    utcOffset: t.timeZoneOffset,
  );
});

/// Everything the moon screen needs for the instant being viewed.
class MoonView {
  const MoonView({
    required this.time,
    required this.isLive,
    required this.state,
    required this.location,
    required this.riseSet,
    required this.upcoming,
  });

  final DateTime time;

  /// True when showing the present moment rather than a chosen time.
  final bool isLive;

  final MoonState state;
  final GeoLocation? location;

  /// Moonrise and moonset on the viewed local day; null without a location.
  final MoonRiseSet? riseSet;

  /// The next new moon, first quarter, full moon and last quarter after
  /// [time], soonest first.
  final List<LunarPhaseEvent> upcoming;

  /// The Moon looks upside down from the southern hemisphere.
  bool get viewedFromSouth => location?.isSouthernHemisphere ?? false;

  /// How far to turn a north-up picture of the Moon, clockwise in degrees,
  /// so it sits as it does in the user's sky with the zenith at the top:
  /// the parallactic angle. Zero, north up, without a location.
  double get skyRotation => state.horizontal?.parallacticAngle ?? 0;
}

/// Moonrise and moonset, cached per day and place while scrubbing.
final _riseSetProvider = Provider<MoonRiseSet?>((ref) {
  final location = ref.watch(locationProvider.select((s) => s.location));
  if (location == null) return null;
  final day = ref.watch(viewDayProvider);
  return ref
      .watch(moonCalculatorProvider)
      .riseSet(
        year: day.year,
        month: day.month,
        day: day.day,
        location: location,
        utcOffset: day.utcOffset,
      );
});

final moonViewProvider = Provider<MoonView>((ref) {
  final calc = ref.watch(moonCalculatorProvider);
  final time = ref.watch(viewTimeProvider);
  final location = ref.watch(locationProvider.select((s) => s.location));
  final upcoming = [
    for (final phase in PrincipalPhase.values)
      calc.nextPhase(time, phase: phase),
  ]..sort((a, b) => a.time.compareTo(b.time));

  return MoonView(
    time: time,
    isLive: ref.watch(viewOffsetProvider) == Duration.zero,
    state: calc.stateAt(time, location: location),
    location: location,
    riseSet: ref.watch(_riseSetProvider),
    upcoming: upcoming,
  );
});
