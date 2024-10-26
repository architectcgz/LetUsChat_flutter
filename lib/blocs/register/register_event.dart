part of 'register_bloc.dart';


@immutable
sealed class RegisterEvent extends Equatable {
  @override
  List<Object?> get props => [];
}


class RegisterRequestEvent extends RegisterEvent {
  /// 0表示email注册,1表示phone注册
  final int registerType;
  final String username;
  final String nickname;
  final String password;
  final String captcha;

  RegisterRequestEvent({
    required this.registerType,
    required this.username,
    required this.nickname,
    required this.password,
    required this.captcha,
  });

  @override
  List<Object?> get props => [registerType, username, nickname, password, captcha];
}


class RegisterSendCaptchaEvent extends RegisterEvent {
  final String username;
  final int captchaType;

  RegisterSendCaptchaEvent({
    required this.captchaType,
    required this.username,
  });

  @override
  List<Object?> get props => [captchaType, username];
}
