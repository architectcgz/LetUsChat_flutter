import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:let_us_chat/pages/utils/show_widget_util.dart';
import 'package:let_us_chat/widgets/app_bar_with_title_arrow.dart';
import '../../blocs/register/register_bloc.dart';
import '../../widgets/text_field.dart';

class EmailRegisterPage extends StatefulWidget {
  const EmailRegisterPage({super.key});

  @override
  State<EmailRegisterPage> createState() => _EmailRegisterPageState();
}

class _EmailRegisterPageState extends State<EmailRegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _captchaController = TextEditingController();
  int _countdown = 0;
  final duration = const Duration(seconds: 1);
  Timer? timer;
  void _startCountdown(int countTimes) {
    if (timer != null) {
      timer!.cancel(); //取消上一次的计时
    }
    _countdown = countTimes;
    timer = Timer.periodic(duration, (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
  }

  void _onEmailChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _emailController.removeListener(_onEmailChanged);
    _emailController.dispose();
    _nicknameController.dispose();
    _passwordController.dispose();
    _captchaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterBloc, RegisterState>(
      listener: (context, state) async {
        if (state is SendCaptchaFailed) {
          if (state.code == 408) {
            if (kDebugMode) {
              print(state.code);
            }
          }
          _startCountdown(3);
          ShowWidgetUtil.showSnackBar(context, state.message);
        } else if (state is RegisterFailed) {
          ShowWidgetUtil.showSnackBar(context, state.message);
        } else if (state is RegisterSucceed) {
          ShowWidgetUtil.showSnackBar(context, "注册成功");
          GoRouter.of(context).push('/phoneLogin');
        }
      },
      builder: (context, state) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            appBar: const AppBarWithTitleAndArrow(
              appbarColor: Color(0xFFB5CCFF),
            ),
            body: Container(
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
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(
                      child: Text(
                        "邮箱注册",
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(height: 20),
                    buildTextField(
                      controller: _emailController,
                      label: "邮箱",
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10),
                    buildTextField(
                      controller: _nicknameController,
                      label: "昵称",
                    ),
                    const SizedBox(height: 10),
                    buildTextField(
                      controller: _passwordController,
                      label: "密码",
                      obscureText: true,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _captchaController,
                            decoration: const InputDecoration(labelText: "验证码"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                            onPressed: _countdown == 0 &&
                                    _emailController.text.isNotEmpty
                                ? () {
                                    context.read<RegisterBloc>().add(
                                        RegisterSendCaptchaEvent(
                                            captchaType: 0,
                                            username:
                                                _emailController.text.trim()));
                                    _startCountdown(60);
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB5CCFF),
                            ),
                            child: Text(
                              _countdown > 0 ? "$_countdown秒后重发" : "发送验证码",
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            )),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _onRegisterButtonPressed(context);
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
                      child: state is RegisterHanding
                          ? const CircularProgressIndicator()
                          : const Text(
                              "注册",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onRegisterButtonPressed(BuildContext context) {
    final email = _emailController.text;
    final nickname = _nicknameController.text;
    final password = _passwordController.text;
    final captcha = _captchaController.text;

    context.read<RegisterBloc>().add(RegisterRequestEvent(
          username: email,
          nickname: nickname,
          password: password,
          captcha: captcha,
          registerType: 0,
        ));
  }
}
