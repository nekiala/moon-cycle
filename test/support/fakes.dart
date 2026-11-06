import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:moon_cycle/core/astronomy/astronomy.dart';
import 'package:moon_cycle/core/theme/app_theme.dart';
import 'package:moon_cycle/features/home/home_screen.dart';
import 'package:moon_cycle/features/location/location_controller.dart';
import 'package:moon_cycle/features/location/location_service.dart';
import 'package:moon_cycle/features/moon/moon_view.dart';
import 'package:moon_cycle/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kinshasa = GeoLocation(latitude: -4.3217, longitude: 15.3125);
const paris = GeoLocation(latitude: 48.8566, longitude: 2.3522);

/// A clock stopped at one instant.
class FixedClock extends Clock {
  FixedClock(this.time);

  final DateTime time;

  @override
  DateTime build() => time;
}

/// Stands in for GPS.
class FakeLocationService implements LocationService {
  FakeLocationService({this.result, this.allowed});

  /// What [locate] returns.
  LocationResult? result;

  /// What [locateIfAllowed] returns.
  GeoLocation? allowed;

  int locateCalls = 0;
  int settingsCalls = 0;

  @override
  Future<LocationResult> locate() async {
    locateCalls++;
    return result ?? const LocationResult.failed(LocationProblem.failed);
  }

  @override
  Future<GeoLocation?> locateIfAllowed() async => allowed;

  @override
  Future<void> openSettings() async => settingsCalls++;
}

Future<List<Override>> testOverrides({
  required DateTime now,
  LocationService? location,
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final instance = await SharedPreferences.getInstance();
  return [
    sharedPreferencesProvider.overrideWithValue(instance),
    clockProvider.overrideWith(() => FixedClock(now)),
    locationServiceProvider.overrideWithValue(
      location ?? FakeLocationService(),
    ),
  ];
}

Widget homeApp(List<Override> overrides, {Locale locale = const Locale('en')}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: AppTheme.dark(),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const HomeScreen(),
    ),
  );
}
