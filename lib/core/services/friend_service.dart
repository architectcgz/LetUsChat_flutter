import 'dart:convert';

import 'package:let_us_chat/core/dio_client.dart';
import 'package:let_us_chat/core/errors/exception.dart';
import 'package:let_us_chat/core/utils/injection_container.dart';
import 'package:let_us_chat/models/friend_request.dart';
import '../../repository/models/friend.dart';
import '../../repository/models/request_friend_info.dart';

class FriendService {
  final DioClient dioClient = serviceLocator.get<DioClient>();

  Future<Friend?> getFriendInfo(String friendUid) async {
    final result = await dioClient.dio.get("/friend/info?friendUid=$friendUid");
    print(result);
    if (result.data['code'] == 200) {
      if(result.data['data']==null){
        return null;
      }
      return Friend.fromMap(result.data['data']);
    } else {
      throw CustomException(code: result.data['code'], message: "好友信息搜索失败");
    }
  }

  Future<List<Friend>?> search(String friendUid) async {
    final result =
        await dioClient.dio.get("/friend/search?friendUid=$friendUid");
    if (result.data['code'] == 200) {
      print(result.data);
      if (result.data['data'] != null) {
        List<dynamic> data = result.data['data'];
        List<Friend> friends =
            data.map((item) => Friend.fromMap(item)).toList();

        return friends;
      }
      return null;
    } else {
      throw CustomException(code: result.data['code'], message: "好友信息搜索失败");
    }
  }

  Future<List<Friend>?> getFriendList() async {
    final result = await dioClient.dio.get("/friend/info/list");
    if (result.data['code'] == 200) {
      if (result.data['data'] != null) {
        print(result.data['data']);
        List<dynamic> data = result.data['data'];
        List<Friend> friends =
            data.map((item) => Friend.fromMap(item)).toList();
        return friends;
      }
      return null;
    } else {
      throw CustomException(code: result.data['code'], message: "好友列表信息获取失败");
    }
  }

  Future<bool> updateFriendAlias(String friendId, String alias) async {
    final result = await dioClient.dio.post(
      "/friend/alias/update",
      data: jsonEncode({"friendUid": friendId, "alias": alias}),
    );
    print(result);
    if (result.data['code'] == 200) {
      return true;
    }
    return false;
  }

  Future<void> requestFriend(FriendRequest friendRequest) async {
    final result = await dioClient.dio.post(
      "/friend/request",
      data: jsonEncode({
        "friendId": friendRequest.friendId,
        "requestMessage": friendRequest.requestMessage,
        "alias": friendRequest.alias
      }),
    );
    if (result.data['code'] != 200) {
      throw CustomException(
          code: result.data['code'], message: result.data['message']);
    }
  }

  Future<List<RequestFriendInfo>?> getRequestFriendList()async{
    final result = await dioClient.dio.get("/friend/request/list");
    print(result);
    final data = result.data;
    if(data['code']==200){
      if(data['data']!=null){
        List<dynamic> dataList = data['data'];
        List<RequestFriendInfo> requestList = dataList.map(
            (e)=>RequestFriendInfo.fromJson(e)
        ).toList();
        return requestList;
      }
    }else{
      throw CustomException(
          code: result.data['code'], message: result.data['message']);
    }
    return null;
  }

  Future<bool>acceptFriendRequest(String friendId,String? alias) async{
    print(alias);
    String postPath = alias!=null?"/friend/accept?friendUid=$friendId&alias=$alias":"/friend/accept?friendUid=$friendId";
    final result = await dioClient.dio.post(postPath);
    if(result.statusCode==200){
      return true;
    }
    return false;
  }

  Future<RequestFriendInfo?> getRequestFriendInfo(String requestUserId) async{
    final result = await dioClient.dio.get("/friend/request/info?friendUid=$requestUserId");
    print(result);
    if(result.data['code']==200){
      return RequestFriendInfo.fromJson(result.data['data']);
    }else{
      throw CustomException(code: result.data['code'], message: result.data['message']);
    }
  }

  Future<DateTime> getUpdateTime(String friendId) async{
    final result = await dioClient.dio.get("/friend/update_time?friendId=$friendId");
    if(result.data['code']==200){
      return DateTime.parse(result.data['data']);
    }else{
      throw CustomException(code: result.data['code'], message: result.data['message']);
    }
  }

  Future<void> deleteFriend(String friendUid) async{
    final result = await dioClient.dio.post("/friend/unfriend?friendUid=$friendUid");
    if(result.data['code']!=200){
      throw CustomException(code: result.data['code'], message: result.data['message']);
    }
  }
}
