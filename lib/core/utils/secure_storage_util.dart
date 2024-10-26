import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:let_us_chat/core/constants/constants.dart';

import '../../models/user.dart';

class SecureStorageUtil{
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static Future<void>saveUserInfo(User user)async{
    String userJson = jsonEncode(user.toJson());
    print("保存用户$userSecureStorageKey${user.userId}信息");
    await _storage.write(key: "$userSecureStorageKey${user.userId}", value: userJson);
  }

  static Future<User?>getUserInfo(String userId)async{
    print("获取用户$userSecureStorageKey$userId信息");
    String? userJson = await _storage.read(key: "$userSecureStorageKey$userId");
    if(userJson==null){
      print("从本地读取到的用户信息为null");
      return null;
    }else{
      print("从本地读取到user信息: $userJson");
    }
    return User.fromJson(jsonDecode(userJson));
  }
  static Future<void>clearStorage()async{
    await _storage.deleteAll();
  }
  static Future<void>removeUserInfo(String userId)async{
    await _storage.delete(key: "$userAccessTokenKey$userId");
  }

  static Future<void> saveAccessToken(String userId,String accessToken) async{
    await _storage.write(key: "$userAccessTokenKey$userId", value: accessToken);
  }
  static Future<void> saveRefreshToken(String userId,String refreshToken) async{
    await _storage.write(key: "$userRefreshTokenKey$userId", value: refreshToken);
  }

  static Future<String?> getAccessToken(String userId) async{
    return await _storage.read(key: "$userAccessTokenKey$userId");
  }
  static Future<String?> getRefreshToken(String userId) async{
    print("$userId 获取refreshToken");
    return await _storage.read(key: "$userRefreshTokenKey$userId");
  }
}