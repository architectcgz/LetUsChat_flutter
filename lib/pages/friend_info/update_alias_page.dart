import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:let_us_chat/blocs/friend_info/friend_info_bloc.dart';
import 'package:let_us_chat/pages/utils/show_widget_util.dart';
import '../../widgets/text_field.dart';

class SetFriendAliasPage extends StatefulWidget {
  final String friendUid;
  final String? alias;
  const SetFriendAliasPage({super.key, required this.friendUid, this.alias});
  @override
  State<SetFriendAliasPage> createState() => _SetFriendAliasPageState();
}

class _SetFriendAliasPageState extends State<SetFriendAliasPage> {
  late final TextEditingController _aliasController;
  late final FriendInfoBloc _friendInfoBloc;
  late String? _alias;
  bool _isModified = false;
  static const int _maxUsernameLength = 30; //最大备注长度
  int _remainingCharacters = 30;

  @override
  void initState() {
    super.initState();
    _alias = widget.alias;
    _aliasController = TextEditingController(text: widget.alias);
    _friendInfoBloc = context.read<FriendInfoBloc>();
    _aliasController.addListener(_onUsernameChanged);
    _remainingCharacters =
        _maxUsernameLength - _aliasController.text.length; //初始化昵称字数
  }

  @override
  void dispose() {
    _aliasController.removeListener(_onUsernameChanged);
    _aliasController.dispose();
    super.dispose();
  }

  void _onUsernameChanged() {
    setState(() {
      _isModified = _aliasController.text != widget.alias;
      //计算剩余字符数
      _remainingCharacters = _maxUsernameLength - _aliasController.text.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FriendInfoBloc, FriendInfoState>(
        listener: (context, state) {
      if (state is AliasExceedLength) {
        ShowWidgetUtil.showSnackBar(context, "备注的长度过长，应在30个字符以内");
      } else if (state is UpdateAliasFailed) {
        ShowWidgetUtil.showSnackBar(context, state.message);
      } else if (state is AliasUpdated) {
        ShowWidgetUtil.showSnackBar(context, "备注更新成功");
        _alias = state.newAlias;
        // 更新成功后，重置保存按钮的状态
        setState(() {
          _isModified = false;
          _aliasController.text = _alias!;
        });
      }
    }, builder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("更改备注"),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: _isModified ? Colors.green : Colors.grey,
              ),
              onPressed: _isModified
                  ? () {
                      String username = _aliasController.text;
                      if (username.isNotEmpty) {
                        _friendInfoBloc.add(UpdateFriendAliasEvent(
                            newAlias: _aliasController.text,
                            friendUid: widget.friendUid));
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
                controller: _aliasController,
                label: "备注",
                inputFormatters: [
                  LengthLimitingTextInputFormatter(_maxUsernameLength)
                ],
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
