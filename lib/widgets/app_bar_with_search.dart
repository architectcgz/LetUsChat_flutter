import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppBarWithSearch extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  const AppBarWithSearch({super.key, required this.title});
  @override
  State<AppBarWithSearch> createState() => _AppBarWithSearchState();
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppBarWithSearchState extends State<AppBarWithSearch> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      title: Text(
        widget.title,
        style: const TextStyle(
          fontSize: 18,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // Implement search action
          },
        ),
        IconButton(
          icon: const Icon(
            Icons.add,
          ),
          onPressed: () {
            final screenWidth = MediaQuery.of(context).size.width;
            final maxWidth = (screenWidth / 2) - 20;
            int? selectedNum;
            showMenu(
              context: context,
              position: const RelativeRect.fromLTRB(50.0, 60.0, 10.0, 0.0),
              items: [
                PopupMenuItem(
                  value: 1,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: const Row(
                      children: [
                        Icon(Icons.person_add, size: 20),
                        SizedBox(width: 10),
                        Text('添加好友/群', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: const Row(
                      children: [
                        Icon(Icons.group, size: 20),
                        SizedBox(width: 10),
                        Text('发起群聊', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 3,
                  child: Container(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: const Row(
                      children: [
                        Icon(Icons.qr_code_scanner, size: 20),
                        SizedBox(width: 10),
                        Text('扫一扫', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                //不作为收款工具使用
                // PopupMenuItem(
                //   value: 4,
                //   child: Container(
                //     constraints: BoxConstraints(maxWidth: maxWidth),
                //     child: const Row(
                //       children: [
                //         Icon(Icons.payment, size: 20),
                //         SizedBox(width: 10),
                //         Text('收付款', style: TextStyle(fontSize: 16)),
                //       ],
                //     ),
                //   ),
                // ),
              ],
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ).then((value) {
              selectedNum = value;
            });
            switch (selectedNum) {
              case 1:
                print("点击了添加好友");
                if (mounted) {
                  GoRouter.of(context).pushNamed("addFriendGroup");
                }
                break;
              case 2:
                print("点击了发起群聊");
                break;
              case 3:
                print("点击了扫码");
                break;
            }
            //             if (selectedNum == 1) {
            //   print("点击了添加好友");
            //   if (mounted) {
            //     GoRouter.of(context).pushNamed("addFriendGroup");
            //   }
            // } else if (value == 2) {
            //   print("点击了发起群聊");
            // } else if (value == 3) {
            //   print("点击了扫码");
            // } else if (value == 4) {
            //   print("点击了付款");
            // }
          },
        )
      ],
    );
  }
}
