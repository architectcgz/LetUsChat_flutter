import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:let_us_chat/blocs/chat_list/chat_list_bloc.dart';
import 'package:let_us_chat/core/utils/injection_container.dart';

class LogoutPopUp extends StatelessWidget {
  const LogoutPopUp({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('强制登出'),
      content: const Text('你已在其他处登录，如果不是本人的操作，请修改密码。'),
      actions: [
        TextButton(
          onPressed: () {
            GoRouter.of(context).pop(); // 关闭对话
            //清理bloc
            serviceLocator.get<RecentChatListBloc>().close();
            serviceLocator.unregister<RecentChatListBloc>();
            serviceLocator.registerLazySingleton<RecentChatListBloc>(
                () => RecentChatListBloc(),
                dispose: (bloc) => bloc.close());
            GoRouter.of(context).go("/auth");
          },
          child: const Text('确定'),
        ),
      ],
    );
  }
}
