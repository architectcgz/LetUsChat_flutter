import 'package:hive/hive.dart';
import 'package:let_us_chat/repository/local/local_group_message_repo.dart';
import 'package:let_us_chat/repository/local/local_group_repo.dart';
import 'package:let_us_chat/repository/local/local_private_message_repo.dart';
import 'package:let_us_chat/repository/local/local_recent_chat_repo.dart';

import '../../core/constants/constants.dart';
import '../../core/global.dart';
import '../../core/utils/injection_container.dart';
import '../models/friend.dart';
import '../models/group.dart';
import '../models/group_message.dart';
import '../models/private_message.dart';
import '../models/recent_chat.dart';
import '../models/request_friend_info.dart';
import 'local_friend_repo.dart';
import 'local_friend_request_repo.dart';

Future<void> setUpBoxAndRepo(String currentUserId) async {
  print("start openBox");
  if (!Hive.isBoxOpen("$friendsBoxKey$currentUserId")) {
    await Hive.openBox<Friend>("$friendsBoxKey$currentUserId");
  }
  if (!Hive.isBoxOpen("$groupsBoxKey$currentUserId")) {
    await Hive.openBox<Group>("$groupsBoxKey$currentUserId");
  }
  if (!Hive.isBoxOpen("$friendRequestBoxKey$currentUserId")) {
    await Hive.openBox<RequestFriendInfo>("$friendRequestBoxKey$currentUserId");
  }
  if (!Hive.isBoxOpen("$recentChatBoxKey$currentUserId")) {
    await Hive.openBox<RecentChat>("$recentChatBoxKey$currentUserId");
  }
  if (!Hive.isBoxOpen("$privateMessageBoxKey$currentUserId")) {
    await Hive.openBox<PrivateMessage>("$privateMessageBoxKey$currentUserId");
  }
  if (!Hive.isBoxOpen("$groupMessageBoxKey$currentUserId")) {
    await Hive.openBox<GroupMessage>("$groupMessageBoxKey$currentUserId");
  }

  print("openBox finished");

  if (!serviceLocator.isRegistered<LocalFriendRequestRepo>()) {
    serviceLocator.registerSingleton(LocalFriendRequestRepo(
        box:
            Hive.box<RequestFriendInfo>("$friendRequestBoxKey$currentUserId")));
  }
  if (!serviceLocator.isRegistered<LocalFriendRepo>()) {
    serviceLocator.registerSingleton(
        LocalFriendRepo(box: Hive.box<Friend>("$friendsBoxKey$currentUserId")));
  }
  if (!serviceLocator.isRegistered<LocalGroupRepo>()) {
    serviceLocator.registerSingleton(
        LocalGroupRepo(box: Hive.box<Group>("$groupsBoxKey$currentUserId")));
  }
  if (!serviceLocator.isRegistered<LocalRecentChatRepo>()) {
    serviceLocator.registerSingleton(LocalRecentChatRepo(
        box: Hive.box<RecentChat>("$recentChatBoxKey$currentUserId")));
  }
  if (!serviceLocator.isRegistered<LocalPrivateMessageRepo>()) {
    serviceLocator.registerSingleton<LocalPrivateMessageRepo>(
        LocalPrivateMessageRepo(
            box: Hive.box<PrivateMessage>("$privateMessageBoxKey$currentUserId")));
  }
  if (!serviceLocator.isRegistered<LocalGroupMessageRepo>()) {
    serviceLocator.registerSingleton(LocalGroupMessageRepo(
        box: Hive.box<GroupMessage>("$groupMessageBoxKey$currentUserId")));
  }
}

Future<void> unRegisterRepoBlocs() async {
  Hive.box<Friend>("$friendsBoxKey$currentUserId").close();
  Hive.box<Group>("$groupsBoxKey$currentUserId").close();
  Hive.box<RequestFriendInfo>("$friendRequestBoxKey$currentUserId").close();
  Hive.box<RecentChat>("$recentChatBoxKey$currentUserId").close();
  Hive.box<PrivateMessage>("$privateMessageBoxKey$currentUserId").close();
  Hive.box<GroupMessage>("$groupMessageBoxKey$currentUserId").close();
  serviceLocator.unregister<LocalFriendRequestRepo>();
  serviceLocator.unregister<LocalGroupRepo>();
  serviceLocator.unregister<LocalFriendRepo>();
  serviceLocator.unregister<LocalRecentChatRepo>();
  serviceLocator.unregister<LocalPrivateMessageRepo>();
  serviceLocator.unregister<LocalGroupMessageRepo>();
}
