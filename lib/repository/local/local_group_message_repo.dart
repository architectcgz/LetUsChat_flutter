import 'package:hive/hive.dart';

import '../models/group_message.dart';


class LocalGroupMessageRepo {
  final Box<GroupMessage> box;

  LocalGroupMessageRepo({required this.box});

  Future<void> saveGroupMessage(GroupMessage message) async {
    await box.put(message.messageId, message);
  }

  GroupMessage? getGroupMessageById(int messageId) {
    return box.get(messageId);
  }

  List<GroupMessage> getGroupMessagesByGroupId(String groupId) {
    return box.values.where((message) => message.groupId == groupId).toList();
  }

  List<GroupMessage> getAllGroupMessages() {
    return box.values.toList();
  }

  Future<void> deleteGroupMessage(int messageId) async {
    await box.delete(messageId);
  }

  Future<void> deleteGroupMessagesByGroupId(String groupId) async {
    final messagesToDelete = box.values.where((message) => message.groupId == groupId).toList();
    for (var message in messagesToDelete) {
      await box.delete(message.messageId);
    }
  }

  Future<void> deleteAllGroupMessages() async {
    await box.clear();
  }

  Future<void> recallGroupMessage(int messageId) async {
    final message = box.get(messageId);
    if (message != null) {
      message.status = 3;
      await message.save();
    }
  }
}
