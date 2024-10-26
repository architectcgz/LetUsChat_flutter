import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:let_us_chat/blocs/global_user/global_user_bloc.dart';
import '../../core/utils/injection_container.dart';
import '../../models/user.dart';
import '../../widgets/app_bar_with_title_arrow.dart';

class UserDetailPage extends StatefulWidget {
  const UserDetailPage({super.key});
  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  late final GlobalUserBloc globalUserBloc;
  late User? globalUser;
  @override
  void initState() {
    globalUserBloc = serviceLocator.get<GlobalUserBloc>();
    globalUser = globalUserBloc.globalUser;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GlobalUserBloc, GlobalUserState>(
      listener: (context, state) {
        // 处理状态变化
      },
      builder: (context, state) {
        return Scaffold(
          appBar: const AppBarWithTitleAndArrow(title: "个人信息"),
          body: ListView(
            children: [
              ListTile(
                title: const Text("头像"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                        globalUser!.avatar,
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () {
                  GoRouter.of(context).pushNamed('avatarDetail');
                },
              ),
              ListTile(
                title: const Text("名字"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      globalUser!.username,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () {
                  GoRouter.of(context).pushNamed("setUsername");
                },
              ),
              ListTile(
                title: const Text("拍一拍"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // 拍一拍点击事件处理
                  print("拍一拍点击");
                },
              ),
              ListTile(
                title: const Text("UID"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      globalUser!.userId,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.chevron_right)
                  ],
                ),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: globalUser!.userId));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('UID 已复制'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text("二维码名片"),
                trailing: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.qr_code),
                    Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () {
                  GoRouter.of(context).pushNamed("qrCode");
                },
              ),
              ListTile(
                title: const Text("更多信息"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // 更多信息点击事件处理
                  GoRouter.of(context).pushNamed("userMoreInfo");
                },
              ),
              ListTile(
                title: const Text("来电铃声"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // 来电铃声点击事件处理
                  print("来电铃声点击");
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
