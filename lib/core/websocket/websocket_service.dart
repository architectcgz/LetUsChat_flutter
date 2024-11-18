import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:let_us_chat/blocs/chat_list/chat_list_bloc.dart';
import 'package:let_us_chat/blocs/contact_list/contact_list_bloc.dart';
import 'package:let_us_chat/blocs/send_file/send_file_bloc.dart';
import 'package:let_us_chat/core/constants/constants.dart';
import 'package:let_us_chat/core/dio_client.dart';
import 'package:let_us_chat/core/global.dart';
import 'package:let_us_chat/core/utils/injection_container.dart';
import 'package:let_us_chat/core/websocket/models/accept_friend_req_msg.dart';
import 'package:let_us_chat/core/websocket/models/received_message.dart';
import 'package:let_us_chat/models/file_slice.dart';
import 'package:let_us_chat/models/file_to_send.dart';
import 'package:let_us_chat/repository/local/local_friend_repo.dart';
import 'package:let_us_chat/repository/models/friend.dart';
import 'package:let_us_chat/repository/models/request_friend_info.dart';
import 'package:let_us_chat/routes/app_navigation.dart';
import 'package:let_us_chat/widgets/request_send_file_pop_up.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../blocs/global_user/global_user_bloc.dart';
import '../../blocs/receive_file/receive_file_bloc.dart';
import '../../models/message.dart';
import '../../widgets/logout_pop_up.dart';
import '../constants/enums.dart';
import 'models/send_info.dart';

final DioClient dioClient = serviceLocator.get<DioClient>();
final globalUserBloc = serviceLocator.get<GlobalUserBloc>();

class UserInfo {
  String userId;
  int terminal;

  UserInfo({required this.userId, required this.terminal});

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "terminal": terminal,
      };
}

class WebSocketFriendRequest {
  UserInfo requestUserInfo;
  String friendId;
  String? requestMessage;

  WebSocketFriendRequest(
      {required this.requestUserInfo,
      required this.friendId,
      required this.requestMessage});

  Map<String, dynamic> toJson() => {
        "requestUserInfo": requestUserInfo,
        "friendId": friendId,
        "requestMessage": requestMessage
      };
}

class ConnectInfo {
  String accessToken;
  ConnectInfo({required this.accessToken});
  Map<String, dynamic> toJson() => {"accessToken": accessToken};
}

class WebSocketService {
  WebSocketChannel? channel;
  final String serverUrl;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  bool _isConnected = false;
  bool _isManuallyClosed = false;
  WebSocketService({required this.serverUrl});
  final Map<String, Function(MessageDto)> _messageHandlers = {};

