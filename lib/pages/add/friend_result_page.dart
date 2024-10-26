import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:let_us_chat/blocs/add_friend_group/add_friend_group_bloc.dart';
import 'package:let_us_chat/widgets/app_bar_with_title_arrow.dart';

import '../../repository/models/friend.dart';

class FriendResultPage extends StatefulWidget {
  final Friend friend;

  const FriendResultPage({super.key, required this.friend});
  @override
  State<FriendResultPage> createState() => _FriendResultPageState();
}

class _FriendResultPageState extends State<FriendResultPage> {
  @override
  Widget build(BuildContext context) {
    final friend = widget.friend;
    return BlocConsumer<AddFriendGroupBloc, AddFriendGroupState>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
          appBar: const AppBarWithTitleAndArrow(
            title: "",
            centerTitle: true,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(friend.avatar),
                  radius: 30.0,
                ),
                title: Text(friend.nickname,
                    style: const TextStyle(fontSize: 20.0)),
                subtitle: Text('地区: ${friend.location ?? '未知'}'),
              ),
              const Divider(),
              ListTile(
                title: const Text('个性签名'),
                subtitle: Text(friend.signature ?? '无签名'),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width - 20, // 设置按钮的宽度
                    child: ElevatedButton(
                      onPressed: () {
                        //context.read<AddFriendBloc>().add(RequestFriendEvent(friendUid: friend.userId));
                        GoRouter.of(context)
                            .pushNamed("friendResult", extra: friend);
                      },
                      child: const Text('添加到通讯录'),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
