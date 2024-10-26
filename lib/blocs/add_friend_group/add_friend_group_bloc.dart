import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:let_us_chat/core/errors/exception.dart';
import 'package:let_us_chat/core/services/group_service.dart';
import 'package:let_us_chat/core/utils/injection_container.dart';
import '../../core/services/friend_service.dart';
import '../../models/friend_request.dart';

import '../../repository/models/friend.dart';
import '../../repository/models/group.dart';

part 'add_friend_group_event.dart';
part 'add_friend_group_state.dart';

class AddFriendGroupBloc
    extends Bloc<AddFriendGroupEvent, AddFriendGroupState> {
  final friendService = serviceLocator.get<FriendService>();
  final groupService = serviceLocator.get<GroupService>();
  AddFriendGroupBloc() : super(AddFriendGroupInitial()) {
    on<SearchEvent>((event, emit) async {
      emit(Searching());
      String query = event.query;
      //搜索长度大于5才允许搜索
      if (query.startsWith('U') && query.length > 5) {
        try {
          final result = await friendService.search(event.query);
          if (result != null) {
            emit(SearchSucceed(groupResult: null, friendResult: result));
          }
        } on CustomException catch (e) {
          emit(SearchFailed(message: e.message));
        }
      } else if (query.startsWith('G') && query.length > 5) {
        try {
          final result = await groupService.search(event.query);
          if (result != null) {
            emit(SearchSucceed(groupResult: result, friendResult: null));
          }
        } on CustomException catch (e) {
          emit(SearchFailed(message: e.message));
        }
      } else {
        emit(NoSearchResult());
      }
    });

    on<RequestFriendEvent>((event, emit) async {
      try {
        final friendRequest = event.friendRequest;
        // webSocketService.sendFriendRequest(
        //   friendRequest.requestUserId,
        //   friendRequest.friendId,
        //   friendRequest.requestMessage,
        // );
        await friendService.requestFriend(friendRequest);
        emit(RequestFriendSucceed());
      } on CustomException catch (e) {
        emit(RequestFriendFailed(message: e.message));
      }
    });
  }
}
