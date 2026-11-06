import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/astronomy/astronomy.dart';

/// Why a location could not be found.
enum LocationProblem { serviceOff, denied, deniedForever, failed }

class LocationResult {
  const LocationResult.found(GeoLocation this.location) : problem = null;
  const LocationResult.failed(LocationProblem this.problem) : location = null;

  final GeoLocation? location;
  final LocationProblem? problem;
}

/// Finds where the device is. Behind an interface so tests and the
/// simulator can stand in for GPS.
abstract interface class LocationService {
  /// Asks for permission if needed, then finds the device.
  Future<LocationResult> locate();

  /// Finds the device only if permission was already given, without asking.
  Future<GeoLocation?> locateIfAllowed();

  Future<void> openSettings();
}

class DeviceLocationService implements LocationService {
  const DeviceLocationService();

  // Moonrise and moonset barely change over a few kilometres, so a coarse,
  // fast fix is plenty.
  static const _settings = LocationSettings(
    accuracy: LocationAccuracy.low,
    timeLimit: Duration(seconds: 20),
  );

  @override
  Future<LocationResult> locate() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const LocationResult.failed(LocationProblem.serviceOff);
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      switch (permission) {
        case LocationPermission.denied:
          return const LocationResult.failed(LocationProblem.denied);
        case LocationPermission.deniedForever:
          return const LocationResult.failed(LocationProblem.deniedForever);
        case LocationPermission.whileInUse:
        case LocationPermission.always:
        case LocationPermission.unableToDetermine:
          break;
      }
      final position = await _position();
      return position == null
          ? const LocationResult.failed(LocationProblem.failed)
          : LocationResult.found(position);
    } on Exception {
      return const LocationResult.failed(LocationProblem.failed);
    }
  }

  @override
  Future<GeoLocation?> locateIfAllowed() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return null;
      }
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      return await _position();
    } on Exception {
      return null;
    }
  }

  Future<GeoLocation?> _position() async {
    Position? p;
    try {
      p = await Geolocator.getCurrentPosition(locationSettings: _settings);
    } on Exception {
      p = await Geolocator.getLastKnownPosition();
    }
    if (p == null) return null;
    return GeoLocation(latitude: p.latitude, longitude: p.longitude);
  }

  @override
  Future<void> openSettings() => Geolocator.openAppSettings();
}

/// Remembers the last location, so the app shows moonrise straight away on
/// the next launch and works with location turned off.
class LocationStore {
  const LocationStore(this._prefs);

  final SharedPreferences _prefs;

  static const _latKey = 'location.latitude';
  static const _lonKey = 'location.longitude';

  GeoLocation? read() {
    final lat = _prefs.getDouble(_latKey);
    final lon = _prefs.getDouble(_lonKey);
    if (lat == null || lon == null) return null;
    if (lat.abs() > 90 || lon.abs() > 180) return null;
    return GeoLocation(latitude: lat, longitude: lon);
  }

  Future<void> write(GeoLocation location) async {
    await _prefs.setDouble(_latKey, location.latitude);
    await _prefs.setDouble(_lonKey, location.longitude);
  }

  Future<void> clear() async {
    await _prefs.remove(_latKey);
    await _prefs.remove(_lonKey);
  }
}
