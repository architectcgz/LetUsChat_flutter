enum ValueType { int, double, bool, string }

enum LoginType {
  emailLogin(0, "邮箱登录"),
  phoneLogin(1, "手机号登录");

  final int code;
  final String desc;
  const LoginType(this.code, this.desc);
  static LoginType? fromCode(int code) {
    for (var typeEnum in LoginType.values) {
      if (typeEnum.code == code) {
        return typeEnum;
      }
    }
    return null;
  }
}

enum NettyCmdType {
  tokenExpired(0, "token过期"),
  connect(1, "第一次(或重连)初始化连接"),
  heartBeat(2, "心跳"),
  forceLogout(3, "强制下线"),
  privateMessage(4, "私聊消息"),
  groupMessage(5, "群发消息"),
  friendRequest(6, "好友请求"),
  groupRequest(7, "加群请求"),
  acceptFriendRequest(8, "接受好友请求"),
  acceptGroupRequest(9, "接受群组请求"),
  sendFileRequest(10, "请求向好友发送文件"),
  acceptFileRequest(11, "接受好友的文件请求"),
  fileSlice(12, "文件分片");

  final int code;
  final String desc;

  const NettyCmdType(this.code, this.desc);

  static NettyCmdType? fromCode(int code) {
    for (var typeEnum in NettyCmdType.values) {
      if (typeEnum.code == code) {
        return typeEnum;
      }
    }
    return null;
  }
}

enum ChatType {
  singleChat(0, "单聊"),
  groupChat(1, "群聊");

  final int code;
  final String desc;
  const ChatType(this.code, this.desc);
  static ChatType? fromCode(int code) {
    for (var typeEnum in ChatType.values) {
      if (typeEnum.code == code) {
        return typeEnum;
      }
    }
    return null;
  }
}

enum MessageType {
//消息类型 0:文字 1:图片 2:文件 3:视频 4: 语音 5:撤回消息
  text(0, "文本"),
  image(1, "图片"),
  file(2, "文件"),
  video(3, "视频"),
  voice(4, "语音"),
  recall(5, "撤回消息");

  final int code;
  final String desc;
  const MessageType(this.code, this.desc);
  static MessageType? fromCode(int code) {
    for (var typeEnum in MessageType.values) {
      if (typeEnum.code == code) {
        return typeEnum;
      }
    }
    return null;
  }
}

enum MessageStatus {
  sending(0, "发送中"),
  sent(1, "发送成功"),
  failed(2, "发送失败"),
  recalled(3, "已撤回");

  final int code;
  final String desc;
  const MessageStatus(this.code, this.desc);
  static MessageStatus? fromCode(int code) {
    for (var typeEnum in MessageStatus.values) {
      if (typeEnum.code == code) {
        return typeEnum;
      }
    }
    return null;
  }
}

enum PlayerStatus {
  ready(0, "已准备"),
  playing(1, "正在播放"),
  paused(2, "暂停"),
  complete(3, "播放完成");

  final int code;
  final String desc;
  const PlayerStatus(this.code, this.desc);
  static PlayerStatus? fromCode(int code) {
    for (var typeEnum in PlayerStatus.values) {
      if (typeEnum.code == code) {
        return typeEnum;
      }
    }
    return null;
  }
}

enum SendFileStatus {
  notSendYet(0, "尚未发送"),
  sending(1, "发送中"),
  succeed(2, "发送成功"),
  failed(3, "发送失败");

  final int code;
  final String desc;
  const SendFileStatus(this.code, this.desc);
  static SendFileStatus? fromCode(int code) {
    for (var typeEnum in SendFileStatus.values) {
      if (typeEnum.code == code) {
        return typeEnum;
      }
    }
    return null;
  }
}
