import 'package:let_us_chat/core/errors/exception.dart';
import 'package:let_us_chat/models/message.dart';
import 'package:let_us_chat/models/message_send_result.dart';

import '../dio_client.dart';
import '../utils/injection_container.dart';

class GroupMessageService{
  final dioClient = serviceLocator.get<DioClient>();
  Future<MessageSendResult> sendMessage(MessageDto message)async{
    final result = await dioClient.dio.post("/message/group/send");
    if(result.data['code']==200){
      return MessageSendResult.fromMap(result.data['data']);
    }else{
      throw CustomException(code: result.data['code'], message: result.data['message']);
    }
  }
  Future<void> recallMessage(int messageId)async{
    final result = await dioClient.dio.post("/message/group/send");
    if(result.data['code']==200){
       return;
    }else{
      throw CustomException(code: result.data['code'], message: result.data['message']);
    }
  }
}