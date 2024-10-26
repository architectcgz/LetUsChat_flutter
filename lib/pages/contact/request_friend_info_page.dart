import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:let_us_chat/blocs/friend_request_list/friend_request_list_bloc.dart';
import 'package:let_us_chat/blocs/request_friend_info/request_friend_info_bloc.dart';
import 'package:let_us_chat/core/utils/injection_container.dart';
import 'package:let_us_chat/pages/utils/show_widget_util.dart';

import '../../repository/models/request_friend_info.dart';
import '../unimplemented_page.dart';

class RequestFriendInfoPage extends StatefulWidget {
  final String requestUseId;
  const RequestFriendInfoPage({super.key, required this.requestUseId});
  @override
  State<RequestFriendInfoPage> createState() => _RequestFriendInfoPageState();
}

class _RequestFriendInfoPageState extends State<RequestFriendInfoPage> {
  late final RequestFriendInfo friendInfo;
  late final RequestFriendInfoBloc requestFriendInfoBloc;
  late final FriendRequestListBloc friendRequestListBloc;
  @override
  void initState() {
    super.initState();
    requestFriendInfoBloc = context.read<RequestFriendInfoBloc>();
    friendRequestListBloc = serviceLocator.get<FriendRequestListBloc>();
    requestFriendInfoBloc
        .add(GetRequestFriendInfoEvent(requestUserId: widget.requestUseId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('好友信息'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context).pop();
          },
        ),
      ),
      body: BlocConsumer<RequestFriendInfoBloc, RequestFriendInfoState>(
        listener: (context, state) {
          if (state is GetRequestUserInfoFailed) {
            ShowWidgetUtil.showSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is GettingRequestUserInfo) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GetRequestUserInfoSucceed) {
            final friendInfo = state.requestFriendInfo;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Section
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(friendInfo.avatar),
                        radius: 30,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                friendInfo.nickname,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Display location
                          Text(
                            "地区: ${friendInfo.location ?? ''}",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '申请信息',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            friendInfo.requestMessage ?? '暂无申请信息',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Action Section
                  ListTile(
                    title: const Text('设置备注和标签'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Handle setting remark and tags
                    },
                  ),
                  ListTile(
                    title: const Text('朋友权限'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Handle friend permissions
                    },
                  ),

                  const Divider(),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UnImplementedPage()),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text('朋友圈'),
                        ),
                        SizedBox(
                          height: 80,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: const [
                              Text("预设的照片区域")
                              // 朋友圈照片区域
                              // Image.asset('assets/image1.png', width: 80, height: 80),
                              // SizedBox(width: 8),
                              // Image.asset('assets/image2.png', width: 80, height: 80),
                              // SizedBox(width: 8),
                              // Image.asset('assets/image3.png', width: 80, height: 80),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(),

                  // Bottom Section
                  ElevatedButton(
                    onPressed: () async {
                      GoRouter.of(context).pushNamed("acceptRequest", extra: {
                        "friendUid": friendInfo.friendUid,
                        "requestMessage": friendInfo.requestMessage
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 40),
                    ),
                    child: const Text('前往验证'),
                  ),

                  const SizedBox(height: 16),

                  // Buttons for blacklist and report
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        onPressed: () {
                          // Handle add to blacklist
                        },
                        child: const Text('加入黑名单'),
                      ),
                      TextButton(
                        onPressed: () {
                          // Handle report
                        },
                        child: const Text('投诉'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else if (state is GetRequestUserInfoFailed) {
            return Center(
              child: Text('获取好友请求信息失败: ${state.message}'),
            );
          } else {
            print(state);
            return const Column(
              children: [Text("这里什么都没有~~~")],
            );
          }
        },
      ),
    );
  }
}
