import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:let_us_chat/blocs/contact_list/contact_list_bloc.dart';
import 'package:let_us_chat/blocs/global_user/global_user_bloc.dart';
import 'package:let_us_chat/core/services/friend_service.dart';
import 'package:let_us_chat/core/utils/injection_container.dart';
import 'package:let_us_chat/core/websocket/websocket_service.dart';
import 'package:let_us_chat/repository/local/local_friend_request_repo.dart';

import '../../repository/models/request_friend_info.dart';

part 'friend_request_list_event.dart';
part 'friend_request_list_state.dart';

class FriendRequestListBloc
    extends Bloc<FriendRequestListEvent, FriendRequestListState> {
  final friendService = serviceLocator.get<FriendService>();
  final webSocketService = serviceLocator.get<WebSocketService>();
  final GlobalUserBloc globalUserBloc = serviceLocator.get<GlobalUserBloc>();
  final ContactListBloc contactListBloc = serviceLocator.get<ContactListBloc>();
  List<RequestFriendInfo> recentRequests = [];
  List<RequestFriendInfo> olderRequests = [];

  FriendRequestListBloc() : super(FriendRequestListInitial()) {
    on<GetFriendRequestListEvent>(_onGetFriendRequestList);
  }

  Future<void> _onGetFriendRequestList(GetFriendRequestListEvent event,
      Emitter<FriendRequestListState> emit) async {
    emit(FriendRequestListLoading());
    try {
      print("获取本地存储");
      // 使用本地存储获取请求列表
      List<RequestFriendInfo>? requestList = await serviceLocator
          .get<LocalFriendRequestRepo>()
          .getLocalRequestListData();

      if (requestList != null && requestList.isNotEmpty) {
        DateTime now = DateTime.now();

        recentRequests.clear();
        olderRequests.clear();

        for (var request in requestList) {
          Duration difference = now.difference(request.updateTime);
          if (difference.inDays <= 3) {
            recentRequests.add(request);
          } else {
            olderRequests.add(request);
          }
        }

        // 按更新时间降序排列
        recentRequests.sort((a, b) => b.updateTime.compareTo(a.updateTime));
        olderRequests.sort((a, b) => b.updateTime.compareTo(a.updateTime));
        emit(GetFriendRequestListSucceed(
            recentRequests: recentRequests, olderRequests: olderRequests));
      } else {
        print("请求列表为空");
        emit(FriendRequestListEmpty());
      }
    } catch (e) {
      emit(GetFriendRequestListFailed(message: e.toString()));
    }
  }
}
