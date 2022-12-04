import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
//import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

import 'package:socket_io_client/socket_io_client.dart' as IO;

class WebSocket {
  // ------------------------- Members ------------------------- //
  late String url;
  WebSocketChannel? _channel;
  StreamController<bool> streamController = StreamController<bool>.broadcast();

  // ---------------------- Getter Setters --------------------- //
  String get getUrl {
    return url;
  }

  set setUrl(String url) {
    this.url = url;
  }

  Stream<dynamic> get stream {
    if (_channel != null) {
      return _channel!.stream;
    } else {
      throw WebSocketChannelException("The connection was not established !");
    }
  }

  // --------------------- Constructor ---------------------- //
  WebSocket(this.url);

  // ---------------------- Functions ----------------------- //

  /// Connects the current application to a websocket
  void connect() async {
    // _channel = IOWebSocketChannel.connect(Uri.parse(url));
    IO.Socket socket = IO.io(
        'ws://127.0.0.1:5000',
        OptionBuilder().setTransports(['websocket']).setQuery(
                {'auth': 'token'}) // for Flutter or Dart VM
            .setExtraHeaders({'auth': 'token'}) // optional
            .build());
    socket.onConnect((_) {
      print('connect');
      socket.emit('msg', 'test');
      socket.on('event', (data) => print(data));
      socket.on('fromServer', (_) => print(_));
    });

    socket.onDisconnect((_) => print('disconnect'));
  }

  /// Disconnects the current application from a websocket
  void disconnect() {
    if (_channel != null) {
      _channel!.sink.close(status.goingAway);
    }
  }
}
