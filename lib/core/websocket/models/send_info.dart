class SendInfo<T> {
  int cmd;
  T data;
  SendInfo({required this.cmd, required this.data});
  Map<String, dynamic> toJson() => {
    "cmd": cmd,
    "data": data,
  };
}