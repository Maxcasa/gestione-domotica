import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gestione_domotica/models/configurazioni/local_data.dart';
import 'package:gestione_domotica/repositories/legacy_encrypted_config.dart';

void main() {
  test('decodes a legacy encrypted configuration', () {
    const encrypted =
        '{"iv":"8Ub[I2c]EpLzTQKH","text":"ZbHjohh9H1w7+wd8aUbCWU/QmZoVch1YnXHYGxE1ru0v5bt2xflbuGPvG9gjCV7rSURaCsmofKtvDWDdQPl3Uw3W0SdMbEFALYwin9oPsPg="}';

    expect(isLegacyEncryptedData(encrypted), isTrue);
    expect(jsonDecode(decodeLegacyStoredJson(encrypted)), {
      'activeIndex': 1,
      'sensoriVisibili': false,
      'token': 'fixture-token',
    });
  });

  test('leaves a plain JSON configuration unchanged', () {
    const plain = '{"activeIndex":1,"sensoriVisibili":false}';

    expect(isLegacyEncryptedData(plain), isFalse);
    expect(decodeLegacyStoredJson(plain), plain);
  });

  test('rejects an invalid legacy encrypted payload', () {
    expect(
      () =>
          decodeLegacyStoredJson('{"iv":"0123456789abcdef","text":"invalid"}'),
      throwsA(isA<FormatException>()),
    );
  });

  test('reads old token fields but never serializes the token to JSON', () {
    final oldConfig = LocalData.fromJson({
      'activeIndex': 1,
      'sensoriVisibili': true,
      'token': 'legacy-token',
    });
    final typoConfig = LocalData.fromJson({'tolken': 'older-token'});

    expect(oldConfig.token, 'legacy-token');
    expect(typoConfig.token, 'older-token');
    expect(oldConfig.toJson().containsKey('token'), isFalse);
  });
}
