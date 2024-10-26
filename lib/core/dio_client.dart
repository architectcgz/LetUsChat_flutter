import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:let_us_chat/core/constants/constants.dart';
import 'package:let_us_chat/core/global.dart';
import 'package:let_us_chat/core/utils/secure_storage_util.dart';
import 'package:let_us_chat/routes/app_navigation.dart';

class DioClient {
  static var whiteList = [
    '/user/register/email',
    '/user/register/phone',
    '/user/login/email',
    '/user/login/phone',
    '/user/refresh_token',
    '/captcha/*'
  ];
  Dio dio = Dio(
    BaseOptions(
      baseUrl: serverBaseUrl,
      contentType: 'application/json',
    ),
  );
  Future<bool>? _refreshTokenPromise;
  final storage = const FlutterSecureStorage();
  final GoRouter router = AppNavigation.router;
  DioClient() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? accessToken = globalAccessToken;
        // Add Authorization header if not in whitelist
        if (accessToken != null && !_isInWhiteList(options.path)) {
          options.headers['Authorization'] = "Bearer $accessToken";
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        print("请求错误: $error");
        if (error.response?.statusCode == 401) {
          //print("请求错误: ${error.response?.data}");
          final localRefreshToken = await getRefreshToken(currentUserId);
          if (localRefreshToken!=null) {
            print("请求刷新token");
            if (_refreshTokenPromise == null) {
              _refreshTokenPromise = refreshToken();
            }
            final refreshResult = await _refreshTokenPromise;
            _refreshTokenPromise = null;

            if (refreshResult!) {
              return handler.resolve(await _retry(error.requestOptions));
            } else {
              // 用户身份凭据过期,请重新登录
              router.go("/auth");
            }
          } else {
            router.go("/auth");
          }
        }
        return handler.next(error);
      },
      onResponse: (response, handler) async {
        // print(response.headers['Authorization']);
        // print(response.data);
        return handler.next(response);
      },
    ));
  }

  Future<bool> refreshToken() async {
    bool refreshSucceed = false;
    final refreshToken = await getRefreshToken(currentUserId);
    // print("refreshToken:$refreshToken");
    // print("accessToken::${await getAccessToken()}");
    try {
      final response = await dio.post('/user/refresh_token',
          options: Options(headers: {"RefreshToken": refreshToken}));
      if (response.data['code'] == 200) {
        print(
            "new access token: ${response.data['data']["accessToken"]}, new refresh token: ${response.data['data']["refreshToken"]}");
        await saveAccessToken(response.data['data']["accessToken"]);
        globalAccessToken = response.data['data']["accessToken"];
        await saveRefreshToken(response.data['data']["refreshToken"]);
        refreshSucceed = true;
      } else {
        //refreshToken is wrong
        print("refreshToken: $refreshToken错误, response: $response");
        router.go("/auth");
        storage.deleteAll();
      }
    } catch (e) {
      print("Failed to refresh token: $e");
      router.go("/auth");
      storage.deleteAll();
    }
    return refreshSucceed;
  }

  bool _isInWhiteList(String path) {
    // 简单的路径匹配逻辑，你可以根据需要更改
    for (String whiteListPath in whiteList) {
      if (path.contains(whiteListPath.replaceAll('*', ''))) {
        return true;
      }
    }
    return false;
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return dio.request<dynamic>(requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: options);
  }

  Future<void> saveAccessToken(String token) async {
    if(currentUserId!=null){
      await SecureStorageUtil.saveAccessToken(currentUserId!,token);
    }

  }

  Future<void> saveRefreshToken(String token) async {
    if(currentUserId!=null){
      print("保存refreshToken: $token");
      await SecureStorageUtil.saveRefreshToken(currentUserId!,token);
    }else{
      print("currentUserId: $currentUserId");
    }
  }

  Future<String?> getAccessToken(String? userId)async{
    if(userId==null){
      return null;
    }
    return await SecureStorageUtil.getAccessToken(userId);
  }
  Future<String?> getRefreshToken(String? userId)async{
    if(userId==null){
      print("要获取refreshToken的userId为null");
      return null;
    }
    return await SecureStorageUtil.getRefreshToken(userId);
  }


}
