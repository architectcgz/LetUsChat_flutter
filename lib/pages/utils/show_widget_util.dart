import 'package:flutter/material.dart';
import 'dart:async';

class ShowWidgetUtil {
  // 静态方法，便于在任何地方调用
  static void showToast(
    BuildContext context,
    String message, {
    int duration = 2,
    double? bottom, // 自定义距离底部的参数
    double? left, // 自定义距离左侧的参数
    double borderRadius = 8.0, // 自定义borderRadius
  }) {
    OverlayState overlayState = Overlay.of(context); // 获取Overlay的状态
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) {
        // 如果没有传入 bottom 和 left，则使用默认居中的位置
        double finalBottom =
            bottom ?? MediaQuery.of(context).size.height / 2 - 50;
        double finalLeft = left ?? MediaQuery.of(context).size.width / 2 - 50;

        return Positioned(
          bottom: finalBottom, // 使用finalBottom作为位置
          left: finalLeft, // 使用finalLeft作为位置
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius:
                    BorderRadius.circular(borderRadius), // 设置 borderRadius
              ),
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        );
      },
    );

    // 插入 OverlayEntry 到 Overlay
    overlayState.insert(overlayEntry);

    // 设置显示时长，之后自动移除
    Timer(Duration(seconds: duration), () {
      overlayEntry.remove();
    });
  }

  static void showSnackBar(BuildContext context, String message,
      {int? seconds}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: seconds ?? 3), // 设置提示显示的时间
        behavior: SnackBarBehavior.floating, // 设置为浮动类型
      ),
    );
  }

  static bool showAlertDialog(
      BuildContext context, String title, String content) {
    bool result = false;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                result = true;
              },
              child: const Text('确认'),
            ),
          ],
        );
      },
    );
    return result;
  }
}
