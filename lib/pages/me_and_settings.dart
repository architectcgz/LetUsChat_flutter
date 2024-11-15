import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/global_user/global_user_bloc.dart';
import '../core/utils/injection_container.dart';
import '../models/user.dart';

class MeAndSettings extends StatefulWidget {
  const MeAndSettings({super.key});

  @override
  State<MeAndSettings> createState() => _MeAndSettingsState();
}

class _MeAndSettingsState extends State<MeAndSettings> {
  late final GlobalUserBloc globalUserBloc;
  late final User? globalUser;
  @override
  void initState() {
    globalUserBloc = serviceLocator.get<GlobalUserBloc>();
    globalUser = globalUserBloc.globalUser;
    if (globalUser == null) {
      print("globalUser为null,未获取!");
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GlobalUserBloc, GlobalUserState>(
      listener: (context, state) {
        if (state is UpdateAvatarSucceed) {
          setState(() {});
        }
      },
      builder: (context, state) {
        return SafeArea(
          child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 16, 8.0, 16.0),
              child: Column(
                children: [
                  //消除水波纹的效果
                  InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      if (globalUser != null) {
                        GoRouter.of(context).pushNamed("userDetail");
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(globalUser!.avatar),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                globalUser!.username,
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              Text("ID: ${globalUser!.userId}"),
                            ],
                          ),
                          const Spacer(), // 占据剩余空间，将Icons推到最右
                          const Icon(Icons.qr_code),
                          const SizedBox(width: 8), // 增加图标之间的间距
                          const Icon(Icons.arrow_forward_ios),
                          const SizedBox(
                            width: 25,
                          ), //与下部分的箭头
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  // Menu Items
                  Flexible(
                    fit: FlexFit.loose,
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: 6,
                      separatorBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(left: 56.0, right: 16.0),
                        child: Divider(
                          color: Colors.grey[300],
                          thickness: 1,
                          height: 0,
                        ),
                      ),
                      itemBuilder: (context, index) {
                        final tiles = [
                          ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.green,
                              child: Icon(
                                Icons.room_service,
                                color: Colors.white,
                              ),
                            ),
                            title: const Text('服务'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              GoRouter.of(context)
                                  .pushNamed("unimplementedPage");
                            },
                          ),
                          ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFFFFC125),
                              child: Icon(
                                Icons.bookmark,
                                color: Colors.white,
                              ),
                            ),
                            title: const Text('收藏'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              GoRouter.of(context)
                                  .pushNamed("unimplementedPage");
                            },
                          ),
                          ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Icon(
                                Icons.image,
                                color: Colors.white,
                              ),
                            ),
                            title: const Text('朋友圈'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              GoRouter.of(context)
                                  .pushNamed("unimplementedPage");
                            },
                          ),
                          ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.orange,
                              child: Icon(Icons.videocam, color: Colors.white),
                            ),
                            title: const Text('视频号'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              GoRouter.of(context)
                                  .pushNamed("unimplementedPage");
                            },
                          ),
                          ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Icon(
                                Icons.account_balance_wallet,
                                color: Colors.white,
                              ),
                            ),
                            title: const Text('卡包'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              GoRouter.of(context)
                                  .pushNamed("unimplementedPage");
                            },
                          ),
                          ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFFFFC125),
                              child: Icon(
                                Icons.emoji_emotions,
                                color: Colors.white,
                              ),
                            ),
                            title: const Text('表情'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              GoRouter.of(context)
                                  .pushNamed("unimplementedPage");
                            },
                          ),
                        ];
                        return tiles[index];
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Icon(
                        Icons.settings,
                        color: Colors.white,
                      ),
                    ),
                    title: const Text('设置'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      GoRouter.of(context).pushNamed("settings");
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Icon(
                        Icons.settings,
                        color: Colors.white,
                      ),
                    ),
                    title: const Text('测试页面'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      GoRouter.of(context).pushNamed("testPage");
                    },
                  ),
                ],
              )),
        );
      },
    );
  }
}
