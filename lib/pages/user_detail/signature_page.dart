import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:let_us_chat/widgets/text_field.dart';
import '../../blocs/global_user/global_user_bloc.dart';
import 'package:flutter/services.dart';
import '../../core/utils/injection_container.dart';
import '../../models/user.dart';

class SignaturePage extends StatefulWidget {
  const SignaturePage({super.key});

  @override
  State<SignaturePage> createState() => _SignaturePageState();
}

class _SignaturePageState extends State<SignaturePage> {
  late final GlobalUserBloc globalUserBloc;
  late final User? globalUser;
  late final TextEditingController _signatureController;
  bool _isModified = false;
  static const int _maxSignatureLength = 20; // 最大签名长度
  int _remainingCharacters = 20;

  @override
  void initState() {
    globalUserBloc = serviceLocator.get<GlobalUserBloc>();
    globalUser = globalUserBloc.globalUser;
    _signatureController =
        TextEditingController(text: globalUserBloc.globalUser!.signature);
    _signatureController.addListener(_onSignatureChanged);
    _remainingCharacters =
        _maxSignatureLength - _signatureController.text.length; //初始化签名字数
    super.initState();
  }

  void _onSignatureChanged() {
    setState(() {
      if (globalUser!.signature == null) {
        _isModified = _signatureController.text.isNotEmpty;
      } else {
        _isModified = _signatureController.text != globalUser!.signature;
      }
      // 计算剩余字符数
      _remainingCharacters =
          _maxSignatureLength - _signatureController.text.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GlobalUserBloc, GlobalUserState>(
      listener: (context, state) {
        if (state is SignatureExceedLength) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("签名的长度过长，应在20个字符以内"),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is UpdateSignatureFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is UpdateSignatureSucceed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("用户签名更新成功"),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
          // 更新成功后，重置保存按钮的状态
          setState(() {
            _isModified = false;
            _signatureController.text = globalUser!.signature ?? '';
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("修改签名"),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: _isModified ? Colors.green : Colors.grey,
                ),
                onPressed: _isModified
                    ? () {
                        globalUserBloc.add(
                          UpdateSignatureEvent(
                              newSignature: _signatureController.text),
                        );
                      }
                    : null,
                child: const Text(
                  "保存",
                  style: TextStyle(color: Colors.white), // 设置文字颜色为白色
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildTextField(
                  controller: _signatureController,
                  label: "签名",
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(_maxSignatureLength),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '剩余字符数: $_remainingCharacters',
                  style: TextStyle(
                      color:
                          _remainingCharacters < 0 ? Colors.red : Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }
}
