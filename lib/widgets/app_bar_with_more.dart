import 'package:flutter/material.dart';

class AppBarWithMore extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onPressed;
  final String? title;
  final bool centerTitle; // 控制标题居中

  const AppBarWithMore({super.key, this.onPressed, this.title, this.centerTitle = false});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title == null
          ? null
          : Text(
        title!,
        style: const TextStyle(
          fontSize: 18,
        ),
      ),
      centerTitle: centerTitle, // 控制标题是否居中
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_horiz),
          onPressed: onPressed,
          color: Colors.black,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
