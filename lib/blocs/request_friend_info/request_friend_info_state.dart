part of 'request_friend_info_bloc.dart';

@immutable
sealed class RequestFriendInfoState {}

final class RequestFriendInfoInitial extends RequestFriendInfoState {}
final class GettingRequestUserInfo extends RequestFriendInfoState{}

final class GetRequestUserInfoSucceed extends RequestFriendInfoState{
  final RequestFriendInfo requestFriendInfo;
  GetRequestUserInfoSucceed({required this.requestFriendInfo});
}
final class GetRequestUserInfoFailed extends RequestFriendInfoState{
  final String message;
  GetRequestUserInfoFailed({required this.message});
}


