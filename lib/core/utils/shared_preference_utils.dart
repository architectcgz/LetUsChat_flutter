import 'package:let_us_chat/core/constants/constants.dart';
import 'package:let_us_chat/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../constants/enums.dart';
import '../errors/exception.dart';


class SharedPreferenceUtil {

  static Future<void> saveData(String key, Object value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is List<String>) {
      await prefs.setStringList(key, value);
    } else {
      throw CustomException(
          code: 400,
          message: "SharedPreferenceUtil不支持对${value.runtimeType}类型存储");
    }
  }

  static Future<Object?> getData(String key, ValueType type) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(key)) {
      switch (type) {
        case ValueType.int:
          return prefs.getInt(key);
        case ValueType.double:
          return prefs.getDouble(key);
        case ValueType.bool:
          return prefs.getBool(key);
        case ValueType.string:
          return prefs.getString(key);
        default:
          return null;
      }
    }
    return null;
  }
  static Future<void> saveCurrentUserId(String userId)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(currentUserIdKey, userId);
  }
  static Future<String?> getCurrentUserId()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(currentUserIdKey);
  }

  static Future<bool> isUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final result = prefs.getBool(userLoggedKey);
    if (result == null) {
      return false;
    }
    return result;
  }

  static Future<void> setUserLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(userLoggedKey, true);
  }

  static Future<void> setUserLoggedOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(userLoggedKey, false);
  }

  static Future<void> saveUserInfo(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userJson = jsonEncode(user.toJson());
    await prefs.setString('user', userJson);
  }

  static Future<User?> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('user');
    if (userJson != null) {
      Map<String, dynamic> userMap = jsonDecode(userJson);
      return User.fromJson(userMap);
    }
    return null;
  }

  static Future<void> clearStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> saveBoolList(String key, List<bool> boolList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> boolListString = boolList.map((e) => e.toString()).toList();
    await prefs.setStringList(key, boolListString);
  }

  static Future<List<bool>?> getBoolList(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? boolListString = prefs.getStringList(key);
    if (boolListString != null) {
      return boolListString.map((e) => e == 'true').toList();
    }
    return null;
  }

  static void saveKeyboardHeight(double height)async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setDouble(keyboardHeightKey, height);
  }

  static Future<double?> getKeyboardHeight()async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getDouble(keyboardHeightKey);
  }

  static Future<void> deleteKeyboardHeight()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyboardHeightKey);
  }
}
