import 'package:flutter/material.dart';
import 'package:let_us_chat/blocs/chat_list/chat_list_bloc.dart';
import 'package:let_us_chat/core/utils/injection_container.dart';
import 'package:let_us_chat/models/chat_item.dart';
import 'package:let_us_chat/widgets/app_bar_with_title_arrow.dart';
import '../../blocs/chat/abstract_chat/abstract_chat_bloc.dart';
import '../../blocs/chat/single_chat/single_chat_bloc.dart';
import '../../repository/models/friend.dart';

class SingleChatInfoPage extends StatefulWidget {
  final ChatItem chatItem;
  final SingleChatBloc singleChatBloc;
  const SingleChatInfoPage(
      {super.key, required this.chatItem, required this.singleChatBloc});
  @override
  State<SingleChatInfoPage> createState() => _SingleChatInfoPageState();
}

class _SingleChatInfoPageState extends State<SingleChatInfoPage> {
  late Friend _friend;
  late SingleChatBloc _singleChatBloc;

  @override
  void initState() {
    super.initState();
    _singleChatBloc = widget.singleChatBloc;
    _friend = _singleChatBloc.friend;
  }

  @override
  void dispose() {
    print("single_chat_info_page disposed");
    //在此之前修改
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithTitleAndArrow(
        title: '聊天信息',
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // Avatar Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(_friend.avatar),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          const Divider(),

          // Settings Section
          ListTile(
            title: const Text('查找聊天记录'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Handle tap
            },
          ),
          const Divider(),

          // Toggle Settings
          SwitchListTile(
            title: const Text('消息免打扰'),
            value: false,
            onChanged: (bool value) {
              // Handle switch
            },
          ),
          SwitchListTile(
            title: const Text('置顶聊天'),
            value: false,
            onChanged: (bool value) {
              serviceLocator
                  .get<RecentChatListBloc>()
                  .add(PinChatEvent(chatItem: widget.chatItem));
            },
          ),
          SwitchListTile(
            title: const Text('提醒'),
            value: false,
            onChanged: (bool value) {
              // Handle switch
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('设置当前聊天背景'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Handle tap
            },
          ),
          ListTile(
            title: const Text('清空聊天记录'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('确认删除'),
                    content: const Text(
                      '确定要删除历史消息记录吗？此操作不可恢复。',
                      style: TextStyle(fontSize: 18),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () {
                          _singleChatBloc.add(ClearChatHistoryEvent());
                          Navigator.of(context).pop();
                        },
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('确认'),
                      ),
                    ],
                  );
                },
              );
            },
          ),

          ListTile(
            title: const Text('投诉'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Handle tap
            },
          ),
        ],
      ),
    );
  }
}
