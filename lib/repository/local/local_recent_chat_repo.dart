import 'package:hive/hive.dart';
import 'package:let_us_chat/repository/models/recent_chat.dart';

class LocalRecentChatRepo {
  final Box<RecentChat> box;

  LocalRecentChatRepo({required this.box});

  Future<void> saveRecentChat(RecentChat recentChat) async {
    await box.put(recentChat.chatId, recentChat);
  }

  RecentChat? getRecentChat(String chatId) {
    return box.get(chatId);
  }

  List<RecentChat> getAllRecentChats() {
    //将新的信息排到前面
    return box.values.toList()
      ..sort((a, b) => b.lastChatTime.compareTo(a.lastChatTime));
  }

  Future<void> updateRecentChat(RecentChat updatedChat) async {
    if (box.containsKey(updatedChat.chatId)) {
      await box.put(updatedChat.chatId, updatedChat);
    }
  }

  Future<void> deleteRecentChat(String chatId) async {
    await box.delete(chatId);
  }

  Future<void> clearAllRecentChats() async {
    await box.clear();
  }
}
