import 'package:hive/hive.dart';
import '../models/request_friend_info.dart';



class LocalFriendRequestRepo {
  final Box<RequestFriendInfo> box;
  LocalFriendRequestRepo({required this.box});
  // 获取本地请求列表数据
  Future<List<RequestFriendInfo>?> getLocalRequestListData() async {
    return box.values.toList();
  }

  // 根据 friendUid 获取对应的 RequestFriendInfo
  Future<RequestFriendInfo?> getRequestInfoByFriendUid(String friendUid) async {
    return box.get(friendUid);  // 直接通过 friendUid 获取数据
  }

  // 根据 friendUid 更新信息
  Future<void> updateRequestInfoByFriendUid(String friendUid, RequestFriendInfo updatedInfo) async {
    if (box.containsKey(friendUid)) {
      await box.put(friendUid, updatedInfo);  // 直接更新指定的 friendUid 对应的数据
    } else {
      throw Exception('No request found with friendUid: $friendUid');
    }
  }

  // 保存请求列表数据
  Future<void> saveRequestListData(List<RequestFriendInfo> requestList) async {
    // 使用 friendUid 作为键保存数据
    for (var request in requestList) {
      await box.put(request.friendUid, request);
    }
  }

  // 添加单个请求
  Future<void> addRequest(RequestFriendInfo request) async {
    await box.put(request.friendUid, request);  // 使用 friendUid 作为键保存
  }

  // 获取单个请求
  RequestFriendInfo? getRequest(String friendUid) {
    return box.get(friendUid);
  }

  // 删除单个请求
  Future<void> deleteRequest(String friendUid) async {
    await box.delete(friendUid);  // 直接通过 friendUid 删除
  }
}
