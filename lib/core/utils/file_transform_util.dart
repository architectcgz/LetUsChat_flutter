import 'dart:typed_data';

class FileTransformUtil {
  static Future<Uint8List> streamToUint8List(Stream<List<int>> stream) async {
    final byteList = <int>[]; // 用于存储接收到的字节
    print("正在将stream 转换为Uint8List");
    // 监听流
    await for (final chunk in stream) {
      byteList.addAll(chunk); // 将每个 List<int> 添加到 byteList
    }
    return Uint8List.fromList(byteList); // 转换为 Uint8List
  }
}
