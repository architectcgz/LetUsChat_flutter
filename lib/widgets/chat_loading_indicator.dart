import 'package:flutter/cupertino.dart';

class ChatLoadingIndicator extends StatelessWidget {
  const ChatLoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.0,
      width: double.infinity,
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CupertinoActivityIndicator(
            color: Color(0xFF333333),
          ),
          const SizedBox(
            width: 10,
          ),
          buildIndicatorTitle(context),
        ],
      ),
    );
  }

  Widget buildIndicatorTitle(BuildContext context) {
    return const Text(
      "加载中",
      textAlign: TextAlign.left,
      maxLines: 1000,
      overflow: TextOverflow.ellipsis,
      softWrap: true,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
        color: Color(0xFF555555),
        decoration: TextDecoration.none,
      ),
    );
  }
}
