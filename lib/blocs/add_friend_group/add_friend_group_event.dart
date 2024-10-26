part of 'add_friend_group_bloc.dart';

sealed class AddFriendGroupEvent {
  const AddFriendGroupEvent();
}

class SearchEvent extends AddFriendGroupEvent{
  final String query;
  const SearchEvent({required this.query});
}

final class RequestFriendEvent extends AddFriendGroupEvent{
  final FriendRequest friendRequest;
  RequestFriendEvent({required this.friendRequest});
}