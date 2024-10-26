import 'package:let_us_chat/core/dio_client.dart';
import 'package:let_us_chat/core/errors/exception.dart';
import 'package:let_us_chat/core/utils/injection_container.dart';

import '../../repository/models/group.dart';



class GroupService{
  final DioClient dioClient = serviceLocator.get<DioClient>();

  Future<List<Group>?> search(String groupId)async{
    final result = await dioClient.dio.get("/group/search?groupId=$groupId");
    if(result.data['code']==200){
      final data = result.data['data'];
      if(data!=null){
        List<dynamic> data = result.data['data'];
        List<Group> groups = data.map((item) => Group.fromMap(item)).toList();
        return groups;
      }else{
        return null;
      }
    }else{
      throw CustomException(code: result.data['code'], message: result.data['message']);
    }
  }
}