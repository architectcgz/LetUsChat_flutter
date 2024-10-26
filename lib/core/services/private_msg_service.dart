import 'package:dio/dio.dart';
import 'package:let_us_chat/core/dio_client.dart';
import 'package:let_us_chat/core/errors/exception.dart';
import 'package:let_us_chat/core/utils/injection_container.dart';
import 'package:let_us_chat/models/message.dart';
import 'package:let_us_chat/models/message_send_result.dart';

class PrivateMessageService{
  final dioClient = serviceLocator.get<DioClient>();
  Future<MessageSendResult> sendMessage(MessageDto message)async{
    print(message);
    try{
      final result = await dioClient.dio.post("/message/private/send",data:message.toMap());
      if(result.data['code']==200){
        print(result.data['data']);
        return MessageSendResult.fromMap(result.data['data']);
      }else{
        throw CustomException(code: result.data['code'], message: result.data['message']);
      }
    }on DioException
    catch(e){
      print(e);
      throw CustomException(code: 400, message: e.toString());
    }
  }
  Future<bool> recallMessage(int messageId)async{
    final result = await dioClient.dio.get("/message/private/recall/$messageId");
    if(result.data['code']==200){
      return true;
    }
    return false;
  }
}