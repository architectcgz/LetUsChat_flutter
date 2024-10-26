import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:let_us_chat/core/constants/constants.dart';
import 'package:let_us_chat/core/utils/injection_container.dart';

import '../../models/user.dart';
import '../dio_client.dart';
import '../errors/exception.dart';
import '../validators.dart';

class UserService {
  final DioClient dioClient = serviceLocator.get();
  final Dio dio = serviceLocator.get();
  UserService();
  Future<void> registerByEmail(
      String email, String nickname, String password, String captcha) async {
    if (!Validator.isValidEmail(email)) {
      throw const CustomException(code: 408, message: "邮箱格式错误");
    }
    if (!Validator.isValidUsername(nickname)) {
      throw const CustomException(code: 408, message: "昵称由1-10个中英文字符或数字组成");
    }
    if (!Validator.isValidPassword(password)) {
      throw const CustomException(
          code: 408, message: "密码必须包含大小写字母和特殊符号其中的两种,至少8位,最多16位");
    }
    var jsonData = {
      "email": email,
      "nickname": nickname,
      "password": password,
      "captcha": captcha
    };
    try {
      final response = await dio.post("$serverBaseUrl/user/register/email",
          options: Options(
              headers: {HttpHeaders.contentTypeHeader: "application/json"}),
          data: jsonEncode(jsonData));
      if (response.data['code'] != 200) {
        throw CustomException(
            code: response.data['code'], message: response.data['message']);
      }
    } on DioException catch (e) {
      print(e.message);
      throw const CustomException(code: 404, message: "请检查网络连接");
    }
  }

  Future<void> registerByPhone(
      String phone, String nickname, String password, String captcha) async {
    if (!Validator.isValidPhone(phone)) {
      throw const CustomException(code: 408, message: "手机号码格式错误");
    }
    if (!Validator.isValidUsername(nickname)) {
      throw const CustomException(code: 408, message: "昵称由1-10个中英文字符或数字组成");
    }
    if (!Validator.isValidPassword(password)) {
      throw const CustomException(
          code: 408, message: "密码必须包含大小写字母和特殊符号其中的两种,至少8位,最多16位");
    }
    var jsonData = {
      "phone": phone,
      "nickname": nickname,
      "password": password,
      "captcha": captcha
    };
    try {
      final response = await dio.post("$serverBaseUrl/user/register/phone",
          options: Options(
              headers: {HttpHeaders.contentTypeHeader: "application/json"}),
          data: jsonEncode(jsonData));
      if (response.data['code'] != 200) {
        throw CustomException(
            code: response.data['code'], message: response.data['message']);
      }
    } on DioException catch (e) {
      print(e.message);
      throw const CustomException(code: 404, message: "请检查网络连接");
    }
  }

  Future<Map<String, dynamic>?> loginByPhone(
      String phone, String password) async {
    if (!Validator.isValidPhone(phone)) {
      throw const CustomException(code: 408, message: "手机号码格式错误");
    }
    if (!Validator.isValidPassword(password)) {
      //throw const CustomException(code: 408, message: "密码必须包含大小写字母和特殊符号其中的两种,至少8位,最多16位");
      throw const CustomException(code: 408, message: "密码格式错误");
    }
    var jsonData = {
      "phone": phone,
      "password": password,
      "platform": 2 //表示app端
    };
    try {
      await dio
          .post("$serverBaseUrl/user/login/phone",
              options: Options(
                  headers: {HttpHeaders.contentTypeHeader: "application/json"}),
              data: jsonEncode(jsonData))
          .catchError((e) => throw CustomException(
              code: e.response?.code, message: e.response?.data['message']))
          .then((resp) async {
        if (resp.data['code'] == 200) {
          return resp.data['data'];
        } else {
          throw CustomException(
              code: resp.data['code'], message: resp.data['message']);
        }
      });
    } on DioException catch (e) {
      print(e);
      throw const CustomException(code: 404, message: "请检查网络连接");
    }
    return null;
  }

  Future<Map<String, dynamic>?> loginByEmail(
      String email, String password) async {
    if (!Validator.isValidEmail(email)) {
      throw const CustomException(code: 408, message: "邮箱格式错误");
    }
    if (!Validator.isValidPassword(password)) {
      //throw const CustomException(code: 408, message: "密码必须包含大小写字母和特殊符号其中的两种,至少8位,最多16位");
      throw const CustomException(code: 408, message: "密码格式错误");
    }
    var jsonData = {
      "email": email,
      "password": password,
      "platform": 2 //表示app端
    };
    final result = await dio.post("$serverBaseUrl/user/login/email",
        data: jsonEncode(jsonData));
    if (result.data['code'] == 200) {
      return result.data;
    } else {
      print("${result.data['code']},${result.data['message']}");
      throw CustomException(
          code: result.data['code'],
          message: result.data['message'] ?? '服务器错误');
    }
  }

  Future<User?> getUserInfo() async {
    try {
      final response = await dioClient.dio.get("/user/info");
      final data = response.data;
      print("用户信息为: $data");
      if (data['code'] == 200) {
        return User.fromJson(data['data']);
      }
    } on CustomException catch (e) {
      print("获取用户信息时出现异常: $e");
      throw CustomException(
        code: e.code,
        message: e.message,
      );
    }
    return null;
  }

  Future<void> updateUserInfo(User user) async {
    try {
      await dioClient.dio.post("/user/info/update", data: user.toJson());
    } on Exception catch (e) {
      print(e);
      throw const CustomException(code: 500, message: "用户信息更新失败,请稍后重试");
    }
  }

  Future<String?> getQRCode() async {
    try {
      final result = await dioClient.dio.get("/user/qrcode");
      print(result);
      if (result.data['code'] == 200) {
        return result.data['data']; //得到的是base64编码后的字符串
      }
    } on Exception catch (e) {
      print(e);
      throw const CustomException(code: 500, message: "用户二维码获取失败,请稍后重试");
    }
    return null;
  }
}
