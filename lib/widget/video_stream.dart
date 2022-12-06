import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gestione_domotica/models/sensori/sensore_camera.dart';
import 'package:gestione_domotica/repositories/video_socket_stream.dart';

class VideoStream extends StatelessWidget {
  VideoStream({Key? key, required this.sensoreCamera}) : super(key: key) {
    if (sensoreCamera.token != null) {
      videoSocketStream = VideoSocketStream(sensoreCamera.token!);
    } else {
      richiediToken();
    }
  }

  SensoreCamera sensoreCamera;

  VideoSocketStream? videoSocketStream;

  @override
  Widget build(BuildContext context) {
    if (videoSocketStream != null) {
      return Container(
        child: StreamBuilder(
          stream: videoSocketStream!.getResponse,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }
            return Image.memory(
              Uint8List.fromList(
                base64Decode(
                  (snapshot.data.toString()),
                ),
              ),
              gaplessPlayback: true,
              excludeFromSemantics: true,
            );
            // return Container(
            //   child: snapshot.data ??  ,
            // );
          },
        ),
      );
    } else {
      return const CircularProgressIndicator();
    }
  }

  void richiediToken() {
    // il valore -10 corrisponde alla richiesta di un token
    sensoreCamera.cambiaValore(-10);
  }

  void disconnect() {
    videoSocketStream?.disconnect();
    sensoreCamera.token = null;
  }
}
