import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:let_us_chat/blocs/chat_list/chat_list_bloc.dart';
import 'package:let_us_chat/blocs/contact_list/contact_list_bloc.dart';
import 'package:let_us_chat/core/services/friend_service.dart';
import 'package:let_us_chat/core/utils/injection_container.dart';
import 'package:let_us_chat/repository/local/local_friend_repo.dart';

import '../../core/errors/exception.dart';
import '../../repository/models/friend.dart';

part 'friend_info_event.dart';
part 'friend_info_state.dart';

class FriendInfoBloc extends Bloc<FriendInfoEvent, FriendInfoState> {
  final friendService = serviceLocator.get<FriendService>();
  late Friend? friend;
  FriendInfoBloc() : super(FriendInfoInitial()) {
    on<LoadFriendInfoEvent>((event, emit) async {
      emit(FriendInfoLoading());

      final LocalFriendRepo localFriendRepo =
          serviceLocator.get<LocalFriendRepo>();
      friend = localFriendRepo.getFriend(event.friendId);
      //本地找不到好友信息的情况(已把好友删除)
      if (friend == null) {
        friend = await friendService.getFriendInfo(event.friendId);
        if (friend != null) {
          emit(LoadDeletedFriendInfoSucceed(friend: friend!));
        } else {
          emit(const LoadFriendInfoFailed(message: "未找到好友信息"));
        }
      } else {
        try {
          DateTime updateTimeRemote =
              await friendService.getUpdateTime(event.friendId);
          print("远程用户更新时间: $updateTimeRemote");
          print("本地用户更新时间: ${friend!.updateTime}");
          print("与本地对比: ${updateTimeRemote == friend!.updateTime}");
          if (updateTimeRemote != friend!.updateTime) {
            friend = await friendService.getFriendInfo(event.friendId);
            if (friend != null) {
              print("远程更新的用户信息: ${friend.toString()}");
              await localFriendRepo.updateFriend(friend!);
              emit(LoadFriendInfoSucceed(friend: friend!));
            }
          } else {
            emit(LoadFriendInfoSucceed(friend: friend!));
          }
        } catch (e) {
          friend = localFriendRepo.getFriend(event.friendId);
          if (friend == null) {
            emit(const LoadFriendInfoFailed(message: "未找到好友信息"));
          } else {
            emit(LoadFriendInfoSucceed(friend: friend!));
          }
        }
      }
    });
    on<UpdateFriendAliasEvent>((event, emit) async {
      final localFriendRepo = serviceLocator.get<LocalFriendRepo>();
      print("${event.friendUid},${event.newAlias}");
      try {
        final result = await friendService.updateFriendAlias(
            event.friendUid, event.newAlias);
        if (result) {
          print("更新成功");
          var friend = localFriendRepo.getFriend(event.friendUid);
          friend!.alias = event.newAlias;
          await localFriendRepo.updateFriend(friend);
          serviceLocator.get<ContactListBloc>().add(LoadContactListEvent());
          serviceLocator.get<RecentChatListBloc>().add(LoadChatListEvent());
          emit(AliasUpdated(newAlias: event.newAlias));
        } else {
          emit(const UpdateAliasFailed(message: ""));
        }
      } on CustomException catch (e) {
        emit(UpdateAliasFailed(message: e.message));
      } on Exception catch (e) {
        print(e);
        emit(UpdateAliasFailed(message: e.toString()));
      }
    });
  }
}
