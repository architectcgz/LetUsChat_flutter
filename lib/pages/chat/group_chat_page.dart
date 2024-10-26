import 'package:flutter/cupertino.dart';
import 'package:let_us_chat/pages/unimplemented_page.dart';

class GroupChatPage extends StatefulWidget {
  final String groupUid;
  const GroupChatPage({super.key, required this.groupUid});
  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  @override
  Widget build(BuildContext context) {
    return const UnImplementedPage();
  }
}
