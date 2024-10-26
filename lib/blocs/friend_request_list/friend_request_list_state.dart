part of 'friend_request_list_bloc.dart';

@immutable
sealed class FriendRequestListState {}

final class FriendRequestListInitial extends FriendRequestListState {}

final class FriendRequestListLoading extends FriendRequestListState{}

final class GetFriendRequestListSucceed extends FriendRequestListState{
  final List<RequestFriendInfo> recentRequests;
  final List<RequestFriendInfo> olderRequests;
  GetFriendRequestListSucceed({required this.recentRequests,required this.olderRequests});
}

final class FriendRequestListEmpty extends FriendRequestListState{}

final class GetFriendRequestListFailed extends FriendRequestListState{
  final String message;
  GetFriendRequestListFailed({required this.message});
}


