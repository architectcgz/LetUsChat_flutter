import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:let_us_chat/blocs/chat_list/chat_list_bloc.dart';
import 'package:let_us_chat/core/utils/injection_container.dart';

import '../models/chat_item.dart';

class ChatListTile extends StatefulWidget {
  final ChatItem chatItem;
  final VoidCallback onTap;

  const ChatListTile({Key? key, required this.chatItem, required this.onTap})
      : super(key: key);

  @override
  State<ChatListTile> createState() => _ChatListTileState();
}

class _ChatListTileState extends State<ChatListTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      color: Theme.of(context).brightness == Brightness.dark
          ? widget.chatItem.isPinned
              ? Colors.grey[800]
              : null
          : widget.chatItem.isPinned
              ? Colors.grey[200]
              : null,
      child: InkWell(
        onTap: widget.onTap,
        onLongPress: () {
          print("长按了ChatList的一个item");
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Slidable(
              endActionPane: ActionPane(
                extentRatio: 0.7,
                key: Key(widget.chatItem.chatId),
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) {
                      print("点击了置顶");
                      serviceLocator
                          .get<RecentChatListBloc>()
                          .add(PinChatEvent(chatItem: widget.chatItem));
                    },
                    backgroundColor: const Color(0xFF0392CF),
                    foregroundColor: Colors.white,
                    label: widget.chatItem.isPinned ? '取消置顶' : '置顶',
                    flex: 2,
                  ),
                  SlidableAction(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    onPressed: (context) {
                      print("点击了已读");
                      serviceLocator.get<RecentChatListBloc>().add(
                          ReadMessageEvent(chatId: widget.chatItem.chatId));
                    },
                    backgroundColor: Colors.orangeAccent,
                    foregroundColor: Colors.white,
                    label: '标为已读',
                    flex: 3,
                  ),
                  SlidableAction(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    onPressed: (context) {
                      print("点击了删除");
                      serviceLocator.get<RecentChatListBloc>().add(
                          DeleteRecentChatEvent(
                              chatId: widget.chatItem.chatId));
                      print(
                          "将DeleteRecentChatEvent 挂载到ChatListBloc处理,chatId:${widget.chatItem.chatId}");
                    },
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    label: '删除',
                    flex: 2,
                  ),
                ],
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(widget.chatItem.avatarUrl),
                  radius: 25,
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.chatItem.chatName,
                    ),
                    Text(
                      widget.chatItem.getFormattedTime(),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.chatItem.lastMessage,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    if (widget.chatItem.unreadCount > 0)
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.red,
                        child: Text(
                          '${widget.chatItem.unreadCount}',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 72.0, right: 16.0), // 左右缩进，保持对齐
              child: Divider(
                color: Colors.grey[300],
                thickness: 1,
                height: 0, // 设置为 0 保证高度不增加
              ),
            ),
          ],
        ),
      ),
    );
  }
}
