import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/astronomy/astronomy.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/moon_phase_l10n.dart';
import '../location/location_controller.dart';
import '../location/location_service.dart';
import '../moon/moon_view.dart';
import '../moon/widgets/lunar_cycle_bar.dart';
import '../moon/widgets/moon_disc.dart';

/// The main moon screen: the Moon as it looks now (or at a chosen time),
/// its phase, illumination, age and distance, moonrise and moonset where
/// the user is, and the next principal phases.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final AppLifecycleListener _lifecycle;

  /// Minutes of time travel per logical pixel dragged across the moon.
  static const _minutesPerPixel = 15;
  double _dragRemainder = 0;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.read(clockProvider.notifier).refresh(),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  void _onDrag(DragUpdateDetails details) {
    // Dragging right goes forward in time, like turning a page.
    _dragRemainder += details.delta.dx * _minutesPerPixel;
    final whole = _dragRemainder.truncate();
    if (whole == 0) return;
    _dragRemainder -= whole;
    ref.read(viewOffsetProvider.notifier).shiftBy(Duration(minutes: whole));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final view = ref.watch(moonViewProvider);
    final state = view.state;
    final percent = _percent(context, state.illuminatedFraction);
    final phaseLabel = state.phaseName.label(l10n);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.skyGradient,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                sliver: SliverList.list(
                  children: [
                    const _LocationBar(),
                    const SizedBox(height: 8),
                    _TimeBar(view: view),
                    const SizedBox(height: 8),
                    Center(
                      child: GestureDetector(
                        onHorizontalDragUpdate: _onDrag,
                        onHorizontalDragEnd: (_) => _dragRemainder = 0,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 360),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: MoonDisc(
                              key: const Key('moon-disc'),
                              state: state,
                              rotation: view.skyRotation,
                              semanticLabel: l10n.moonPictureLabel(
                                phaseLabel,
                                percent,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      l10n.dragHint,
                      style: theme.textTheme.labelSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      phaseLabel,
                      style: theme.textTheme.displayMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.illuminationValue(percent),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.gold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    _CycleCard(state: state),
                    const SizedBox(height: 12),
                    _DetailsRow(state: state),
                    const SizedBox(height: 12),
                    _RiseSetCard(view: view),
                    const SizedBox(height: 12),
                    _UpcomingCard(view: view),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _percent(BuildContext context, double fraction) {
  final locale = AppLocalizations.of(context).localeName;
  return NumberFormat.percentPattern(locale).format(fraction);
}

/// Hours and minutes in the user's preferred clock style.
DateFormat _timeFormat(BuildContext context) {
  final locale = AppLocalizations.of(context).localeName;
  return MediaQuery.alwaysUse24HourFormatOf(context)
      ? DateFormat.Hm(locale)
      : DateFormat.jm(locale);
}

class _LocationBar extends ConsumerWidget {
  const _LocationBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final location = ref.watch(locationProvider);

    final label = location.locating
        ? l10n.locating
        : location.location == null
        ? l10n.noLocation
        : formatCoordinates(l10n, location.location!);

    return Row(
      children: [
        Icon(
          Icons.place_outlined,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Expanded(child: Text(label, style: theme.textTheme.labelMedium)),
        if (location.location != null)
          IconButton(
            tooltip: l10n.updateLocation,
            visualDensity: VisualDensity.compact,
            onPressed: location.locating
                ? null
                : () => ref.read(locationProvider.notifier).locate(),
            icon: const Icon(Icons.my_location, size: 18),
          ),
      ],
    );
  }
}

/// "4.32° S · 15.31° E", with the hemisphere letters translated.
String formatCoordinates(AppLocalizations l10n, GeoLocation location) {
  final f = NumberFormat('0.00', l10n.localeName);
  final lat = f.format(location.latitude.abs());
  final lon = f.format(location.longitude.abs());
  return '${location.latitude < 0 ? l10n.latitudeSouth(lat) : l10n.latitudeNorth(lat)}'
      ' · '
      '${location.longitude < 0 ? l10n.longitudeWest(lon) : l10n.longitudeEast(lon)}';
}

class _TimeBar extends ConsumerWidget {
  const _TimeBar({required this.view});

  final MoonView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = l10n.localeName;
    final offset = ref.read(viewOffsetProvider.notifier);
    final date = toBeginningOfSentenceCase(
      DateFormat.MMMEd(locale).format(view.time),
      locale,
    );
    final time = _timeFormat(context).format(view.time);

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              tooltip: l10n.previousDay,
              onPressed: () => offset.shiftDays(-1),
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    view.isLive ? l10n.today : date,
                    key: const Key('view-date'),
                    style: theme.textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    view.isLive ? '$date · $time' : time,
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: l10n.nextDay,
              onPressed: () => offset.shiftDays(1),
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: view.isLive
              ? const SizedBox(height: 36)
              : SizedBox(
                  height: 36,
                  child: TextButton.icon(
                    onPressed: offset.reset,
                    icon: const Icon(Icons.restore, size: 18),
                    label: Text(l10n.backToNow),
                  ),
                ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _CycleCard extends StatelessWidget {
  const _CycleCard({required this.state});

  final MoonState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final length =
        state.nextNewMoon.difference(state.previousNewMoon).inMinutes /
        Duration.minutesPerDay;
    return _Section(
      title: l10n.lunarCycle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LunarCycleBar(fraction: state.lunationFraction),
          const SizedBox(height: 10),
          Text(
            l10n.cycleLength(
              NumberFormat('0.0', l10n.localeName).format(length),
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _DetailsRow extends StatelessWidget {
  const _DetailsRow({required this.state});

  final MoonState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final km = NumberFormat.decimalPattern(l10n.localeName)
        .format((state.distanceKm / 100).round() * 100);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _Stat(
              label: l10n.moonAge,
              value: l10n.moonAgeDays(state.age.inDays),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _Stat(label: l10n.distance, value: l10n.distanceKm(km)),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: theme.textTheme.labelSmall),
            const SizedBox(height: 8),
            Text(value, style: theme.textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}

class _RiseSetCard extends ConsumerWidget {
  const _RiseSetCard({required this.view});

  final MoonView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final riseSet = view.riseSet;

    if (riseSet == null) {
      return _Section(title: l10n.riseSetTitle, child: const _LocationPrompt());
    }

    final format = _timeFormat(context);
    String timeOr(DateTime? t, String none) =>
        t == null ? none : format.format(t.toLocal());

    final Widget body;
    if (riseSet.alwaysUp || riseSet.alwaysDown) {
      body = Text(
        riseSet.alwaysUp ? l10n.moonAlwaysUp : l10n.moonAlwaysDown,
        style: theme.textTheme.bodyMedium,
      );
    } else {
      body = Row(
        children: [
          Expanded(
            child: _RiseSetTime(
              icon: Icons.north_east,
              label: l10n.moonrise,
              value: timeOr(riseSet.rise, l10n.noMoonrise),
              hasTime: riseSet.rise != null,
            ),
          ),
          Expanded(
            child: _RiseSetTime(
              icon: Icons.south_east,
              label: l10n.moonset,
              value: timeOr(riseSet.set, l10n.noMoonset),
              hasTime: riseSet.set != null,
            ),
          ),
        ],
      );
    }

    final altitude = view.state.horizontal?.altitude;
    return _Section(
      title: l10n.riseSetTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          body,
          if (altitude != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  altitude > 0 ? Icons.visibility : Icons.visibility_off,
                  size: 16,
                  color: altitude > 0
                      ? AppColors.gold
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  altitude > 0 ? l10n.moonUp : l10n.moonDown,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _RiseSetTime extends StatelessWidget {
  const _RiseSetTime({
    required this.icon,
    required this.label,
    required this.value,
    required this.hasTime,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool hasTime;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: hasTime
              ? theme.textTheme.headlineSmall
              : theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _LocationPrompt extends ConsumerWidget {
  const _LocationPrompt();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final location = ref.watch(locationProvider);
    final controller = ref.read(locationProvider.notifier);

    final problem = switch (location.problem) {
      null => null,
      LocationProblem.denied => l10n.locationDenied,
      LocationProblem.deniedForever => l10n.locationDeniedForever,
      LocationProblem.serviceOff => l10n.locationServiceOff,
      LocationProblem.failed => l10n.locationFailed,
    };
    final needsSettings =
        location.problem == LocationProblem.deniedForever ||
        location.problem == LocationProblem.serviceOff;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.locationPromptTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(l10n.locationPromptBody, style: theme.textTheme.bodySmall),
        if (problem != null) ...[
          const SizedBox(height: 8),
          Text(
            problem,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
        const SizedBox(height: 14),
        if (location.locating)
          Row(
            children: [
              const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 10),
              Text(l10n.locating, style: theme.textTheme.bodySmall),
            ],
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: controller.locate,
                icon: const Icon(Icons.my_location, size: 18),
                label: Text(
                  problem == null ? l10n.useMyLocation : l10n.tryAgain,
                ),
              ),
              if (needsSettings)
                OutlinedButton(
                  onPressed: controller.openSettings,
                  child: Text(l10n.openSettings),
                ),
            ],
          ),
      ],
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard({required this.view});

  final MoonView view;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = l10n.localeName;
    final dateFormat = DateFormat.MMMEd(locale);
    final timeFormat = _timeFormat(context);
    final from = DateUtils.dateOnly(view.time);

    return _Section(
      title: l10n.comingUp,
      child: Column(
        children: [
          for (final event in view.upcoming)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  _PhaseIcon(phase: event.phase, south: view.viewedFromSouth),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          MoonPhaseName.fromPrincipal(event.phase).label(l10n),
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          '${toBeginningOfSentenceCase(dateFormat.format(event.time.toLocal()), locale)}'
                          ' · ${timeFormat.format(event.time.toLocal())}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    l10n.inDays(
                      _calendarDaysBetween(from, event.time.toLocal()),
                    ),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: event.phase == PrincipalPhase.fullMoon
                          ? AppColors.gold
                          : null,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Whole calendar days from [from] (a local midnight) to [to], immune to
/// daylight saving changes.
int _calendarDaysBetween(DateTime from, DateTime to) {
  final a = DateTime.utc(from.year, from.month, from.day);
  final b = DateTime.utc(to.year, to.month, to.day);
  return b.difference(a).inDays;
}

/// A small glyph of a principal phase, drawn with the moon painter.
class _PhaseIcon extends StatelessWidget {
  const _PhaseIcon({required this.phase, required this.south});

  final PrincipalPhase phase;
  final bool south;

  @override
  Widget build(BuildContext context) {
    final (fraction, limb) = switch (phase) {
      PrincipalPhase.newMoon => (0.0, 270.0),
      PrincipalPhase.firstQuarter => (0.5, 270.0),
      PrincipalPhase.fullMoon => (1.0, 270.0),
      PrincipalPhase.lastQuarter => (0.5, 90.0),
    };
    return SizedBox.square(
      dimension: 34,
      child: MoonGlyph(
        fraction: fraction,
        brightLimbAngle: limb,
        rotation: south ? 180 : 0,
      ),
    );
  }
}
