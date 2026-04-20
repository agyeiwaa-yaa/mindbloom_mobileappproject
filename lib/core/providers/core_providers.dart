import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/biometric_service.dart';
import '../services/database_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../services/sensor_service.dart';
import '../services/storage_service.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  final service = DatabaseService();
  ref.onDispose(service.dispose);
  return service;
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final sensorServiceProvider = Provider<SensorService>((ref) {
  return SensorService();
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});
