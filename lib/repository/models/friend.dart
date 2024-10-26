import 'package:hive/hive.dart';
part 'friend.g.dart';

//flutter pub run build_runner build
@HiveType(typeId: 1)
class Friend {
  @HiveField(0)
  String userId;
  @HiveField(1)
  String? phone;
  @HiveField(2)
  String? email;
  @HiveField(3)
  String avatar;
  @HiveField(4)
  String nickname;
  @HiveField(5)
  String? alias;
  @HiveField(6)
  String? location;
  @HiveField(7)
  int? gender;
  @HiveField(8)
  String? signature;
  @HiveField(9)
  bool pinned;
  @HiveField(10)
  bool muted;
  @HiveField(11)
  DateTime createTime;
  @HiveField(12)
  DateTime updateTime;

//<editor-fold desc="Data Methods">
  Friend({
    required this.userId,
    this.phone,
    this.email,
    required this.avatar,
    required this.nickname,
    this.alias,
    this.location,
    this.gender,
    this.signature,
    required this.pinned,
    required this.muted,
    required this.createTime,
    required this.updateTime,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Friend &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          phone == other.phone &&
          email == other.email &&
          avatar == other.avatar &&
          nickname == other.nickname &&
          alias == other.alias &&
          location == other.location &&
          gender == other.gender &&
          signature == other.signature &&
          pinned == other.pinned &&
          muted == other.muted &&
          createTime == other.createTime &&
          updateTime == other.updateTime);

  @override
  int get hashCode =>
      userId.hashCode ^
      phone.hashCode ^
      email.hashCode ^
      avatar.hashCode ^
      nickname.hashCode ^
      alias.hashCode ^
      location.hashCode ^
      gender.hashCode ^
      signature.hashCode ^
      pinned.hashCode ^
      muted.hashCode ^
      createTime.hashCode ^
      updateTime.hashCode;

  @override
  String toString() {
    return 'Friend{ userId: $userId, phone: $phone, email: $email, avatar: $avatar, nickname: $nickname, alias: $alias, location: $location, gender: $gender, signature: $signature, pinned: $pinned, muted: $muted, createTime: $createTime, updateTime: $updateTime,}';
  }

  Friend copyWith({
    String? userId,
    String? phone,
    String? email,
    String? avatar,
    String? nickname,
    String? alias,
    String? location,
    int? gender,
    String? signature,
    bool? pinned,
    bool? muted,
    DateTime? createTime,
    DateTime? updateTime,
  }) {
    return Friend(
      userId: userId ?? this.userId,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      nickname: nickname ?? this.nickname,
      alias: alias ?? this.alias,
      location: location ?? this.location,
      gender: gender ?? this.gender,
      signature: signature ?? this.signature,
      pinned: pinned ?? this.pinned,
      muted: muted ?? this.muted,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'phone': phone,
      'email': email,
      'avatar': avatar,
      'nickname': nickname,
      'alias': alias,
      'location': location,
      'gender': gender,
      'signature': signature,
      'pinned': pinned,
      'muted': muted,
      'createTime': createTime,
      'updateTime': updateTime,
    };
  }

  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      userId: map['userId'] as String,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      avatar: map['avatar'] as String,
      nickname: map['nickname'] as String,
      alias: map['alias'] as String?,
      location: map['location'] as String?,
      gender: map['gender'] as int?,
      signature: map['signature'] as String?,
      pinned: map['pinned']==null?false:map['pinned'] as bool,
      muted: map['muted']==null?false:map['muted'] as bool,
      createTime: DateTime.parse(map['createTime']),
      updateTime: DateTime.parse(map['updateTime']),
    );
  }

//</editor-fold>
}
