import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:let_us_chat/blocs/contact_list/contact_list_bloc.dart';
import 'package:let_us_chat/core/utils/injection_container.dart';
import 'package:let_us_chat/pages/utils/show_widget_util.dart';
import '../../blocs/friend_request_list/friend_request_list_bloc.dart';
import '../../repository/models/request_friend_info.dart';
import '../../widgets/clickable_text_with_button.dart';

class FriendRequestListPage extends StatefulWidget {
  const FriendRequestListPage({super.key});
  @override
  State<FriendRequestListPage> createState() => _FriendRequestListPageState();
}

class _FriendRequestListPageState extends State<FriendRequestListPage> {
  final ContactListBloc contactListBloc = serviceLocator.get<ContactListBloc>();
  final FriendRequestListBloc friendRequestListBloc =
      serviceLocator.get<FriendRequestListBloc>();
  late List<RequestFriendInfo> recentRequestList;
  late List<RequestFriendInfo> olderRequestList;
  @override
  void initState() {
    super.initState();
    print("添加获取请求列表事件");
    friendRequestListBloc.add(GetFriendRequestListEvent());
    recentRequestList = [];
    olderRequestList = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context).goNamed('contactList');
          },
        ),
        title: const Text("新的朋友"),
        actions: [
          ClickableTextWithIcon(
            text: "添加朋友",
            icon: Icons.person_add,
            onTap: () {
              GoRouter.of(context).pushNamed("addFriendGroup");
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "账号/手机号",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text("添加手机联系人"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Add contacts action
            },
          ),
          const Divider(),
          BlocConsumer<FriendRequestListBloc, FriendRequestListState>(
              listener: (context, state) {
            if (state is GetFriendRequestListFailed) {
              ShowWidgetUtil.showSnackBar(context, state.message);
            }
          }, builder: (context, state) {
            if (state is FriendRequestListLoading) {
              return const Expanded(
                child: Center(child: CircularProgressIndicator()),
              );
            } else if (state is GetFriendRequestListSucceed) {
              recentRequestList = state.recentRequests;
              olderRequestList = state.olderRequests;
            } else if (state is GetFriendRequestListFailed) {
              return const Expanded(
                child: Center(child: Text("获取好友请求失败")),
              );
            } else if (state is FriendRequestListEmpty) {
              return const Center(
                child: Text("没有新的朋友请求"),
              );
            }
            return Expanded(
              child: ListView(
                children: [
                  if (recentRequestList.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "近三天",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    ),
                    ...recentRequestList.map(
                      (request) => _buildFriendRequestItem(
                          request: request,
                          isAccepted: request.status != 0,
                          canAdd: true),
                    ),
                    const Divider(),
                  ],
                  if (olderRequestList.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "三天前",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    ),
                    ...olderRequestList.map(
                      (request) => _buildFriendRequestItem(
                          request: request,
                          isAccepted: request.status != 0,
                          canAdd: false),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFriendRequestItem(
      {required RequestFriendInfo request,
      required bool isAccepted,
      required bool canAdd}) {
    return InkWell(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(request.avatar),
        ),
        title: Text(request.nickname),
        subtitle: Text(request.requestMessage ?? ""),
        trailing: isAccepted
            ? const Text(
                "已添加",
                style: TextStyle(color: Colors.grey),
              )
            : canAdd
                ? ElevatedButton(
                    onPressed: () async {
                      final result = await GoRouter.of(context).pushNamed(
                        "acceptRequest",
                        extra: {
                          "requestMessage": request.requestMessage,
                          "friendUid": request.friendUid
                        },
                      ) as Map<String, dynamic>?;

                      if (result != null && result['accepted'] == true) {
                        String? alias = result['alias'] as String?;
                        if (mounted) {
                          contactListBloc.add(AddFriendEvent(
                              friendUid: request.friendUid, alias: alias));
                        }
                      }
                    },
                    child: const Text("接受"),
                  )
                : const Text("好友请求已过期,无法添加"),
      ),
      onTap: () {
        print("触发点击事件");
        if (request.status == 1) {
          if (contactListBloc.contactUidSet.contains(request.friendUid)) {
            GoRouter.of(context).pushNamed(
              "friendInfo",
              extra: request.friendUid,
            );
          } else {
            GoRouter.of(context)
                .pushNamed("requestFriendInfo", extra: request.friendUid);
          }
        } else {
          GoRouter.of(context)
              .pushNamed("requestFriendInfo", extra: request.friendUid);
        }
      },
    );
  }
}
