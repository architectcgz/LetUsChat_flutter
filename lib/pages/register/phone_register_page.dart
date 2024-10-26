import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:let_us_chat/blocs/register/register_bloc.dart';
import 'package:let_us_chat/pages/utils/show_widget_util.dart';
import 'package:let_us_chat/widgets/app_bar_with_title_arrow.dart';

class PhoneRegisterPage extends StatefulWidget {
  const PhoneRegisterPage({super.key});

  @override
  State<PhoneRegisterPage> createState() => _PhoneRegisterPageState();
}

class _PhoneRegisterPageState extends State<PhoneRegisterPage> {
  final TextEditingController _phoneController = TextEditingController();
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

  void _onPhoneNumberChanged() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneNumberChanged);
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
          GoRouter.of(context).push('/phoneLogin');
        }
      },
      builder: (context, state) {
        bool isLoading = state is RegisterHanding;

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
                        "手机号注册",
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: "手机号码"),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _nicknameController,
                      decoration: const InputDecoration(labelText: "昵称"),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: "密码"),
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
                                  _phoneController.text.isNotEmpty
                              ? () {
                                  context.read<RegisterBloc>().add(
                                      RegisterSendCaptchaEvent(
                                          captchaType: 1,
                                          username: _phoneController.text));
                                  _startCountdown(60);
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB5CCFF),
                          ),
                          child: Text(
                            _countdown > 0 ? "$_countdown秒后重发" : "发送验证码",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  BlocProvider.of<RegisterBloc>(context).add(
                                    RegisterRequestEvent(
                                        registerType: 1,
                                        username: _phoneController.text,
                                        nickname: _nicknameController.text,
                                        password: _passwordController.text,
                                        captcha: _captchaController.text),
                                  );
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
                          child: isLoading
                              ? const CircularProgressIndicator()
                              : const Text(
                                  "注册",
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            GoRouter.of(context).push("/emailRegister");
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
                            "邮箱注册",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (timer != null) {
      timer!.cancel();
    }
    _phoneController.dispose();
    _nicknameController.dispose();
    _passwordController.dispose();
    _captchaController.dispose(); // Dispose of the captcha controller if used
  }
}
