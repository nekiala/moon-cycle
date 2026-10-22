/// A place on Earth.
class GeoLocation {
  const GeoLocation({required this.latitude, required this.longitude})
    : assert(latitude >= -90 && latitude <= 90),
      assert(longitude >= -180 && longitude <= 180);

  /// Degrees, positive north of the equator.
  final double latitude;

  /// Degrees, positive east of Greenwich.
  final double longitude;

  bool get isSouthernHemisphere => latitude < 0;

  @override
  bool operator ==(Object other) =>
      other is GeoLocation &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() => 'GeoLocation($latitude, $longitude)';
}
