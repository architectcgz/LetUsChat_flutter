class AcceptFriendReqMsg {
  final String acceptUserId;
  final String requestUserId;
  AcceptFriendReqMsg({required this.acceptUserId, required this.requestUserId});
  Map<String, dynamic> toJson() =>
      {"acceptUserId": acceptUserId, "requestUserId": requestUserId};
}
