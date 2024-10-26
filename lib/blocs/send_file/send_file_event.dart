part of 'send_file_bloc.dart';

@immutable
sealed class SendFileEvent {}

final class FriendAcceptFileReqEvent extends SendFileEvent{
  final String friendUid;
  final int fileListHashCode;

  FriendAcceptFileReqEvent({required this.friendUid, required this.fileListHashCode});
}
