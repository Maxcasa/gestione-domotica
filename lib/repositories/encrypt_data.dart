import 'dart:convert';
import 'dart:math';

import 'package:encrypt/encrypt.dart';

// 'put32charactershereeeeeeeeeeeee!'
// 'put16characters!'
const keyString = 'chiveDiMassimoCasarin1371Domotic'; //32 chars
// final iv = IV.fromUtf8('MassimoDomotic13'); //16 chars

// //encrypt
String encryptMyData(String text) {
  return encryptWithKey(text, keyString);
}

//dycrypt
String? decryptMyData(String? text) {
  return decryptWithKey(text, keyString);
}

// //encrypt
String encryptWithKey(String text, String keyString) {
  final key = Key.fromUtf8(keyString);
  String generetedIV = generatePassword(length: 16); //32 chars
  final iv = IV.fromUtf8(generetedIV);
  final e = Encrypter(AES(key, mode: AESMode.cbc));
  final encryptedData = e.encrypt(text, iv: iv);
  return '{"iv": "$generetedIV", "text": "${encryptedData.base64}"}';
}

//dycrypt
String? decryptWithKey(String? text, String keyString) {
  final key = Key.fromUtf8(keyString); //32 chars
  if (text != null && text != "") {
    Map<String, dynamic> jsonText = jsonDecode(text);
    try {
      final e = Encrypter(AES(key, mode: AESMode.cbc));
      final decryptedData = e.decrypt(Encrypted.fromBase64(jsonText['text']),
          iv: IV.fromUtf8(jsonText['iv']));
      return decryptedData;
    } on Exception catch (e) {
      throw Exception(e);
    }
  } else {
    throw Exception('DecryptException');
  }
}

String generatePassword(
    {bool letter = true,
    bool isNumber = true,
    bool isSpecial = true,
    int length = 16}) {
  const letterLowerCase = "abcdefghijklmnopqrstuvwxyz";
  const letterUpperCase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  const number = '0123456789';
  const special = '@#%^*>\$@?/[]=+';

  String chars = "";
  if (letter) chars += '$letterLowerCase$letterUpperCase';
  if (isNumber) chars += number;
  if (isSpecial) chars += special;

  return List.generate(length, (index) {
    final indexRandom = Random.secure().nextInt(chars.length);
    return chars[indexRandom];
  }).join('');
}
