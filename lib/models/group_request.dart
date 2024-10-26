class GroupRequest {
  String groupId;
  String requestUserId;
  DateTime requestTime;
  GroupRequest({required this.groupId, required this.requestUserId})
      : requestTime = DateTime.timestamp();
}
