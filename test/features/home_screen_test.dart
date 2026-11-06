import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moon_cycle/features/location/location_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fakes.dart';

void main() {
  // A waxing gibbous moon, two days before the full moon of 5 Nov 2025.
  final waxing = DateTime.utc(2025, 11, 3, 12);

  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(finder, 200);
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
  }

  setUp(() {
    // A phone-shaped screen.
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(1170, 2532);
    view.devicePixelRatio = 3;
  });

  tearDown(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  testWidgets('shows the phase, cycle, age and distance', (tester) async {
    await tester.pumpWidget(homeApp(await testOverrides(now: waxing)));
    expect(find.text('Waxing Gibbous'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.textContaining('lit'), findsOneWidget);
    await scrollTo(tester, find.textContaining(' km'));
    expect(
      find.textContaining('-day cycle, new moon to new moon'),
      findsOneWidget,
    );
    expect(find.text('12 days'), findsOneWidget);
  });

  testWidgets('lists the next four phases, soonest first', (tester) async {
    await tester.pumpWidget(homeApp(await testOverrides(now: waxing)));
    await scrollTo(tester, find.text('Coming up'.toUpperCase()));
    await scrollTo(tester, find.text('First Quarter'));
    final names = ['Full Moon', 'Last Quarter', 'New Moon', 'First Quarter'];
    final ys = [for (final n in names) tester.getTopLeft(find.text(n)).dy];
    expect(ys, orderedEquals([...ys]..sort()));
    // 5 Nov 2025 13:19 UTC.
    expect(find.text('In 2 days'), findsOneWidget);
  });

  testWidgets('asks for location before showing moonrise', (tester) async {
    final gps = FakeLocationService(
      result: const LocationResult.found(kinshasa),
    );
    await tester.pumpWidget(
      homeApp(await testOverrides(now: waxing, location: gps)),
    );
    await scrollTo(tester, find.text('Use my location'));
    expect(find.text('Moonrise'), findsNothing);

    await tester.tap(find.text('Use my location'));
    await tester.pumpAndSettle();

    expect(gps.locateCalls, 1);
    await scrollTo(tester, find.text('Moonrise'));
    expect(find.text('Moonset'), findsOneWidget);
    expect(find.text('Use my location'), findsNothing);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getDouble('location.latitude'), kinshasa.latitude);
  });

  testWidgets('remembers the location from last time', (tester) async {
    await tester.pumpWidget(
      homeApp(
        await testOverrides(
          now: waxing,
          prefs: {
            'location.latitude': paris.latitude,
            'location.longitude': paris.longitude,
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('48.86° N · 2.35° E'), findsOneWidget);
    await scrollTo(tester, find.text('Moonrise'));
  });

  testWidgets('explains a refused permission and links to settings', (
    tester,
  ) async {
    final gps = FakeLocationService(
      result: const LocationResult.failed(LocationProblem.deniedForever),
    );
    await tester.pumpWidget(
      homeApp(await testOverrides(now: waxing, location: gps)),
    );
    await scrollTo(tester, find.text('Use my location'));
    await tester.tap(find.text('Use my location'));
    await tester.pumpAndSettle();

    expect(find.textContaining('turn it on in Settings'), findsOneWidget);
    await tester.tap(find.text('Open Settings'));
    expect(gps.settingsCalls, 1);
  });

  testWidgets('moves through days and back to now', (tester) async {
    await tester.pumpWidget(homeApp(await testOverrides(now: waxing)));
    expect(find.text('Back to now'), findsNothing);

    await tester.tap(find.byTooltip('Next day'));
    await tester.tap(find.byTooltip('Next day'));
    await tester.pumpAndSettle();
    expect(find.text('Wed, Nov 5'), findsOneWidget);
    expect(find.text('Full Moon'), findsWidgets);
    expect(find.text('Back to now'), findsOneWidget);

    await tester.tap(find.text('Back to now'));
    await tester.pumpAndSettle();
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Waxing Gibbous'), findsOneWidget);
  });

  testWidgets('dragging the moon travels in time', (tester) async {
    await tester.pumpWidget(homeApp(await testOverrides(now: waxing)));
    // 15 minutes a pixel: 200 px is 50 hours, past the full moon.
    await tester.drag(find.byKey(const Key('moon-disc')), const Offset(200, 0));
    await tester.pumpAndSettle();
    expect(find.text('Full Moon'), findsWidgets);
    expect(find.text('Back to now'), findsOneWidget);
  });

  testWidgets('shows French dates and labels', (tester) async {
    await tester.pumpWidget(
      homeApp(await testOverrides(now: waxing), locale: const Locale('fr')),
    );
    expect(find.text('Gibbeuse croissante'), findsOneWidget);
    await tester.tap(find.byTooltip('Jour suivant'));
    await tester.pumpAndSettle();
    expect(find.text('Mar. 4 nov.'), findsOneWidget);
    expect(find.text('Revenir à maintenant'), findsOneWidget);
  });
}
