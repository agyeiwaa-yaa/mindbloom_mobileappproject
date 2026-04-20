import 'package:geolocator/geolocator.dart';

class LocationSnapshot {
  const LocationSnapshot({
    required this.latitude,
    required this.longitude,
    this.label,
  });

  final double latitude;
  final double longitude;
  final String? label;
}

class LocationService {
  Future<LocationSnapshot?> getCurrentLocation() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      return null;
    }

    final position = await Geolocator.getCurrentPosition();
    final lat = position.latitude.toStringAsFixed(4);
    final lng = position.longitude.toStringAsFixed(4);
    return LocationSnapshot(
      latitude: position.latitude,
      longitude: position.longitude,
      label: 'Lat $lat, Lng $lng',
    );
  }
}
