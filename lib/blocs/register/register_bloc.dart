import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/exception.dart';
import '../../core/services/captcha_service.dart';
import '../../core/services/user_service.dart';
import '../../core/utils/injection_container.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final UserService userService = serviceLocator.get();
  final CaptchaService captchaService = serviceLocator.get();

  RegisterBloc() : super(RegisterInitial()) {
    on<RegisterRequestEvent>(_onRegisterRequest);
    on<RegisterSendCaptchaEvent>(_onSendCaptcha);
  }

  Future<void> _onRegisterRequest(
    RegisterRequestEvent event,
    Emitter<RegisterState> emit,
  ) async {
    if (state is RegisterHanding) return;
    emit(RegisterHanding()); //表示正在处理注册Event

    try {
      if (event.registerType == 0) {
        await userService.registerByEmail(
          event.username,
          event.nickname,
          event.password,
          event.captcha,
        );
      } else if (event.registerType == 1) {
        await userService.registerByPhone(
          event.username,
          event.nickname,
          event.password,
          event.captcha,
        );
      }
      emit(RegisterSucceed());
    } on CustomException catch (e) {
      emit(RegisterFailed(code: e.code, message: e.message));
    }
  }

  Future<void> _onSendCaptcha(
    RegisterSendCaptchaEvent event,
    Emitter<RegisterState> emit,
  ) async {
    if (kDebugMode) {
      print("触发了发送验证码的操作");
    }
    try {
      if (event.captchaType == 0) {
        await captchaService.emailCaptcha(event.username);
      } else if (event.captchaType == 1) {
        await captchaService.smsCaptcha(event.username);
      }
    } on CustomException catch (e) {
      if (kDebugMode) {
        print("验证码发送失败");
        print("${e.code}:${e.message}");
      }
      emit(SendCaptchaFailed(code: e.code, message: e.message));
    }
  }
}
