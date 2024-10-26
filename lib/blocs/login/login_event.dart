part of 'login_bloc.dart';

sealed class LoginEvent extends Equatable {
  const LoginEvent();
}

class LoginRequestEvent extends LoginEvent{
  final String username;
  final String password;
  /// 0表示email登录,1表示phone登录
  final int loginType;
  const LoginRequestEvent({
    required this.username,
    required this.password,
    required this.loginType
});
  @override
  List<Object?> get props => [username,password,loginType];
}

class LoginSucceedEvent extends LoginEvent{
  @override
  List<Object?> get props => [];
}
