import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:let_us_chat/core/constants/enums.dart';
import 'package:let_us_chat/core/utils/RegexUtils.dart';
import 'package:let_us_chat/core/utils/injection_container.dart';

import '../../blocs/authentication/authentication_bloc.dart';
import '../../blocs/login/login_bloc.dart';
import '../utils/platform_utils.dart';
import '../utils/show_widget_util.dart';

class AuthPage extends StatelessWidget {
  AuthPage({super.key});

  final TextEditingController _usernameController = PlatformUtils.isWindows
      ? TextEditingController(text: "837629890@qq.com")
      : PlatformUtils.isAndroid
          ? TextEditingController(text: "3304409760@qq.com")
          : PlatformUtils.isWeb
              ? TextEditingController(text: "860617776@qq.com")
              : TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController(text: "cgz201902");

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state is EmailLoginFailed) {
              ShowWidgetUtil.showSnackBar(context, "登录失败,请重试:${state.message}");
            } else if (state is EmailLoginSucceed) {
              ShowWidgetUtil.showSnackBar(context, "通过邮箱登录成功");
              //获取用户信息
              context.read<LoginBloc>().add(LoginSucceedEvent());
            } else if (state is GetNecessaryInfoFailed) {
              print("用户信息获取失败");
              ShowWidgetUtil.showSnackBar(
                  context, "${state.code}${state.message}");
            } else if (state is GetUserInfoSucceed) {
              print("用户信息获取成功");
              // 通知 AuthenticationBloc 用户已登录
              context.read<AuthenticationBloc>().add(LoggedIn());
              //用户信息获取成功,跳转到聊天页面
            } else if (state is PhoneLoginFailed) {
              ShowWidgetUtil.showSnackBar(context, state.message);
            } else if (state is PhoneLoginSucceed) {
              ShowWidgetUtil.showSnackBar(context, "通过手机号码登录成功");
              //获取用户信息
              context.read<LoginBloc>().add(LoginSucceedEvent());
            }
          },
          builder: (context, state) {
            if (state is Logging) {
              return Stack(
                children: [
                  _buildLoginArea(context),
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                ],
              );
            }
            return _buildLoginArea(context);
          },
        ),
      ),
    );
  }

  Widget _buildLoginArea(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFB5CCFF),
            Color(0xFF80A8FF),
            Color(0xFF5C8FFF),
            Color(0xFF2167FF),
            Color(0xFF0051FF)
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 100),
            const Text(
              '登录',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              '欢迎回来',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 50),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '邮箱或手机号',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const Divider(),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '密码',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  '忘记密码?',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    var username = _usernameController.text.trim();
                    var pwd = _passwordController.text.trim();
                    if (RegexUtils.isEmail(username)) {
                      serviceLocator.get<LoginBloc>().add(LoginRequestEvent(
                          username: username,
                          password: pwd,
                          loginType: LoginType.emailLogin.code));
                    } else if (RegexUtils.isPhoneNumber(username)) {
                      serviceLocator.get<LoginBloc>().add(LoginRequestEvent(
                          username: username,
                          password: pwd,
                          loginType: LoginType.phoneLogin.code));
                    } else {
                      print("username: $username, password: $pwd");
                      var size = MediaQuery.of(context).size;
                      ShowWidgetUtil.showToast(context, "手机号码或邮箱格式错误",
                          left: size.width * 0.4, bottom: size.height * 3 / 4);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB5CCFF),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    '登录',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    GoRouter.of(context).push("/phoneRegister");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB5CCFF),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    '注册',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
