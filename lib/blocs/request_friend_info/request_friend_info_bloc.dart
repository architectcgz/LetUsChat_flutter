import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:let_us_chat/blocs/contact_list/contact_list_bloc.dart';
import 'package:let_us_chat/blocs/friend_request_list/friend_request_list_bloc.dart';
import 'package:let_us_chat/core/services/friend_service.dart';
import 'package:let_us_chat/core/utils/injection_container.dart';
import 'package:let_us_chat/core/websocket/websocket_service.dart';
import 'package:let_us_chat/repository/local/local_friend_request_repo.dart';

import '../../repository/models/request_friend_info.dart';

part 'request_friend_info_event.dart';
part 'request_friend_info_state.dart';

class RequestFriendInfoBloc
    extends Bloc<RequestFriendInfoEvent, RequestFriendInfoState> {
  final friendService = serviceLocator.get<FriendService>();
  final localFriendRequestRepo = serviceLocator.get<LocalFriendRequestRepo>();
  final friendRequestListBloc = serviceLocator.get<FriendRequestListBloc>();
  final webSocketService = serviceLocator.get<WebSocketService>();
  final contactListBloc = serviceLocator.get<ContactListBloc>();
  RequestFriendInfoBloc() : super(RequestFriendInfoInitial()) {
    on<GetRequestFriendInfoEvent>((event, emit) async {
      emit(GettingRequestUserInfo());
      final result = await localFriendRequestRepo
          .getRequestInfoByFriendUid(event.requestUserId);
      if (result != null) {
        emit(GetRequestUserInfoSucceed(requestFriendInfo: result));
      } else {
        emit(GetRequestUserInfoFailed(message: "查找不到这条请求的好友信息"));
      }
    });
  }
}
