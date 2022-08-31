import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import '../constants/Constants.dart';

class AuthCode {

  static String getAuthCode(String nickname, String avatar, String openId) {
    return hs256(nickname, avatar, openId);
  }

  static String hs256(String nickname, String avatar, String openId) {
    String token;

    final jwt = JWT({
      'appKey': Constants.appKey,
      'userInfo': {
        'nickname': nickname,
        'avatar': avatar,
        'openId': openId,
      }
    });

    // Sign it
    token = jwt.sign(SecretKey(Constants.appSecret));
    print('AuthCode Signed token: $token\n');
    return token;
  }
}