  void startConnection() {
    print("serverUri: $serverUrl");
    if (!_isConnected) {
      channel = WebSocketChannel.connect(Uri.parse(serverUrl));
      _isConnected = true;
      channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onDone: () {
          _isConnected = false;

          // 如果是手动关闭，不进行自动重连
          if (!_isManuallyClosed) {
            _reconnect();
          }

          // 重置手动关闭标志
          _isManuallyClosed = false;
        },
        onError: (error) {
          _isConnected = false;

          // 打印错误
          print(error.toString());

          // 如果是手动关闭，不进行自动重连
          if (!_isManuallyClosed) {
            _reconnect();
          }

          // 重置手动关闭标志
          _isManuallyClosed = false;
        },
      );

      // 发送连接消息
      sendConnectMessage();
    }
  }

  void _handleReceiveSendFileReq(String friendUid, String friendName,
      List<Map<String, dynamic>> fileList, int fileListHashCode) {
    showDialog(
      context: AppNavigation.rootNavigatorKey.currentContext!,
      builder: (BuildContext context) {
        return RequestSendFilePopUp(
            friendUid: friendUid,
            friendName: friendName,
            fileList: fileList,
            fileListHashCode: fileListHashCode);
      },
      barrierDismissible: false, //点击对话框外部不会关闭对话框
    );
  }

  void _handleForceLogout() {
    showDialog(
      context: AppNavigation.rootNavigatorKey.currentContext!,
      builder: (BuildContext context) {
        return const LogoutPopUp();
      },
      barrierDismissible: false,
    );
  }

  void disconnect({bool isManual = true}) {
    // 标记为手动关闭连接
    _isManuallyClosed = isManual;

    // 取消心跳和重连的定时器
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();

    // 关闭 WebSocket 连接
    channel?.sink.close();

    // 更新连接状态
    _isConnected = false;
  }

  void _handleMessage(String message) {
    //print('Received message: $message');

    try {
      Map<String, dynamic> jsonMessage = json.decode(message);
      int cmd = jsonMessage['cmd'];
      var data = jsonMessage['data'];
      ReceivedMessage receivedMessage = ReceivedMessage(cmd: cmd, data: data);

      _handleReceivedCmd(receivedMessage);
    } catch (e) {
      print('Error parsing message: $e');
    }
  }

  void _handleReceivedCmd(ReceivedMessage receivedMessage) {
    NettyCmdType? cmdType = NettyCmdType.fromCode(receivedMessage.cmd);

    if (cmdType != null) {
      switch (cmdType) {
        case NettyCmdType.tokenExpired:
          dioClient.refreshToken();
          _reconnect();
          break;
        case NettyCmdType.connect:
          print('Handling CONNECT with data: ${receivedMessage.data}');
          _startHeartbeat();
          break;
        case NettyCmdType.heartBeat:
          print('Handling HEART_BEAT with data: ${receivedMessage.data}');
          break;
        case NettyCmdType.forceLogout:
          print('Handling FORCE_LOGOUT with data: ${receivedMessage.data}');
          disconnect();
          _handleForceLogout();

          break;
        case NettyCmdType.privateMessage:
          print('Handling PRIVATE_MESSAGE with data: ${receivedMessage.data}');
          final data = receivedMessage.data['data'];
          final senderId = data['senderId'];
          final receiverId = data['receiverId'];
          print(data['sendTime']);
          var privateMessage = MessageDto(
              receiverId: receiverId,
              messageId: data['id'].toString(),
              senderId: senderId,
              messageType: MessageType.fromCode(data['messageType'])!,
              messageStatus: MessageStatus.fromCode(data['status'])!,
              sendTime: DateTime.fromMillisecondsSinceEpoch(data['sendTime']),
              content: data['content'],
              mediaName: data['mediaName'],
              mediaUrl: data['mediaUrl'],
              mediaSize: data['mediaSize']?.toDouble(),
              chatType: ChatType.singleChat);
          // 如果有对应 friendId 的消息处理器，也就是停留在聊天节目，触发回调
          if (_messageHandlers.containsKey(senderId)) {
            print("在singleChatPage处理信息");
            _messageHandlers[senderId]!(privateMessage);
          } else {
            //否则,在chatList页面显示未读消息
            print("在chatList页面显示未读消息");
            serviceLocator
                .get<RecentChatListBloc>()
                .add(ReceiveNewMessageEvent(message: privateMessage));
          }
          break;
        case NettyCmdType.groupMessage:
          print('Handling GROUP_MESSAGE with data: ${receivedMessage.data}');
          break;
        case NettyCmdType.friendRequest:
          print('Handling FRIEND_REQUEST with data: ${receivedMessage.data}');
          print("${receivedMessage.data}");
          RequestFriendInfo requestFriendInfo =
              RequestFriendInfo.fromJson(receivedMessage.data);
          serviceLocator.get<ContactListBloc>().add(
              ReceiveFriendRequestEvent(requestFriendInfo: requestFriendInfo));
          //serviceLocator.get<ContactListBloc>().add(ReceiveRequest)
          break;
        case NettyCmdType.groupRequest:
          print('Handling GROUP_REQUEST with data: ${receivedMessage.data}');
          break;
        case NettyCmdType.acceptFriendRequest:
          print(
              'Handling ACCEPT_FRIEND_REQUEST with data: ${receivedMessage.data}');
          var data = receivedMessage.data;
          AcceptFriendReqMsg acceptFriendReqMsg = AcceptFriendReqMsg(
              acceptUserId: data['acceptUserId'],
              requestUserId: data['requestUserId']);
          serviceLocator
              .get<ContactListBloc>()
              .add(AddFriendEvent(friendUid: acceptFriendReqMsg.acceptUserId));

          break;
        case NettyCmdType.acceptGroupRequest:
          print(
              'Handling ACCEPT_GROUP_REQUEST with data: ${receivedMessage.data}');
          break;
        case NettyCmdType.sendFileRequest:
          final senderId = receivedMessage.data['senderId'] as String;
          Friend? friend =
              serviceLocator.get<LocalFriendRepo>().getFriend(senderId);
          if (friend != null) {
            print(
                "接收到好友发送文件的申请\n fileListHashCode: ${receivedMessage.data['fileListHashCode'].toString()} fileList: ${receivedMessage.data['fileList'].toString()} ");
            var fileList = receivedMessage.data['fileList'] as List<dynamic>;
            var decodedList = fileList
                .map((e) => {
                      "fileIndex": e['fileIndex'] ,
                      "fileName": e['fileName'],
                      "fileSize": e['fileSize']
                    })
                .toList();
            _handleReceiveSendFileReq(
                senderId,
                friend.alias ?? friend.nickname,
                decodedList,
                int.parse(receivedMessage.data['fileListHashCode']));
          } else {
            print("本地没有保存Uid: $senderId的好友信息");
          }
          break;
        case NettyCmdType.acceptFileRequest:
          print(
              "对方接受了向其发送文件的请求,这次文件list的hashCode为: ${receivedMessage.data['fileListHashCode']}");
          serviceLocator.get<SendFileBloc>().add(FriendAcceptFileReqEvent(
              friendUid: receivedMessage.data['acceptUserId'],
              fileListHashCode:
                  int.parse(receivedMessage.data['fileListHashCode'])));
          break;
        case NettyCmdType.fileSlice:
          //print("收到了来自好友的文件slice");
          var data = receivedMessage.data;
          int fileIndex = data['fileIndex'];
          String fileName = data['fileName'] as String;
          String senderId = data['senderId'] as String;
          int chunkIndex = data['chunkIndex'];
          int totalChunks =  data['totalChunks'];
          List<int> chunkData = base64Decode(data['data']);
          serviceLocator.get<ReceiveFileBloc>().add(ReceiveFileSliceEvent(
              fileSlice: FileSlice(
                  fileIndex: fileIndex,
                  fileName: fileName,
                  senderId: senderId,
                  chunkIndex: chunkIndex,
                  totalChunks: totalChunks,
                  chunkData: chunkData)));
      }
    } else {
      print('未知command: ${receivedMessage.cmd}');
    }
  }

  // 注册消息处理回调
  void registerMessageHandler(String friendId, Function(MessageDto) handler) {
    _messageHandlers[friendId] = handler;
  }

  // 注销消息处理回调
  void unregisterMessageHandler(String friendId) {
    _messageHandlers.remove(friendId);
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer =
        Timer.periodic(const Duration(seconds: heartBeatDuration), (timer) {
      _sendHeartbeat();
    });
  }

  void _sendHeartbeat() {
    if (_isConnected) {
      var heartbeat = {
        "cmd": NettyCmdType.heartBeat.code,
        "data": {
          "sender": UserInfo(userId: currentUserId!, terminal: 2).toJson(),
          "sendResult": false,
        },
      };
      _send(jsonEncode(heartbeat));
    }
  }

  void _reconnect() {
    if (_reconnectTimer == null || !_reconnectTimer!.isActive) {
      _reconnectTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (!_isConnected) {
          startConnection();
        }
      });
    }
  }

  void _send(String message) {
    print("发送的信息: $message");
    if (_isConnected && channel != null) {
      channel!.sink.add(message);
    } else {
      print("未连接，无法发送信息");
    }
  }

  void sendPrivateMessage(
      String senderId, int senderTerminal, String receiverId, String data) {
    var message = {
      "cmd": NettyCmdType.privateMessage.code,
      "data": {
        "sender": UserInfo(userId: senderId, terminal: senderTerminal).toJson(),
        "receiverId": receiverId,
        "receiveTerminals": [1],
        "data": data,
        "sendResult": true,
      },
    };
    _send(jsonEncode(message));
  }

  void sendFileSlice(
      int fileIndex,
      String fileName,
      String senderId,
      String receiverId,
      List<int> accumulatedData,
      int chunkSize,
      int chunkIndex,
      int totalChunks) {
    // int start = chunkIndex * chunkSize;
    // int end = (chunkIndex + 1) * chunkSize > accumulatedData.length
    //     ? accumulatedData.length
    //     : (chunkIndex + 1) * chunkSize;

    var message = {
      "cmd": NettyCmdType.fileSlice.code,
      "data": {
        "fileIndex":fileIndex,
        "fileName": fileName,
        "senderId": senderId,
        "receiverId": receiverId,
        'data': base64Encode(accumulatedData),
        'chunkIndex': chunkIndex,
        'totalChunks': totalChunks,
        "sendResult": true,
      },
    };
    _send(jsonEncode(message));
  }

  void sendConnectMessage() {
    var accessToken = globalAccessToken;
    if (accessToken == null) {
      dioClient.refreshToken();
    } else {
      var message = SendInfo(
          cmd: NettyCmdType.connect.code,
          data: ConnectInfo(accessToken: accessToken));
      _send(jsonEncode(message));
    }
  }

  void sendGroupMessage(
      String senderId, int senderTerminal, String groupId, String data) {
    var message = {
      "cmd": NettyCmdType.groupMessage.code,
      "data": {
        "sender": UserInfo(userId: senderId, terminal: senderTerminal).toJson(),
        "receiverId": groupId,
        "data": data,
        "sendResult": true,
      },
    };
    _send(jsonEncode(message));
  }

  void sendGroupRequest(String senderId, int senderTerminal, String groupId) {
    var message = {
      "cmd": NettyCmdType.groupRequest.code,
      "data": {
        "sender": UserInfo(userId: senderId, terminal: senderTerminal).toJson(),
        "receiverId": groupId,
        "sendResult": true,
      },
    };
    _send(jsonEncode(message));
  }

  void sendAcceptFriendRequest(String requestUserId, String acceptUserId) {
    var message = SendInfo(
      cmd: NettyCmdType.acceptFriendRequest.code,
      data: AcceptFriendReqMsg(
        acceptUserId: acceptUserId,
        requestUserId: requestUserId,
      ),
    );
    _send(jsonEncode(message));
  }

  void sendFileRequest(String receiverId, String senderId,
      List<FileToSend> fileList, int fileListHashCode) {
    print("发送的sendFileRequest, 此次fileList的hashCode为: $fileListHashCode");
    var message = SendInfo(
      cmd: NettyCmdType.sendFileRequest.code,
      data: {
        "senderId": senderId,
        "receiverId": receiverId,
        "fileListHashCode": fileListHashCode,
        "fileList": fileList.map((file) {
          return {
            "fileIndex": file.fileIndex,
            'fileName': file.fileName,
            'fileSize': file.getFixedFileSize()
          };
        }).toList(),
      },
    );
    _send(jsonEncode(message));
  }

  void sendAcceptFileRequest(
      String sendUserId, String acceptUserId, int fileListHashCode) {
    var message = SendInfo(cmd: NettyCmdType.acceptFileRequest.code, data: {
      "sendUserId": sendUserId,
      "acceptUserId": acceptUserId,
      "fileListHashCode": fileListHashCode,
    });
    _send(jsonEncode(message));
  }
}
