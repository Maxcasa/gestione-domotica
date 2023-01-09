import 'dart:async';
import 'dart:io';

// import 'package:socket_io_client/socket_io_client.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
// //import 'package:web_socket_channel/io.dart';
// import 'package:web_socket_channel/status.dart' as status;

import 'package:path_provider/path_provider.dart';
import 'package:property_change_notifier/property_change_notifier.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:gestione_domotica/models/configurazioni/remote_connection.dart';
import 'package:flutter/services.dart' show rootBundle;

const String ConnPort = "5002";

enum SocketCurrentConnectionState {
  IDLE,
  CONNECTING,
  CONNECTED,
  DISCONNECTING,
  DISCONNECTED,
  ERROR_WHEN_CONNECTING
}

class VideoSocketStream extends PropertyChangeNotifier<String> {
  // --------------------- Constructor ---------------------- //
  static final VideoSocketStream _instance = VideoSocketStream._internal();

  factory VideoSocketStream() {
    return _instance;
  }

  VideoSocketStream._internal() {
    remoteConnection = RemoteConnection();
    // remoteConnection!.addListener(() async {
    //   await connect();
    // }, [
    //   'activeIndex',
    //   'connectivity',
    //   'connectionInfo',
    //   'connectionConf',
    //   'connectionActive'
    // ]);
    remoteConnection!.getConnectionInfo();
    //connect();
  }

  // ------------------------- Members ------------------------- //
  late IO.Socket socket;

  final _socketResponse = StreamController<String>();

  // void Function(String) get addResponse => _socketResponse.sink.add;

  Stream<String> get getResponse => _socketResponse.stream;

  RemoteConnection? remoteConnection;
  SocketCurrentConnectionState connectionState =
      SocketCurrentConnectionState.IDLE;

  String? _token;

  String? get token {
    return _token;
  }

  set token(String? token) {
    if (token != _token) {
      if (connectionState == SocketCurrentConnectionState.CONNECTED) {
        socket.disconnect();
      }
    }
  }

  /// Connects the current application to a websocket
  Future<void> connect() async {
    if (remoteConnection != null &&
        !remoteConnection!.connectionDataNull &&
        remoteConnection!.connectionPresent) {
      final directory = await getApplicationDocumentsDirectory();

      // loading CA Certificate
      dynamic sslCa;
      if (remoteConnection!.caFile != null &&
          remoteConnection!.certDirBase != null) {
        try {
          sslCa = await File(
                  '${directory.path}/${remoteConnection!.connectionName}${remoteConnection!.caFile}.pfx')
              .readAsBytes();
          // securityContext.setClientAuthoritiesBytes(sslCa.buffer.asInt8List(),
          //     password: 'test');
        } catch (e) {
          print('HTTPS connection error::client exception - $e');
          // client!.disconnect();
        }
      } else {
        sslCa = await rootBundle.load('assets/certs/ca/ca.pfx');
      }
      String passPhrase = 'supermax';

      // loading Client Certificate
      dynamic sslCert;
      if (remoteConnection!.certFile != null &&
          remoteConnection!.certDirBase != null) {
        try {
          sslCert = await File(
                  '${directory.path}/${remoteConnection!.connectionName}${remoteConnection!.certFile}.pfx')
              .readAsBytes();
        } catch (e) {
          print('HTTPS connection error::client exception - $e');
        }
      } else {
        sslCert = await rootBundle.load('assets/certs/client/client.pfx');
      }

      // loadinf Client Key
      dynamic sslKey;
      if (remoteConnection!.keyFile != null &&
          remoteConnection!.certDirBase != null) {
        try {
          sslKey = await File(
                  '${directory.path}/${remoteConnection!.connectionName}${remoteConnection!.keyFile}.key')
              .readAsBytes();

          //, password: 'HostPass997');
        } catch (e) {
          print('HTTPS connection error::client exception - $e');
          // client!.disconnect();
        }
      } else {
        sslKey = await rootBundle.load('assets/certs/client/client.key');
      }

      String remoteBackUri =
          'https://${remoteConnection!.remoteServerName}:$ConnPort/';
      // 'ws://${remoteConnection!.remoteServerName}:5000'
      socket = IO.io(
          remoteBackUri,
          IO.OptionBuilder()
              .setTransports(['websocket'])
              .setCa(sslCa)
              .setPassphrase(passPhrase)
              .setPfx(sslCert)
              .setKey(sslKey)
              .setQuery({'auth': _token})
              .build());
      connectionState = SocketCurrentConnectionState.CONNECTING;
      socket.onConnect((_) {
        connectionState = SocketCurrentConnectionState.CONNECTING;
        notifyListeners('connected');
        print('connect');
      });

      socket.on('frame', (data) {
        print('frame');
        _socketResponse.sink.add(data);
      });

      socket.onDisconnect((_) {
        //socket.disconnect();
        connectionState = SocketCurrentConnectionState.DISCONNECTED;
        notifyListeners('disconnected');
      });
    }
  }

  Future<void> disconnect() async {
    connectionState = SocketCurrentConnectionState.DISCONNECTING;
    socket.disconnect();
  }

  // ---------------------- Functions ----------------------- //

}
