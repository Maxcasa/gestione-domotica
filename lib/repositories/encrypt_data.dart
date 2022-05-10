import 'dart:convert';

import 'package:encrypt/encrypt.dart';

// 'put32charactershereeeeeeeeeeeee!'
// 'put16characters!'
const keyString = 'chiveDiMassimoCasarin1371Domotic'; //32 chars
// final iv = IV.fromUtf8('MassimoDomotic13'); //16 chars

//encrypt
String encryptMyData(String text) {
  return encryptWithKey(text, keyString);
}

//dycrypt
String? decryptMyData(String? text) {
  return decryptWithKey(text, keyString);
}

//encrypt
String encryptWithKey(String text, String keyString) {
  final key = Key.fromUtf8(keyString); //32 chars
  final iv = IV.fromLength(16);
  final e = Encrypter(AES(key, mode: AESMode.cbc));
  final encryptedData = e.encrypt(text, iv: iv);
  return '{iv: ${iv.toString()}, text: ${encryptedData.base64}}';
}

//dycrypt
String? decryptWithKey(String? text, String keyString) {
  final key = Key.fromUtf8(keyString); //32 chars
  if (text != null && text != "") {
    Map<String, dynamic> jsonText = jsonDecode(text);
    try {
      final e = Encrypter(AES(key, mode: AESMode.cbc));
      final decrypted_data = e.decrypt(Encrypted.fromBase64(jsonText['text']),
          iv: IV.fromUtf8(jsonText['iv']));
      return decrypted_data;
    } on Exception catch (e) {
      return null;
    }
  } else {
    return null;
  }
}
