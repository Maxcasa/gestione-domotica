import 'dart:convert';

import 'package:encrypt/encrypt.dart';

// 'put32charactershereeeeeeeeeeeee!'
// 'put16characters!'
const keyString = 'chiveDiMassimoCasarin1371Domotic'; //32 chars
// Legacy data uses a per-record IV; this module only reads that format.

String? _decryptLegacyData(String? text) {
  return _decryptWithKey(text, keyString);
}

bool isLegacyEncryptedData(String value) {
  try {
    final dynamic decoded = jsonDecode(value);
    return decoded is Map &&
        decoded['iv'] is String &&
        decoded['text'] is String;
  } on FormatException {
    return false;
  }
}

String decodeLegacyStoredJson(String value) {
  if (!isLegacyEncryptedData(value)) {
    return value;
  }
  return _decryptLegacyData(value) ??
      (throw const FormatException('Unable to decrypt legacy configuration'));
}

String? _decryptWithKey(String? text, String keyString) {
  final key = Key.fromUtf8(keyString); //32 chars
  if (text != null && text != "") {
    Map<String, dynamic> jsonText = jsonDecode(text);
    try {
      final e = Encrypter(AES(key, mode: AESMode.cbc));
      final decryptedData = e.decrypt(Encrypted.fromBase64(jsonText['text']),
          iv: IV.fromUtf8(jsonText['iv']));
      return decryptedData;
    } on Exception {
      throw const FormatException('Unable to decrypt legacy configuration');
    }
  } else {
    throw const FormatException('Unable to decrypt legacy configuration');
  }
}
