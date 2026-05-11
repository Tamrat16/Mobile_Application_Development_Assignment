import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PinService {
  static const _key = 'app_pin';
  final _storage = const FlutterSecureStorage();

  Future<void> savePin(String pin) async {
    await _storage.write(key: _key, value: pin);
  }

  Future<String?> getPin() async {
    return await _storage.read(key: _key);
  }

  Future<bool> hasPin() async {
    return (await getPin()) != null;
  }

  Future<bool> verifyPin(String inputPin) async {
    final savedPin = await getPin();
    return savedPin == inputPin;
  }

  Future<void> deletePin() async {
    await _storage.delete(key: _key);
  }
}
