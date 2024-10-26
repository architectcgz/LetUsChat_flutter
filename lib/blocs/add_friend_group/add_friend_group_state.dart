part of 'add_friend_group_bloc.dart';

sealed class AddFriendGroupState{
  const AddFriendGroupState();
}

final class AddFriendGroupInitial extends AddFriendGroupState {

}
final class Searching extends AddFriendGroupState{}

final class SearchSucceed extends AddFriendGroupState{
  List<Group>? groupResult;
  List<Friend>? friendResult;
  SearchSucceed({required this.groupResult,required this.friendResult});
}

final class SearchFailed extends AddFriendGroupState{
  final String message;
  const SearchFailed({required this.message});
}

final class NoSearchResult extends AddFriendGroupState{

}

final class RequestFriendSucceed extends AddFriendGroupState{}

final class RequestFriendFailed extends AddFriendGroupState{
  final String message;
  RequestFriendFailed({required this.message});
}