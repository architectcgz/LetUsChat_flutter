import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:let_us_chat/blocs/chat_list/chat_list_bloc.dart';
import 'package:let_us_chat/core/constants/enums.dart';
import 'package:let_us_chat/pages/utils/show_widget_util.dart';
import 'package:let_us_chat/widgets/app_bar_with_search.dart';

import '../../core/utils/injection_container.dart';
import '../../models/chat_item.dart';
import '../../repository/local/local_friend_repo.dart';
import '../../widgets/chat_list_tile.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListStatePage();
}

class _ChatListStatePage extends State<ChatListPage> {
  late List<ChatItem?> _recentChatList;
  late RecentChatListBloc _chatListBloc;
  @override
  void initState() {
    super.initState();
    _recentChatList = [];
    _chatListBloc = context.read<RecentChatListBloc>()
      ..add(LoadChatListEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWithSearch(title: "聊天"),
      body: PageTransitionSwitcher(
        transitionBuilder: (Widget child, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return FadeThroughTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child);
        },
        child: RefreshIndicator(
          onRefresh: () async {
            print("下拉刷新");
          },
          child: BlocConsumer<RecentChatListBloc, ChatListState>(
            listener: (context, state) {
              if (state is NewMessageReceived) {
                var itemIndex = _recentChatList
                    .indexWhere((e) => e?.chatName == state.chatItem.chatName);
                if (itemIndex != -1) {
                  var item = _recentChatList[itemIndex]!;
                  print("这个聊天项已存在");
                  _recentChatList.remove(item); //删除旧的,将最新的置于上方
                  _recentChatList.insert(0, state.chatItem);
                  print(item.toString());
                } else {
                  print("这个聊天项不存在,添加");
                  _recentChatList.add(state.chatItem);
                }
              } else if (state is LoadChatListSucceed) {
                _recentChatList = state.chatItems;
              } else if (state is ClearRecentChatHistorySucceed) {
                var itemIndex = _recentChatList
                    .indexWhere((e) => e?.chatId == state.chatId);
                if (itemIndex != -1) {
                  var item = _recentChatList[itemIndex]!;
                  print("${item.chatName}的消息记录被清空");
                  item.lastMessage = '';
                  item.unreadCount = 0;
                }
              } else if (state is RecentChatUpdated) {
                var itemIndex = _recentChatList
                    .indexWhere((e) => e?.chatId == state.chatId);
                if (itemIndex != -1) {
                  print("与${state.chatId}的最近聊天记录已经更新");
                  var item = _recentChatList[itemIndex]!
                    ..lastMessage = state.lastMessage
                    ..lastChatTime = state.lastChatTime;
                  _recentChatList.removeAt(itemIndex);
                  _recentChatList.insert(0, item);
                }
              } else if (state is DeleteChatSucceed) {
                var itemIndex = _recentChatList
                    .indexWhere((e) => e?.chatId == state.chatId);
                if (itemIndex >= 0) {
                  _recentChatList.removeAt(itemIndex);
                }
              } else if (state is AddToChatListSucceed) {
                var itemIndex = _recentChatList
                    .indexWhere((e) => e?.chatId == state.chatItem.chatId);
                if (itemIndex >= 0) {
                  _recentChatList.removeAt(itemIndex);
                }
                _recentChatList.insert(0, state.chatItem);
                print("添加到chatList成功");
              } else if (state is ChatItemUpdated) {
                print("更新置顶状态: ${state.chatItem.isPinned}");
                var idx = _recentChatList
                    .indexWhere((e) => e?.chatId == state.chatItem.chatId);
                if (idx >= 0) {
                  _recentChatList[idx] = state.chatItem;
                } else {
                  print("recentChatList找不到这个项");
                }
              }
            },
            builder: (context, state) {
              if (state is ChatListLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ChatListEmpty) {
                return const Center(
                    child: Text(
                  '还没有聊天过呢~',
                  style: TextStyle(fontSize: 18),
                ));
              } else if (state is LoadChatListFailed) {
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<RecentChatListBloc>().add(LoadChatListEvent());
                  },
                  child: const Center(child: Text('加载失败,请尝试刷新一下~')),
                );
              } else if (_recentChatList.isEmpty) {
                return const Center(child: Text('还没有聊天过呢~'));
              }
              return ListView.builder(
                itemCount: _recentChatList.length,
                itemBuilder: (context, index) {
                  final chatItem = _recentChatList[index];
                  if (chatItem != null) {
                    return ChatListTile(
                      chatItem: chatItem,
                      onTap: () {
                        switch (chatItem.chatType) {
                          case ChatType.singleChat:
                            _chatListBloc
                                .add(ReadMessageEvent(chatId: chatItem.chatId));
                            var friend = serviceLocator
                                .get<LocalFriendRepo>()
                                .getFriend(chatItem.chatId);
                            if (friend != null) {
                              GoRouter.of(context)
                                  .push("/singleChatPage", extra: friend);
                            } else {
                              ShowWidgetUtil.showToast(context, "此好友不存在");
                            }

                            setState(() {
                              chatItem.unreadCount = 0;
                            });
                            break;
                          case ChatType.groupChat:
                            _chatListBloc
                                .add(ReadMessageEvent(chatId: chatItem.chatId));
                            GoRouter.of(context).pushNamed("groupChatPage",
                                extra: chatItem.chatId);
                            setState(() {
                              chatItem.unreadCount = 0;
                            });
                            break;
                        }
                      },
                    );
                  }
                  return null;
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
