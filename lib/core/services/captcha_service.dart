import 'package:dio/dio.dart';
import 'package:let_us_chat/core/constants/constants.dart';
import 'package:let_us_chat/core/utils/injection_container.dart';

import '../dio_client.dart';
import '../errors/exception.dart';
import '../validators.dart';

class CaptchaService {
  final DioClient dioClient = serviceLocator.get();
  Future<void> emailCaptcha(String email) async {
    if (!Validator.isValidEmail(email)) {
      throw const CustomException(code: 408, message: "邮箱格式错误");
    }
    try {
      var response =
          await dioClient.dio.get("$serverBaseUrl/captcha/email?email=$email");
      if (response.data['code'] != 200) {
        throw CustomException(
            code: response.data['code'], message: response.data['message']);
      }
    } on DioException catch (e) {
      print(e);
      throw const CustomException(code: 404, message: "请检查网络连接");
    }
  }

  Future<void> smsCaptcha(String phone) async {
    if (!Validator.isValidPhone(phone)) {
      throw const CustomException(code: 408, message: "手机号码格式错误");
    }
    try {
      var response =
          await dioClient.dio.get("$serverBaseUrl/captcha/phone?phone=$phone");
      if (response.data['code'] != 200) {
        throw CustomException(
            code: response.data['code'], message: response.data['message']);
      }
    } on DioException catch (e) {
      print(e.message);
      throw const CustomException(code: 404, message: "请检查网络连接");
    }
  }
}
