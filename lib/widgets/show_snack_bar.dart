import 'package:flutter/material.dart';

void showFloatSnackBar(
    {required BuildContext context,
    required String content,
    int duration = 2,
    required double bottomMargin}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      margin: EdgeInsets.only(bottom: bottomMargin),
      content: Text(content),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
