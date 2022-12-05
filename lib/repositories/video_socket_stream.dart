import 'dart:async';

// import 'package:socket_io_client/socket_io_client.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
// //import 'package:web_socket_channel/io.dart';
// import 'package:web_socket_channel/status.dart' as status;

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:gestione_domotica/models/configurazioni/remote_connection.dart';

class VideoSocketStream {
  // --------------------- Constructor ---------------------- //
  VideoSocketStream(this.token) {
    remoteConnection = RemoteConnection();
    remoteConnection!.addListener(() async {
      await connect();
    }, [
      'activeIndex',
      'connectivity',
      'connectionInfo',
      'connectionConf',
      'connectionActive'
    ]);
    remoteConnection!.getConnectionInfo();
    connect();
  }

  // ------------------------- Members ------------------------- //
  late IO.Socket socket;

  final _socketResponse = StreamController<String>();

  void Function(String) get addResponse => _socketResponse.sink.add;

  Stream<String> get getResponse => _socketResponse.stream;

  RemoteConnection? remoteConnection;

  String token;

  /// Connects the current application to a websocket
  Future<void> connect() async {
    if (remoteConnection != null &&
        !remoteConnection!.connectionDataNull &&
        remoteConnection!.connectionPresent) {
      // _channel = IOWebSocketChannel.connect(Uri.parse(url));
      socket = IO.io(
          'ws://${remoteConnection!.remoteServerName}:5000',
          IO.OptionBuilder().setTransports(['websocket']).setQuery(
                  {'auth': 'token'}) // for Flutter or Dart VM
              .setExtraHeaders({'auth': token}) // optional
              .build());
      socket.onConnect((_) {
        print('connect');
      });

      socket.on('frame', (data) => addResponse);
      socket.onDisconnect((_) => print('disconnect'));
    }
  }

  Future<void> disconnect() async {
    socket.disconnect();
  }

  // ---------------------- Functions ----------------------- //

}
