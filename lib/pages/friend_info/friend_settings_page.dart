import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:let_us_chat/blocs/contact_list/contact_list_bloc.dart';
import 'package:let_us_chat/blocs/friend_info/friend_info_bloc.dart';
import 'package:let_us_chat/core/utils/injection_container.dart';
import 'package:let_us_chat/pages/utils/show_widget_util.dart';
import 'package:let_us_chat/widgets/app_bar_with_title_arrow.dart';

import '../../repository/models/friend.dart';

class FriendSettingsPage extends StatefulWidget {
  final Friend friend;
  const FriendSettingsPage({super.key, required this.friend});
  @override
  State<FriendSettingsPage> createState() => _FriendSettingsPageState();
}

class _FriendSettingsPageState extends State<FriendSettingsPage> {
  bool isStarFriend = false;
  bool isBlackListed = false;

  @override
  Widget build(BuildContext context) {
    Friend friend = widget.friend;
    return Scaffold(
        appBar: AppBarWithTitleAndArrow(
          title: "资料设置",
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<ContactListBloc, ContactListState>(
                listener: (context, state) {
              if (state is DeleteFriendSucceed) {
                ShowWidgetUtil.showToast(context, "删除成功");
                GoRouter.of(context).go("/contactList");
              } else if (state is DeleteFriendFailed) {
                ShowWidgetUtil.showToast(context, "删除失败: ${state.message}");
              }
            }),
          ],
          child: Column(
            children: [
              ListTile(
                title: const Text('设置备注和标签'),
                trailing: Text(friend.alias ?? friend.nickname),
                onTap: () {
                  GoRouter.of(context).pushNamed("updateAlias", extra: {
                    'friendUid': friend.userId,
                    'alias': friend.alias ?? friend.nickname,
                    'friendInfoBloc': context.read<FriendInfoBloc>()
                  });
                },
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('朋友权限'),
                onTap: () {
                  // Handle tap for 朋友权限
                },
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('把他推荐给朋友'),
                onTap: () {
                  // Handle tap for 把他推荐给朋友
                },
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('添加到桌面'),
                onTap: () {
                  // Handle tap for 添加到桌面
                },
              ),
              Divider(height: 10, color: Colors.grey[200]),
              SwitchListTile(
                title: const Text('设为星标朋友'),
                value: isStarFriend,
                onChanged: (bool value) {
                  setState(() {
                    isStarFriend = value;
                  });
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('加入黑名单'),
                value: isBlackListed,
                onChanged: (bool value) {
                  setState(() {
                    isBlackListed = value;
                  });
                },
              ),
              Divider(height: 10, color: Colors.grey[200]),
              ListTile(
                title: const Text('投诉'),
                onTap: () {
                  // Handle tap for 投诉
                },
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('确认删除'),
                            content: const Text(
                              '确定要删除好友吗? 消息记录会同时删除',
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
                                  serviceLocator.get<ContactListBloc>().add(
                                      DeleteFriendEvent(
                                          friendUid: friend.userId));
                                  Navigator.of(context).pop();
                                },
                                child: const Text('确认'),
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.red),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text('删除'),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
