part of 'friend_info_bloc.dart';

sealed class FriendInfoState extends Equatable {
  const FriendInfoState();
}

final class FriendInfoInitial extends FriendInfoState {
  @override
  List<Object> get props => [];
}

final class FriendInfoLoading extends FriendInfoState{
  @override
  List<Object?> get props => [];
}

final class LoadFriendInfoSucceed extends FriendInfoState{
  final Friend friend;
  const LoadFriendInfoSucceed({required this.friend});
  @override
  List<Object?> get props => [friend];
}

final class LoadDeletedFriendInfoSucceed extends FriendInfoState{
  final Friend friend;
  const LoadDeletedFriendInfoSucceed({required this.friend});
  @override
  List<Object?> get props => [friend];
}

final class LoadFriendInfoFailed extends FriendInfoState{
  final String message;
  const LoadFriendInfoFailed({required this.message});
  @override
  List<Object?> get props => [message];
}

final class AliasExceedLength extends FriendInfoState{
  @override
  List<Object?> get props => [];
}

final class AliasUpdated extends FriendInfoState{
  final String newAlias;
  const AliasUpdated({required this.newAlias});
  @override
  List<Object?> get props => [newAlias];
}

final class UpdateAliasFailed extends FriendInfoState{
  final String message;
  const UpdateAliasFailed({required this.message});
  @override
  List<Object?> get props => [];
}