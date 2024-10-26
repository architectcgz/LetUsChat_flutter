class User {
  final String userId;
  final String? phone;
  final String? email;
  String username;
  String avatar;
  String qrCode;
  final int status;
  int joinType;
  int? gender;
  String? location;
  String? signature;
  final int userType;
  final int addType;
  DateTime createTime;
  DateTime updateTime;
  User(
      {required this.userId,
      required this.phone,
      required this.email,
      required this.avatar,
      required this.qrCode,
      required this.username,
      required this.status,
      required this.joinType,
      required this.gender,
      required this.location,
      required this.signature,
      required this.userType,
      required this.addType,
      required this.createTime,
        required this.updateTime
      });
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      phone: json['phone'],
      email: json['email'],
      avatar: json['avatar']??"https://avatar.iran.liara.run/public/boy?username=Ash",
      qrCode: json['qrCode'],
      username: json['nickname'],
      status: json['status'],
      joinType: json['joinType'],
      gender: json['gender'],
      location: json['location'],
      signature: json['signature'],
      userType: json['userType'],
      addType: json['addType'],
      createTime: DateTime.parse(json['createTime']),
      updateTime: DateTime.parse(json['updateTime'])
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'phone': phone,
      'email': email,
      'nickname': username,
      'avatar':avatar,
      'qrCode':qrCode,
      'status': status,
      'joinType': joinType,
      'gender': gender,
      'location': location,
      'signature': signature,
      'userType': userType,
      'addType': addType,
      'createTime': createTime.toIso8601String(),
      'updateTime': updateTime.toIso8601String()
    };
  }

  @override
  String toString() {
    return 'User{userId: $userId, phone: $phone, email: $email, nickname: $username, avatar: $avatar, qrCode: $qrCode, status: $status, joinType: $joinType, gender: $gender, signature: $signature, userType: $userType, addType: $addType, createTime: $createTime, updateTime: $updateTime}';
  }
}
