import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:let_us_chat/blocs/navbar_bloc/navbar_bloc.dart';
import 'package:let_us_chat/core/utils/injection_container.dart';
import 'package:let_us_chat/pages/utils/show_widget_util.dart';
import 'package:let_us_chat/widgets/app_bar_with_search.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:azlistview/azlistview.dart';
import '../../blocs/contact_list/contact_list_bloc.dart';
import '../../repository/models/friend.dart';

class ContactAZItem extends ISuspensionBean {
  String title; // 显示名称
  String tag; // 字母索引标签
  Friend friend;

  ContactAZItem({
    required this.title,
    required this.tag,
    required this.friend,
  });

  @override
  String getSuspensionTag() => tag;
}

class ContactListPage extends StatefulWidget {
  const ContactListPage({super.key});

  @override
  State<ContactListPage> createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  late final ContactListBloc contactListBloc;
  late final NavbarBloc navbarBloc;
  late List<Friend> friendList;
  late int newFriendCount;
  late int newGroupCount;
  @override
  void initState() {
    super.initState();
    contactListBloc = serviceLocator.get<ContactListBloc>()
      ..add(LoadContactListEvent());
    navbarBloc = serviceLocator.get<NavbarBloc>();
    friendList = [];
    newFriendCount = 0;
    newGroupCount = 0;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContactListBloc, ContactListState>(
      listener: (context, state) {
        if (state is GetContactListFailed) {
          ShowWidgetUtil.showSnackBar(context, "联系人列表加载失败");
        } else if (state is NewFriendRequested) {
          setState(() {
            newFriendCount += 1;
          });
        }
      },
      builder: (context, state) {
        if (state is LoadContactListSucceed) {
          friendList = state.localFriendList;
          newFriendCount = state.newFriendCount;
          newGroupCount = state.newGroupCount;
        } else if (state is AddFriendSucceed) {
          friendList = contactListBloc.contactList;
        }
        return Scaffold(
          appBar: const AppBarWithSearch(title: "通讯录"),
          body: Column(
            children: [
              Expanded(
                  child: Column(
                children: [
                  _buildFixedItems(),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(16, 10, 0, 0),
                        child: Text(style: TextStyle(fontSize: 16), "联系人"),
                      ),
                    ],
                  ),
                  Expanded(
                    child: _buildAZListView(context, friendList),
                  ),
                ],
              ))
            ],
          ),
        );
      },
    );
  }

  Widget _buildFixedItems() {
    return Column(
      children: [
        _buildFixedItem(Icons.person_add, "新的朋友", Colors.orange, () {
          setState(() {
            newFriendCount = 0;
          });
          var badgeList = navbarBloc.badgeList;
          badgeList[1] = false;
          navbarBloc.add(UpdateBadgeEvent(badgeList: badgeList));
          GoRouter.of(context).pushNamed("requestFriendList");
        }, newFriendCount),
        _buildFixedItem(Icons.chat, "仅聊天的朋友", Colors.orange, () {
          GoRouter.of(context).pushNamed("unimplementedPage");
        }, 0),
        _buildFixedItem(Icons.group, "群聊", Colors.green, () {
          GoRouter.of(context).pushNamed("unimplementedPage");
        }, newGroupCount),
        _buildFixedItem(Icons.label, "标签", Colors.blue, () {
          GoRouter.of(context).pushNamed("unimplementedPage");
        }, 0),
        _buildFixedItem(Icons.public, "公众号", Colors.blue, () {
          GoRouter.of(context).pushNamed("unimplementedPage");
        }, 0),
      ],
    );
  }

  ///显示 新的朋友 群聊 等
  Widget _buildFixedItem(IconData icon, String title, Color color,
      VoidCallback onTap, int badgeCount) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: color,
            child: Icon(icon, color: Colors.white),
          ),
          title: Text(title),
          trailing: badgeCount > 0
              ? Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle),
                  constraints: const BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Text(
                    badgeCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : null,
          onTap: onTap,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 72.0, right: 16.0), // 左右缩进，保持对齐
          child: Divider(
            color: Colors.grey[300],
            thickness: 1,
            height: 0, // 设置为 0 保证高度不增加
          ),
        ),
      ],
    );
  }

  // 使用 AZListView 显示联系人列表
  Widget _buildAZListView(BuildContext context, List<Friend> contactList) {
    final azItems = _generateAZItemList(contactList);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AzListView(
        data: azItems,
        itemCount: azItems.length,
        itemBuilder: (context, index) {
          final item = azItems[index];
          return _buildContactItem(context, item);
        },
        indexBarData: SuspensionUtil.getTagIndexList(azItems),

        ///圆形提示框中词的大小
        indexHintBuilder: (context, hint) => Container(
          alignment: Alignment.center,
          width: 40,
          height: 40,
          decoration:
              const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
          child: Text(
            hint,
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        //右侧提示词控制
        indexBarOptions: const IndexBarOptions(
          needRebuild: true,
          indexHintTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          selectTextStyle:
              TextStyle(color: Colors.black, fontWeight: FontWeight.bold),

          ///右侧A-Z提示词区域
          selectItemDecoration: BoxDecoration(
            shape: BoxShape.circle, //右侧A-Z提示词形状
            color: Colors.blue,
          ),
          indexHintAlignment: Alignment.centerRight, //提示词的位置
          indexHintOffset: Offset(-10, 0), //提示词距离右侧A-Z距离
        ),
      ),
    );
  }

  List<ContactAZItem> _generateAZItemList(List<Friend> contactList) {
    List<ContactAZItem> azItemList = contactList.map((friend) {
      String title = friend.alias ?? friend.nickname;
      String pinyin = PinyinHelper.getPinyinE(title);
      String tag = pinyin.substring(0, 1).toUpperCase();
      return ContactAZItem(
          title: title,
          tag: RegExp(r'^[A-Z]$').hasMatch(tag) ? tag : '#',
          friend: friend);
    }).toList();

    // 根据拼音排序
    SuspensionUtil.sortListBySuspensionTag(azItemList);
    SuspensionUtil.setShowSuspensionStatus(azItemList);
    return azItemList;
  }

  Widget _buildContactItem(BuildContext context, ContactAZItem item) {
    return Column(
      children: [
        Offstage(
          offstage: !item.isShowSuspension,
          child: _buildHeader(item.tag),
        ),
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: Column(
            children: [
              SizedBox(
                height: 45,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(item.friend.avatar),
                  ),
                  title: Text(item.title),
                  onTap: () {
                    // 点击联系人的处理逻辑
                    GoRouter.of(context)
                        .pushNamed("friendInfo", extra: item.friend.userId);
                  },
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 72.0, right: 16.0), // 左右缩进，保持对齐
                child: Divider(
                  color: Colors.grey[300], // 自定义颜色
                  thickness: 1, // 分割线的厚度
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildHeader(String tag) => Container(
        height: 20,
        alignment: Alignment.centerLeft,
        child: Text(
          tag,
          softWrap: false,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
}
