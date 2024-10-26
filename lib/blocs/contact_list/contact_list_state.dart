part of 'contact_list_bloc.dart';

sealed class ContactListState extends Equatable {
  const ContactListState();
}

final class ContactListInitial extends ContactListState {
  @override
  List<Object> get props => [];
}

final class GettingContactList extends ContactListState{
  @override
  List<Object?> get props => [];
}

final class LoadContactListSucceed extends ContactListState{
  final List<Friend> localFriendList;
  final int newFriendCount;
  final int newGroupCount;
  const LoadContactListSucceed({required this.localFriendList,required this.newFriendCount,required this.newGroupCount});
  @override
  List<Object?> get props => [localFriendList];
}

final class GetContactListFailed extends ContactListState{
  final String message;
  const GetContactListFailed({required this.message});
  @override
  List<Object?> get props => [message];
}

final class DeletingFriend extends ContactListState{
  @override
  List<Object?> get props => [];
}

final class DeleteFriendSucceed extends ContactListState{
  @override
  List<Object?> get props => [];
}

final class DeleteFriendFailed extends ContactListState{
  final String message;
  const DeleteFriendFailed({required this.message});
  @override
  List<Object?> get props => [message];
}

final class AddingFriend extends ContactListState{
  @override
  List<Object?> get props => [];
}

final class AddFriendSucceed extends ContactListState{
  @override
  List<Object?> get props => [];
}

final class AddFriendFailed extends ContactListState{
  final String message;
  const AddFriendFailed({required this.message});
  @override
  List<Object?> get props => [message];
}

final class NewFriendRequested extends ContactListState{
  @override
  List<Object?> get props => [];
}

