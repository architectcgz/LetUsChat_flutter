import 'package:flutter/material.dart';

class AppBarWithTitleAndArrow extends StatefulWidget
    implements PreferredSizeWidget {
  final String? title;
  final bool? centerTitle;
  final Color? appbarColor;
  const AppBarWithTitleAndArrow(
      {super.key, this.title, this.centerTitle, this.appbarColor});

  @override
  State<AppBarWithTitleAndArrow> createState() =>
      _AppBarWithTitleAndArrowState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppBarWithTitleAndArrowState extends State<AppBarWithTitleAndArrow> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: widget.appbarColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      centerTitle: widget.centerTitle ?? false,
      title: widget.title == null
          ? null
          : Text(
              widget.title!,
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
    );
  }
}
