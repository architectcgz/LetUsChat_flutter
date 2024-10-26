class FriendRequest {
  String requestUserId;
  String friendId;
  String? requestMessage;
  String? alias;
  DateTime requestTime;

  FriendRequest({
    required this.requestUserId,
    required this.friendId,
    required this.requestMessage,
    required this.alias
  }): requestTime = DateTime.timestamp();
}
