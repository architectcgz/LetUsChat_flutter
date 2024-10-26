import 'package:hive/hive.dart';

import '../models/private_message.dart';

class LocalPrivateMessageRepo {
  final Box<PrivateMessage> box;

  LocalPrivateMessageRepo({required this.box});

  Future<void> saveMessage(PrivateMessage message) async {
    await box.put(message.messageId, message);
  }

  PrivateMessage? getMessageById(int messageId) {
    return box.get(messageId);
  }

  List<PrivateMessage> getMessagesByFriendId(String friendId, {required int limit, DateTime? lastMessageTime}) {
    // 获取所有该好友的消息，按发送时间倒序排列
    final messages = box.values
        .where((message) => message.friendId == friendId)
        .where((message) => lastMessageTime == null || message.sendTime.isBefore(lastMessageTime))
        .toList()..sort((a, b) => b.sendTime.compareTo(a.sendTime)); // 按时间倒序排列（最新的在前）
    // 获取分页消息，默认获取最新的 limit 条消息
    return messages.take(limit).toList();
  }


  List<PrivateMessage> getAllMessages() {
    return box.values.toList();
  }

  Future<void> updateLocalImagePath(int messageId,String imagePath)async{
    var message = box.get(messageId);
    if(message!=null){
      message.localMediaPath = imagePath;
      await message.save();
    }

  }

  Future<void> deleteMessage(int messageId) async {
    await box.delete(messageId);
  }

  Future<void> deleteMessagesByFriendId(String friendId) async {
    final messagesToDelete = box.values.where((message) => message.friendId == friendId).toList();
    for (var message in messagesToDelete) {
      await box.delete(message.messageId);
    }
  }

  Future<void> deleteAllMessages() async {
    await box.clear();
  }

  Future<void> recallMessage(int messageId) async {
    final message = box.get(messageId);
    if (message != null) {
      message.status = 3;
      await message.save();
    }
  }
}
