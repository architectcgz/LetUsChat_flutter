// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RequestSendFilePopUp extends StatelessWidget {
  final String friendName;
  final String friendUid;
  final List<Map<String, String>> fileList;
  final int fileListHashCode;
  const RequestSendFilePopUp({
    Key? key,
    required this.friendName,
    required this.friendUid,
    required this.fileList, required this.fileListHashCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("好友向你发送了文件"),
      content: Text("你的好友$friendName向你发送了文件,请选择接收或忽略"),
      actions: [
        //拒绝
        TextButton(
          onPressed: () {
            GoRouter.of(context).pop(); // 关闭对话
          },
          child: const Text('取消'),
        ),
        //同意接收
        TextButton(
          onPressed: () {
            GoRouter.of(context).pop();//退出弹出框
            if(GoRouter.of(context).canPop()){
              GoRouter.of(context).pop();
            }
            GoRouter.of(context).pushNamed("receiveFile",
                extra: {"friendUid": friendUid, "fileList": fileList,"fileListHashCode": fileListHashCode}); // 关闭对话
          },
          child: const Text('点击查看'),
        ),
      ],
    );
  }
}
