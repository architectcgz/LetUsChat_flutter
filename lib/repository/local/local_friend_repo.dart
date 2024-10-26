import 'package:hive/hive.dart';

import '../models/friend.dart';



class LocalFriendRepo {
  final Box<Friend> box;

  LocalFriendRepo({required this.box});

  // 插入单个好友
  Future<void> insertFriend(Friend friend) async {
    await box.put(friend.userId, friend);
  }

  // 更新单个好友
  Future<void> updateFriend(Friend friend) async {
    if (box.containsKey(friend.userId)) {
      await box.delete(friend.userId);
      await box.put(friend.userId, friend);
    } else {
      throw Exception("Friend with userId ${friend.userId} not found");
    }
  }

  // 删除单个好友
  Future<void> deleteFriend(String friendUid) async {
    if (box.containsKey(friendUid)) {
      await box.delete(friendUid);
    } else {
      throw Exception("Friend with Id $friendUid not found");
    }
  }

  // 获取单个好友信息
  Friend? getFriend(String userId) {
    return box.get(userId);
  }

  // 获取所有好友信息
  List<Friend> getAllFriendsList() {
    return box.values.toList();
  }

  // 保存 List<Friend>
  Future<void> saveFriends(List<Friend> friends) async {
    await box.clear();
    final Map<String, Friend> friendMap = {
      for (var friend in friends) friend.userId: friend
    };
    await box.putAll(friendMap);
  }

  Future<void> clearFriendInfo()async{
    await box.clear();
  }
}