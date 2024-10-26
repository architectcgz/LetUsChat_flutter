part of 'friend_info_bloc.dart';

sealed class FriendInfoEvent extends Equatable {
  const FriendInfoEvent();
}

final class LoadFriendInfoEvent extends FriendInfoEvent {
  final String friendId;
  const LoadFriendInfoEvent({required this.friendId});
  @override
  List<Object?> get props => [friendId];
}

final class UpdateFriendAliasEvent extends FriendInfoEvent {
  final String friendUid;
  final String newAlias;
  const UpdateFriendAliasEvent(
      {required this.friendUid, required this.newAlias});
  @override
  List<Object?> get props => [friendUid, newAlias];
}
