import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:let_us_chat/blocs/contact_list/contact_list_bloc.dart';
import 'package:let_us_chat/core/utils/injection_container.dart';

import '../utils/show_widget_util.dart';

class AcceptRequestPage extends StatefulWidget {
  final String? requestMessage;
  final String friendUid;
  const AcceptRequestPage(
      {super.key, required this.requestMessage, required this.friendUid});

  @override
  State<AcceptRequestPage> createState() => _AcceptRequestPageState();
}

class _AcceptRequestPageState extends State<AcceptRequestPage> {
  final TextEditingController _remarkController = TextEditingController();
  bool allowChatFriends = true;
  bool preventViewingMyMoments = false;
  bool preventSeeingTheirMoments = false;
  late final ContactListBloc _contactListBloc;
  @override
  void initState() {
    super.initState();
    _contactListBloc = serviceLocator.get<ContactListBloc>();
    _remarkController.text =
        widget.requestMessage == null ? "" : widget.requestMessage!;
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContactListBloc, ContactListState>(
      listener: (context, state) {
        if (state is AddFriendSucceed) {
          ShowWidgetUtil.showSnackBar(context, "添加好友成功");
          GoRouter.of(context).pop();
        } else if (state is AddFriendFailed) {
          ShowWidgetUtil.showSnackBar(
              context, "接受好友请求失败,请稍后重试: ${state.message}");
        }
      },
      builder: (context, state) {
        var content = Scaffold(
          appBar: AppBar(
            title: const Text('通过朋友验证'),
          ),
          body: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width,
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('设置备注',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _remarkController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: '请输入备注',
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text('设置朋友权限',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ListTile(
                            title: const Text('聊天、朋友圈、微信运动等'),
                            trailing: Radio(
                              value: true,
                              groupValue: allowChatFriends,
                              onChanged: (value) {
                                setState(() {
                                  allowChatFriends = value!;
                                });
                              },
                            ),
                          ),
                          ListTile(
                            title: const Text('仅聊天'),
                            trailing: Radio(
                              value: false,
                              groupValue: allowChatFriends,
                              onChanged: (value) {
                                setState(() {
                                  allowChatFriends = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text('朋友圈和状态',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          SwitchListTile(
                            title: const Text('不让他(她)看'),
                            value: preventViewingMyMoments,
                            onChanged: (value) {
                              setState(() {
                                preventViewingMyMoments = value;
                              });
                            },
                          ),
                          SwitchListTile(
                            title: const Text('不看他(她)'),
                            value: preventSeeingTheirMoments,
                            onChanged: (value) {
                              setState(() {
                                preventSeeingTheirMoments = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            String? alias = _remarkController.text ==
                                        widget.requestMessage ||
                                    _remarkController.text.isEmpty
                                ? null
                                : _remarkController.text;
                            _contactListBloc.add(AddFriendEvent(
                                friendUid: widget.friendUid, alias: alias));
                          },
                          child: const Text('完成'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        return Stack(
          children: [
            content,
            if (state is AddingFriend) ...[
              const Opacity(
                opacity: 0.5,
                child: ModalBarrier(dismissible: false, color: Colors.black),
              ),
              const Center(child: CircularProgressIndicator()),
            ]
          ],
        );
      },
    );
  }
}
