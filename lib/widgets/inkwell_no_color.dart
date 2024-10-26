import 'package:flutter/material.dart';

class InkWellNoColor extends InkWell {
  const InkWellNoColor({
    Key? key,
    required Widget child,
    GestureTapCallback? onTap,
    GestureLongPressCallback? onLongPress,
    BorderRadius? borderRadius,
    Color? splashColor,
    Color? highlightColor,
    Color? hoverColor,
    Color? focusColor,
  }) : super(
    key: key,
    onTap: onTap,
    onLongPress: onLongPress,
    borderRadius: borderRadius,
    splashColor: splashColor ?? Colors.transparent, // 隐藏水波效果
    highlightColor: highlightColor ?? Colors.transparent,// 隐藏点击高亮效果
    hoverColor: hoverColor ?? Colors.transparent,// 禁用hover效果
    focusColor: focusColor ?? Colors.transparent,// 禁用focus效果
    child: child,
  );
}