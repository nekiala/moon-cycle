import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/astronomy/astronomy.dart';
import 'location_service.dart';

/// Loaded in `main` before the app starts, and overridden there.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Override in main()'),
);

final locationServiceProvider = Provider<LocationService>(
  (ref) => const DeviceLocationService(),
);

final locationStoreProvider = Provider<LocationStore>(
  (ref) => LocationStore(ref.watch(sharedPreferencesProvider)),
);

class LocationState {
  const LocationState({this.location, this.locating = false, this.problem});

  /// Where the user is, or null until they share it.
  final GeoLocation? location;

  /// A lookup is running.
  final bool locating;

  /// Why the last lookup failed, if it did.
  final LocationProblem? problem;
}

/// The user's location: remembered from last time, refreshed quietly when
/// permission is already granted, and requested only when the user asks.
class LocationController extends Notifier<LocationState> {
  @override
  LocationState build() {
    final saved = ref.read(locationStoreProvider).read();
    if (saved != null) Future.microtask(_refreshQuietly);
    return LocationState(location: saved);
  }

  Future<void> _refreshQuietly() async {
    final found = await ref.read(locationServiceProvider).locateIfAllowed();
    if (found == null || !ref.mounted) return;
    await ref.read(locationStoreProvider).write(found);
    if (!ref.mounted) return;
    state = LocationState(location: found);
  }

  /// Asks the device for its location, with a permission prompt if needed.
  Future<void> locate() async {
    if (state.locating) return;
    state = LocationState(location: state.location, locating: true);
    final result = await ref.read(locationServiceProvider).locate();
    if (!ref.mounted) return;
    final found = result.location;
    if (found != null) {
      await ref.read(locationStoreProvider).write(found);
      if (!ref.mounted) return;
      state = LocationState(location: found);
    } else {
      state = LocationState(location: state.location, problem: result.problem);
    }
  }

  Future<void> openSettings() =>
      ref.read(locationServiceProvider).openSettings();
}

final locationProvider = NotifierProvider<LocationController, LocationState>(
  LocationController.new,
);
