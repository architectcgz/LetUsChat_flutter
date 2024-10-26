import 'package:flutter/material.dart';

class ClickableTextWithIcon extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;

  const ClickableTextWithIcon({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent, // 背景颜色透明
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0), // 设置水波纹的圆角
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 14.0, vertical: 6.0), // 设置背景框的大小
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon),
              const SizedBox(width: 8.0), // 设定图标和文本之间的间距
              Text(
                text,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
