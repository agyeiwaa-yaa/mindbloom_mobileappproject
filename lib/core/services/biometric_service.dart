import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> isAvailable() async {
    final canCheck = await _localAuth.canCheckBiometrics;
    return canCheck || await _localAuth.isDeviceSupported();
  }

  Future<bool> authenticate() async {
    try {
      final available = await isAvailable();
      if (!available) return false;
      return _localAuth.authenticate(
        localizedReason: 'Unlock MindBloom to access your private wellness data',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }
}
