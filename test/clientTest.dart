import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  final WebSocketChannel channel =
      IOWebSocketChannel.connect('ws://localhost:5432/ws');
  channel.sink.add("test");
}
