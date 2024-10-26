import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:let_us_chat/blocs/global_user/global_user_bloc.dart';

import '../../core/utils/injection_container.dart';
import '../../models/user.dart';

class UserMoreInfoPage extends StatefulWidget {
  const UserMoreInfoPage({super.key});

  @override
  State<UserMoreInfoPage> createState() => _UserMoreInfoPageState();
}

class _UserMoreInfoPageState extends State<UserMoreInfoPage> {
  late final GlobalUserBloc globalUserBloc;
  late final User? globalUser;
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
        if (state is UpdateUserInfoFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is UpdateUserInfoSucceed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("用户信息更新成功"),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("更多信息"),
          ),
          body: ListView(
            children: [
              ListTile(
                title: const Text("性别"),
                trailing: Text((globalUser!.gender) == null
                    ? "未设置"
                    : (globalUser!.gender!) == 0
                        ? "女"
                        : "男"),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext _) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            title: const Text('男'),
                            onTap: () {
                              if (context.mounted) {
                                if (globalUser!.gender != 1) {
                                  globalUserBloc
                                      .add(UpdateGenderEvent(newGender: 1));
                                }
                                //手动关闭showModelSheet
                                Navigator.pop(context);
                                setState(() {});
                              }
                            },
                          ),
                          ListTile(
                            title: const Text('女'),
                            onTap: () {
                              if (context.mounted) {
                                if (globalUser!.gender != 0) {
                                  globalUserBloc
                                      .add(UpdateGenderEvent(newGender: 0));
                                }
                                Navigator.pop(context);
                                setState(() {});
                              }
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const Divider(),
              ListTile(
                title: const Text("地区"),
                trailing: Text(globalUser!.location == null
                    ? "未设置"
                    : globalUser!.location!),
                onTap: () async {
                  String? val =
                      await GoRouter.of(context).pushNamed('locationSelection');
                  if (context.mounted) {
                    if (val != null && val != globalUser!.location) {
                      globalUserBloc.add(UpdateLocationEvent(newLocation: val));
                      setState(() {});
                    }
                  }
                },
              ),
              const Divider(),
              ListTile(
                title: const Text("个性签名"),
                trailing: Text(globalUser!.signature == null
                    ? "未设置"
                    : globalUser!.signature!),
                onTap: () {
                  GoRouter.of(context).pushNamed('signature');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
