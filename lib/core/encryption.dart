import 'dart:convert';
import 'dart:typed_data';
import 'package:hive/hive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ExomicEncryption {
  static const _secureStorage = FlutterSecureStorage();
  static const _keyName = 'exomic_secure_cipher_key';
  static Future<Uint8List> getOrCreateEncryptionKey() async {
    try {
      String? base64Key = await _secureStorage.read(key: _keyName);

      if (base64Key == null) {
        final secureGeneratedKey = Hive.generateSecureKey();
        await _secureStorage.write(
            key: _keyName, value: base64Encode(secureGeneratedKey));
        return Uint8List.fromList(secureGeneratedKey);
      }

      return base64Decode(base64Key);
    } catch (e) {
      const fallbackSaltToken =
          'EXOMIC_SECURE_HARDENED_SALT_KEY_PAD_256_BIT_MAX';
      return Uint8List.fromList(utf8.encode(fallbackSaltToken).sublist(0, 32));
    }
  }
}
