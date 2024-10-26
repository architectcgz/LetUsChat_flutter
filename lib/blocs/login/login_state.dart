part of 'login_bloc.dart';

sealed class LoginState {
  const LoginState();
}

final class LoginInitial extends LoginState {

}

final class LoginRequest extends LoginState {
  final String username;
  final String password;
  /// 0表示email登录,1表示phone登录
  final int loginType;
  const LoginRequest(
      {required this.username,
      required this.password,
      required this.loginType});
}

final class PhoneLoginSucceed extends LoginState {

}

final class PhoneLoginFailed extends LoginState {
  final int code;
  final String message;
  PhoneLoginFailed({required this.code, required this.message});
}

final class EmailLoginSucceed extends LoginState {

}

final class EmailLoginFailed extends LoginState {
  final int code;
  final String message;
  EmailLoginFailed({required this.code, required this.message});
}

final class Logging extends LoginState {

}

final class GetNecessaryInfoFailed extends LoginState{
  final int code;
  final String message;
  GetNecessaryInfoFailed({required this.code, required this.message});
}

final class GetUserInfoSucceed extends LoginState{
}