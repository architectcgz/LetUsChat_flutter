import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:let_us_chat/widgets/app_bar_with_title_arrow.dart';
import '../../repository/models/friend.dart';
import '../../repository/models/group.dart';

class SearchResultsPage extends StatelessWidget {
  final List<Friend>? friends;
  final List<Group>? groups;

  const SearchResultsPage(
      {super.key, required this.friends, required this.groups});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWithTitleAndArrow(
        title: "搜索结果",
      ),
      body: ((friends == null || friends!.isEmpty) &&
              (groups == null || groups!.isEmpty))
          ? const Center(
              child: Text("该用户/群不存在"),
            )
          : ListView(
              children: [
                if (friends != null && friends!.isNotEmpty) ...[
                  // Contacts Section
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      '联系人',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  ...friends!.map(
                    (friend) => ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                            NetworkImage(friend.avatar), // Friend's avatar
                      ),
                      title: Text(friend.nickname),
                      subtitle: Text(friend.signature ?? '无签名'),
                      onTap: () {
                        GoRouter.of(context)
                            .pushNamed("addFriend", extra: friend);
                      },
                    ),
                  ),
                ],
                if (groups != null && groups!.isNotEmpty) ...[
                  // Groups Section
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      '群聊',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  ...groups!.map((group) => ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              Colors.blue, // You can add a group image here
                          child: Text(group.groupName.substring(0, 1)),
                        ),
                        title: Text(group.groupName),
                        subtitle: Text('包含: ${group.groupName}'),
                      )),
                ],
              ],
            ),
    );
  }
}
