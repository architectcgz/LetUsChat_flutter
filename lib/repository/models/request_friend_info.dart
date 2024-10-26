import 'package:hive/hive.dart';
part 'request_friend_info.g.dart';

//flutter packages pub run build_runner build
@HiveType(typeId: 4)
class RequestFriendInfo {
  @HiveField(0)
  String friendUid;
  @HiveField(1)
  String nickname;
  @HiveField(2)
  String avatar;
  @HiveField(3)
  int? gender;
  @HiveField(4)
  String? location;
  @HiveField(5)
  String? requestMessage;
  @HiveField(6)
  int status;// 0: 未处理, -1 已过期 1:已同意
  @HiveField(7)
  DateTime createTime;
  @HiveField(8)
  DateTime updateTime;

  RequestFriendInfo({
    required this.friendUid,
    required this.nickname,
    required this.avatar,
    required this.gender,
    required this.location,
    required this.requestMessage,
    required this.createTime,
    required this.updateTime,
    required this.status,
  });

  factory RequestFriendInfo.fromJson(Map<String, dynamic> json) {
    return RequestFriendInfo(
      friendUid: json['friendUid'] as String,
      nickname: json['friendNickname'] as String,
      avatar: json['friendAvatar'] as String,
      gender: json['friendGender'] != null ? json['friendGender'] as int : null,
      location: json['friendLocation'] as String?,
      requestMessage: json['requestMessage'] as String?,
      status: json['status'] as int,
      createTime: _parseDateTime(json['createTime']),
      updateTime: _parseDateTime(json['updateTime']),
    );
  }
  static DateTime _parseDateTime(dynamic timestamp) {
    if (timestamp is int) {
      // 如果是整数，假定它是毫秒级时间戳
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } else if (timestamp is String) {
      // 如果是字符串，尝试解析为 ISO 8601 格式的日期时间
      return DateTime.parse(timestamp);
    } else {
      throw ArgumentError("Unsupported timestamp format");
    }
  }

  RequestFriendInfo copyWith({
    String? friendUid,
    String? nickname,
    String? avatar,
    int? gender,
    String? location,
    String? requestMessage,
    int? status,
    DateTime? createTime,
    DateTime? updateTime,
  }) {
    return RequestFriendInfo(
      friendUid: friendUid ?? this.friendUid,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      gender: gender ?? this.gender,
      location: location ?? this.location,
      requestMessage: requestMessage ?? this.requestMessage,
      status: status ?? this.status,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
    );
  }

  @override
  String toString() {
    return 'FriendRequestInfo{'
        'friendUid: $friendUid, '
        'nickname: $nickname, '
        'avatar: $avatar, '
        'gender: $gender, '
        'location: $location, '
        'requestMessage: $requestMessage, '
        'status: $status, '
        'createTime: $createTime, '
        'updateTime: $updateTime'
        '}';
  }
}
