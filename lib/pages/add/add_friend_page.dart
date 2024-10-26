import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:let_us_chat/blocs/add_friend_group/add_friend_group_bloc.dart';
import 'package:let_us_chat/models/friend_request.dart';

import '../../blocs/global_user/global_user_bloc.dart';
import '../../core/utils/injection_container.dart';
import '../../repository/models/friend.dart';
import '../../widgets/show_snack_bar.dart';

class AddFriendPage extends StatefulWidget {
  final Friend friend;
  const AddFriendPage({super.key, required this.friend});

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  String? requestMessage;
  String alias = "";
  String tag = "";
  String description = "";
  bool hideMoments = false;
  String friendPermission = "聊天、朋友圈、微信运动等";

  @override
  Widget build(BuildContext context) {
    final globalUserBloc = serviceLocator.get<GlobalUserBloc>();
    final friend = widget.friend;
    return BlocConsumer<AddFriendGroupBloc, AddFriendGroupState>(
      listener: (context, state) {
        if (state is RequestFriendSucceed) {
          showFloatSnackBar(
              context: context, content: "好友请求发送成功", bottomMargin: 0);
        } else if (state is RequestFriendFailed) {
          showFloatSnackBar(
              context: context, content: state.message, bottomMargin: 0);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('申请添加朋友'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('发送添加朋友申请',
                        style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: "请输入添加朋友申请信息",
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          setState(() {
                            requestMessage = value;
                          });
                        },
                        maxLines: null, // Allow multiple lines
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('设置备注', style: TextStyle(color: Colors.grey)),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: friend.nickname,
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          setState(() {
                            alias = value;
                          });
                        },
                      ),
                    ),
                    const Divider(),
                    const Text('设置朋友权限', style: TextStyle(color: Colors.grey)),
                    ListTile(
                      title: Text(friendPermission),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Navigate to permissions selection screen
                      },
                    ),
                    ListTile(
                      title: const Text('朋友圈和状态'),
                      subtitle: const Text('不让他(她)看'),
                      trailing: Switch(
                        value: hideMoments,
                        onChanged: (value) {
                          setState(() {
                            hideMoments = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      BlocProvider.of<AddFriendGroupBloc>(context).add(
                        RequestFriendEvent(
                          friendRequest: FriendRequest(
                            requestUserId: globalUserBloc.globalUser!.userId,
                            friendId: friend.userId,
                            requestMessage: requestMessage,
                            alias: alias == friend.nickname || alias.isEmpty
                                ? null
                                : alias,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(235, 200, 243, 60),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('发送'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
