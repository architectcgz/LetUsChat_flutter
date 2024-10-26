import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:let_us_chat/widgets/text_field.dart';

import '../../blocs/global_user/global_user_bloc.dart';
import '../../core/utils/injection_container.dart';
import '../../models/user.dart';

class SetUsernamePage extends StatefulWidget {
  const SetUsernamePage({super.key});

  @override
  State<SetUsernamePage> createState() => _SetUsernamePageState();
}

class _SetUsernamePageState extends State<SetUsernamePage> {
  late final GlobalUserBloc globalUserBloc;
  late final User? globalUser;
  late final TextEditingController _usernameController;
  bool _isModified = false;
  static const int _maxUsernameLength = 10; //最大昵称长度
  int _remainingCharacters = 10;

  @override
  void initState() {
    globalUserBloc = serviceLocator.get<GlobalUserBloc>();
    globalUser = globalUserBloc.globalUser;
    _usernameController = TextEditingController(text: globalUser!.username);
    _usernameController.addListener(_onUsernameChanged);
    _remainingCharacters =
        _maxUsernameLength - _usernameController.text.length; //初始化昵称字数
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.removeListener(_onUsernameChanged);
    _usernameController.dispose();
    super.dispose();
  }

  void _onUsernameChanged() {
    setState(() {
      _isModified = _usernameController.text != globalUser!.username;
      //计算剩余字符数
      _remainingCharacters =
          _maxUsernameLength - _usernameController.text.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GlobalUserBloc, GlobalUserState>(
        listener: (context, state) {
      if (state is UsernameExceedLength) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("昵称的长度过长，应在10个字符以内"),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (state is UpdateUsernameFailed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (state is UpdateUsernameSucceed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("用户昵称更新成功"),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // 更新成功后，重置保存按钮的状态
        setState(() {
          _isModified = false;
          _usernameController.text = globalUser!.username;
        });
      }
    }, builder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("更改昵称"),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: _isModified ? Colors.green : Colors.grey,
              ),
              onPressed: _isModified
                  ? () {
                      String username = _usernameController.text;
                      if (username.isNotEmpty) {
                        globalUserBloc.add(UpdateUsernameEvent(
                            username: _usernameController.text));
                      }
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
            children: [
              buildTextField(
                controller: _usernameController,
                label: "昵称",
                inputFormatters: [
                  LengthLimitingTextInputFormatter(_maxUsernameLength)
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              const Text(
                "为自己起一个好名字吧",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                '剩余字符数: $_remainingCharacters',
                style: TextStyle(
                    color: _remainingCharacters < 0 ? Colors.red : Colors.grey),
              ),
            ],
          ),
        ),
      );
    });
  }
}
