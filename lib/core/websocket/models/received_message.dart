class ReceivedMessage<T>{
  int cmd;
  T data;
  ReceivedMessage({required this.cmd,required this.data});
}