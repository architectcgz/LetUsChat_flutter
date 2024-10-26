part of 'request_friend_info_bloc.dart';

@immutable
sealed class RequestFriendInfoEvent {}

final class GetRequestFriendInfoEvent extends RequestFriendInfoEvent {
  final String requestUserId;
  GetRequestFriendInfoEvent({required this.requestUserId});
}

final class TryAcceptFriendEvent extends RequestFriendInfoEvent {
  final String friendUid;
  final String? alias;
  TryAcceptFriendEvent({required this.friendUid, required this.alias});
}
