import 'package:let_us_chat/core/utils/injection_container.dart';

import '../dio_client.dart';

class ChatService{
  final DioClient dioClient = serviceLocator.get();


}