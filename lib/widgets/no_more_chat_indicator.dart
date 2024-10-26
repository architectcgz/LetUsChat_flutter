import 'package:flutter/material.dart';

class NoMoreChatIndicator extends StatelessWidget {
  const NoMoreChatIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.0,
      width: double.infinity,
      alignment: Alignment.center,
      // 不显示提示文本
      child: buildIndicatorTitle(context),
    );
  }

  Widget buildIndicatorTitle(BuildContext context) {
    return const Text(
      "没有更多消息",
      textAlign: TextAlign.left,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: true,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
        color: Colors.grey,
        decoration: TextDecoration.none,
      ),
    );
  }
}
