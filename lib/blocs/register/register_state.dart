part of 'register_bloc.dart';

@immutable
sealed class RegisterState {
  const RegisterState();
}

final class RegisterInitial extends RegisterState {}

final class RegisterRequest extends RegisterState {
  /// 0表示email注册,1表示phone注册
  final int registerType;
  final String username;
  final String nickname;
  final String password;
  final String captcha;

  const RegisterRequest({
    required this.registerType,
    required this.username,
    required this.nickname,
    required this.password,
    required this.captcha,
  });
}

final class RegisterHanding extends RegisterState {}

final class RegisterSucceed extends RegisterState {}

final class RegisterFailed extends RegisterState {
  final String message;
  final int code;
  const RegisterFailed({required this.code, required this.message});
}

final class SendCaptchaFailed extends RegisterState {
  final int code;
  final String message;
  const SendCaptchaFailed({required this.code, required this.message});
}
