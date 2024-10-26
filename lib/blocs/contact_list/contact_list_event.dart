part of 'contact_list_bloc.dart';

sealed class ContactListEvent {
  const ContactListEvent();
}

final class LoadContactListEvent extends ContactListEvent{

}

final class AddFriendEvent extends ContactListEvent{
  final String friendUid;
  final String? alias;
  AddFriendEvent({required this.friendUid,this.alias});
}


final class DeleteFriendEvent extends ContactListEvent{
  final String friendUid;
  DeleteFriendEvent({required this.friendUid});
}

final class UpdateFriendInfoEvent extends ContactListEvent{}

final class ReceiveFriendRequestEvent extends ContactListEvent{
  final RequestFriendInfo requestFriendInfo;
  ReceiveFriendRequestEvent({required this.requestFriendInfo});
}

final class AcceptRequestEvent extends ContactListEvent{
  final String friendUid;
  final String? alias;
  AcceptRequestEvent({required this.friendUid,required this.alias});
}