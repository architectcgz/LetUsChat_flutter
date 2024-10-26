import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:let_us_chat/blocs/add_friend_group/add_friend_group_bloc.dart';
import 'package:let_us_chat/widgets/app_bar_with_title_arrow.dart';
import 'package:let_us_chat/widgets/inkwell_no_color.dart';

import '../../blocs/global_user/global_user_bloc.dart';
import '../../core/utils/injection_container.dart';
import '../../data/search_result_data.dart';

class AddFriendGroupPage extends StatefulWidget {
  const AddFriendGroupPage({super.key});

  @override
  State<AddFriendGroupPage> createState() => _AddFriendGroupPageState();
}

class _AddFriendGroupPageState extends State<AddFriendGroupPage> {
  final TextEditingController _searchController = TextEditingController();
  final globalUserBloc = serviceLocator.get<GlobalUserBloc>();
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddFriendGroupBloc, AddFriendGroupState>(
      listener: (context, state) {
        if (state is Searching) {
          showDialog(
            context: context,
            barrierDismissible: false, // 不允许点击外部关闭
            builder: (BuildContext context) {
              return const Center(
                child: CircularProgressIndicator(), // 显示加载中的圆形进度条
              );
            },
          );
        } else {
          // 关闭加载对话框
          Navigator.of(context, rootNavigator: true).pop();

          if (state is SearchSucceed) {
            FocusScope.of(context).unfocus();
            GoRouter.of(context).pushNamed(
              "searchResult",
              extra: SearchResultData(
                friends: state.friendResult,
                groups: state.groupResult,
              ),
            );
          } else if (state is SearchFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("搜索失败: ${state.message}"),
              ),
            );
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: const AppBarWithTitleAndArrow(
            title: '添加好友/群',
            centerTitle: true,
          ),
          body: Column(
            children: [
              // 搜索框
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: '好友UID/群UID',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    ElevatedButton(
                      onPressed: () {
                        // Trigger the search event
                        final query = _searchController.text;
                        context
                            .read<AddFriendGroupBloc>()
                            .add(SearchEvent(query: query));
                      },
                      child: const Text('搜索'),
                    ),
                  ],
                ),
              ),
              //我的UID部分
              InkWell(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  GoRouter.of(context).pushNamed("qrCode");
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("我的UID: ${globalUserBloc.globalUser!.userId}"),
                    const SizedBox(width: 10),
                    const Icon(Icons.qr_code),
                  ],
                ),
              ),

              //其余部分
              InkWellNoColor(
                onTap: () {
                  //print("点击了空白区域,关闭输入框");
                  FocusScope.of(context).unfocus();
                },
                child: const SizedBox(
                  height: 40,
                  width: double.infinity,
                ),
              ),
              // 列表项
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.camera_alt),
                      title: const Text('雷达加朋友'),
                      onTap: () {
                        // Handle tap
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.person_add),
                      title: const Text('添加身边的朋友'),
                      onTap: () {
                        // Handle tap
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.group),
                      title: const Text('面对面建群'),
                      onTap: () {
                        // Handle tap
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.credit_card),
                      title: const Text('扫一扫'),
                      onTap: () {
                        // Handle tap
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.contacts),
                      title: const Text('手机联系人'),
                      onTap: () {
                        // Handle tap
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.public),
                      title: const Text('公众号'),
                      onTap: () {
                        // Handle tap
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.business),
                      title: const Text('企业微信联系人'),
                      onTap: () {
                        // Handle tap
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
