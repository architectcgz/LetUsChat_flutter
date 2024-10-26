import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:let_us_chat/blocs/chat_list/chat_list_bloc.dart';
import 'package:let_us_chat/blocs/friend_request_list/friend_request_list_bloc.dart';
import 'package:let_us_chat/blocs/global_user/global_user_bloc.dart';
import 'package:let_us_chat/blocs/navbar_bloc/navbar_bloc.dart';
import 'package:let_us_chat/core/constants/constants.dart';
import 'package:let_us_chat/core/errors/exception.dart';
import 'package:let_us_chat/core/services/friend_service.dart';
import 'package:let_us_chat/core/utils/injection_container.dart';
import 'package:let_us_chat/core/websocket/websocket_service.dart';
import 'package:let_us_chat/repository/local/local_friend_repo.dart';
import 'package:let_us_chat/repository/local/local_private_message_repo.dart';
import 'package:let_us_chat/repository/local/local_recent_chat_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../repository/local/local_friend_request_repo.dart';
import '../../repository/models/friend.dart';
import '../../repository/models/request_friend_info.dart';

part 'contact_list_event.dart';
part 'contact_list_state.dart';

class ContactListBloc extends Bloc<ContactListEvent, ContactListState> {
  final friendService = serviceLocator.get<FriendService>();
  final globalUserBloc = serviceLocator.get<GlobalUserBloc>();
  final navbarBloc = serviceLocator.get<NavbarBloc>();
  late List<Friend> contactList;
  late Set<String> contactUidSet;
  late int newFriendCount;
  late int newGroupCount;
  ContactListBloc() : super(ContactListInitial()) {
    contactList = [];
    contactUidSet = {};
    newFriendCount = 0;
    on<LoadContactListEvent>((event, emit) async {
      //先从本地读取联系人列表信息
      print("获取联系人列表信息");
      try {
        contactList = serviceLocator.get<LocalFriendRepo>().getAllFriendsList();
        contactUidSet = contactList.map((e) => e.userId).toSet();
        SharedPreferences pref = await SharedPreferences.getInstance();
        newFriendCount = pref.getInt(newFriendCountKey) ?? 0;
        newGroupCount = pref.getInt(newGroupCountKey) ?? 0;
        emit(LoadContactListSucceed(
            localFriendList: contactList,
            newFriendCount: newFriendCount,
            newGroupCount: newGroupCount));
      } on CustomException catch (e) {
        emit(GetContactListFailed(message: e.message));
      }
    });
    on<DeleteFriendEvent>((event, emit) async {
      try {
        await friendService.deleteFriend(event.friendUid);
        contactUidSet.remove(event.friendUid);
        contactList.removeWhere((e) => e.userId == event.friendUid);
        await serviceLocator
            .get<LocalFriendRepo>()
            .deleteFriend(event.friendUid);
        await serviceLocator
            .get<LocalPrivateMessageRepo>()
            .deleteMessagesByFriendId(event.friendUid);
        serviceLocator
            .get<RecentChatListBloc>()
            .add(ClearRecentChatHistoryEvent(chatId: event.friendUid));
        await serviceLocator
            .get<LocalRecentChatRepo>()
            .deleteRecentChat(event.friendUid);
        emit(DeleteFriendSucceed());
      } on CustomException catch (e) {
        emit(DeleteFriendFailed(message: e.message));
      }
    });

    on<AddFriendEvent>(_onAddFriend);
    on<ReceiveFriendRequestEvent>((event, emit) async {
      final requestFriendInfo = event.requestFriendInfo;
      print(requestFriendInfo.toString());
      serviceLocator
          .get<FriendRequestListBloc>()
          .recentRequests
          .add(requestFriendInfo);
      newFriendCount += 1;
      await serviceLocator
          .get<LocalFriendRequestRepo>()
          .addRequest(requestFriendInfo);
      var badgeList = navbarBloc.badgeList;
      badgeList[1] = true;
      navbarBloc.add(UpdateBadgeEvent(badgeList: badgeList));
      emit(NewFriendRequested());
    });
  }

  FutureOr<void> _onAddFriend(event, emit) async {
    final localFriendRequestRepo = serviceLocator.get<LocalFriendRequestRepo>();
    final localFriendRepo = serviceLocator.get<LocalFriendRepo>();
    emit(AddingFriend());
    try {
      final result =
          await friendService.acceptFriendRequest(event.friendUid, event.alias);
      if (result) {
        RequestFriendInfo? friendInfo = await localFriendRequestRepo
            .getRequestInfoByFriendUid(event.friendUid);
        Friend? friend = await friendService.getFriendInfo(event.friendUid);
        if (friend != null) {
          friendInfo!.status = 1;
          friend.alias = event.alias;
          contactList.add(friend);
          contactUidSet.add(friend.userId);
          await localFriendRepo.insertFriend(friend);
          await localFriendRequestRepo.updateRequestInfoByFriendUid(
              event.friendUid, friendInfo);
          serviceLocator.get<WebSocketService>().sendAcceptFriendRequest(
              event.friendUid, globalUserBloc.globalUser!.userId);
          emit(AddFriendSucceed());
        } else {
          emit(const AddFriendFailed(message: "获取要添加的好友信息失败"));
        }
      } else {
        emit(const AddFriendFailed(message: "添加好友失败"));
      }
    } on CustomException catch (e) {
      emit(AddFriendFailed(message: e.message));
    } on Exception catch (e) {
      print(e);
      emit(const AddFriendFailed(message: "未知错误"));
    }
  }
}
