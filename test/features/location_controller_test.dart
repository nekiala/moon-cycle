import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moon_cycle/features/location/location_controller.dart';
import 'package:moon_cycle/features/location/location_service.dart';
import 'package:moon_cycle/features/moon/moon_view.dart';

import '../support/fakes.dart';

void main() {
  final now = DateTime.utc(2025, 11, 3, 12);

  test('starts without a location and finds one on request', () async {
    final gps = FakeLocationService(
      result: const LocationResult.found(kinshasa),
    );
    final container = ProviderContainer(
      overrides: await testOverrides(now: now, location: gps),
    );
    addTearDown(container.dispose);

    expect(container.read(locationProvider).location, isNull);
    expect(container.read(moonViewProvider).riseSet, isNull);

    await container.read(locationProvider.notifier).locate();
    expect(container.read(locationProvider).location, kinshasa);
    expect(container.read(moonViewProvider).riseSet, isNotNull);
    expect(container.read(moonViewProvider).viewedFromSouth, isTrue);
    expect(container.read(locationStoreProvider).read(), kinshasa);
  });

  test('keeps the saved place when a lookup fails', () async {
    final gps = FakeLocationService(
      result: const LocationResult.failed(LocationProblem.serviceOff),
    );
    final container = ProviderContainer(
      overrides: await testOverrides(
        now: now,
        location: gps,
        prefs: {
          'location.latitude': paris.latitude,
          'location.longitude': paris.longitude,
        },
      ),
    );
    addTearDown(container.dispose);

    await container.read(locationProvider.notifier).locate();
    final state = container.read(locationProvider);
    expect(state.location, paris);
    expect(state.problem, LocationProblem.serviceOff);
  });

  test('refreshes a saved place quietly when permission is granted', () async {
    final gps = FakeLocationService(allowed: kinshasa);
    final container = ProviderContainer(
      overrides: await testOverrides(
        now: now,
        location: gps,
        prefs: {
          'location.latitude': paris.latitude,
          'location.longitude': paris.longitude,
        },
      ),
    );
    addTearDown(container.dispose);

    expect(container.read(locationProvider).location, paris);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(locationProvider).location, kinshasa);
    expect(gps.locateCalls, 0);
  });

  test('the view offset moves time and resets to live', () async {
    final container = ProviderContainer(
      overrides: await testOverrides(now: now),
    );
    addTearDown(container.dispose);

    expect(container.read(moonViewProvider).isLive, isTrue);
    container.read(viewOffsetProvider.notifier).shiftDays(3);
    final view = container.read(moonViewProvider);
    expect(view.isLive, isFalse);
    expect(view.time, now.add(const Duration(days: 3)).toLocal());
    container.read(viewOffsetProvider.notifier).reset();
    expect(container.read(moonViewProvider).isLive, isTrue);
  });
}
