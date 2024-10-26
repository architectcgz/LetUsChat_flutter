import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:let_us_chat/widgets/app_bar_with_more.dart';
import 'package:let_us_chat/widgets/qr_code_profile.dart';

import '../../blocs/global_user/global_user_bloc.dart';
import '../../blocs/qr_code_bloc/qr_code_bloc.dart';
import '../../core/utils/injection_container.dart';

class QrCodePage extends StatelessWidget {
  final globalUserBloc = serviceLocator.get<GlobalUserBloc>();

  QrCodePage({super.key});
  @override
  Widget build(BuildContext context) {
    final globalUser = globalUserBloc.globalUser;
    return BlocConsumer<QrCodeBloc, QrCodeState>(
      listener: (context, state) {
        if (state is QrCodeError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
            appBar: const AppBarWithMore(),
            body: Column(
              children: [
                const SizedBox(height: 40),
                UserProfile(
                    avatarUrl: globalUser!.avatar,
                    username: globalUser.username,
                    location: globalUser.location,
                    qrCodeUrl: globalUser.qrCode),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Handle scan
                        },
                        child: const Text(
                          '扫一扫',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const Text(
                        '   |   ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Handle change style
                        },
                        child: const Text(
                          '换个样式',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      const Text(
                        '   |   ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Handle save image
                        },
                        child: const Text(
                          '保存图片',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ));
      },
    );
  }
}
