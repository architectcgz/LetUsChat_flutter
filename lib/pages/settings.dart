import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:let_us_chat/blocs/authentication/authentication_bloc.dart';
import 'package:let_us_chat/widgets/app_bar_with_title_arrow.dart';
import '../blocs/setting/settings_bloc.dart';
import 'package:flutter/material.dart';

import '../core/utils/injection_container.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return Scaffold(
          appBar: const AppBarWithTitleAndArrow(
            title: "设置",
          ),
          body: ListView(
            children: [
              ListTile(
                title: const Text("账号与安全"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to the "账号与安全" screen
                },
              ),
              ListTile(
                title: const Text("青少年模式"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to the "青少年模式" screen
                },
              ),
              ListTile(
                title: const Text("关怀模式"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to the "关怀模式" screen
                },
              ),
              const Divider(),
              ListTile(
                title: const Text("新消息通知"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to the "新消息通知" screen
                },
              ),
              ListTile(
                title: const Text("聊天"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to the "聊天" screen
                },
              ),
              ListTile(
                title: const Text("通用"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to the "通用" screen
                },
              ),
              ListTile(
                title: const Text("切换主题"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  GoRouter.of(context).pushNamed("changeThemePage");
                },
              ),
              const Divider(),
              ListTile(
                title: const Text("朋友权限"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to the "朋友权限" screen
                },
              ),
              ListTile(
                title: const Text("个人信息与权限"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to the "个人信息与权限" screen
                },
              ),
              ListTile(
                title: const Text("个人信息收集清单"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to the "个人信息收集清单" screen
                },
              ),
              ListTile(
                title: const Text("第三方信息共享清单"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to the "第三方信息共享清单" screen
                },
              ),
              const Divider(),
              ListTile(
                title: const Text("插件"),
                trailing: const Text("微信输入法可以【问AI】了"),
                onTap: () {
                  // Navigate to the "插件" screen
                },
              ),
              ListTile(
                title: const Text("关于微信"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to the "关于微信" screen
                },
              ),
              ListTile(
                title: const Text("帮助与反馈"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to the "帮助与反馈" screen
                },
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                padding: const EdgeInsets.all(12.0),
                child: TextButton(
                  onPressed: () {
                    serviceLocator.get<AuthenticationBloc>().add(LoggedOut());
                    GoRouter.of(context).go("/auth");
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.all(14.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Center(
                    child: Text(
                      "退出登录",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      listener: (context, state) {},
    );
  }
}
