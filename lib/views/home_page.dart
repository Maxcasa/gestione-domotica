import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gestione_domotica/views/page_layer.dart';
import 'package:gestione_domotica/widget/dot_indicator.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key) {
    // mqttClientWrapper = MQTTClientWrapper();
    // if (mqttClientWrapper!.connectionState == MqttCurrentConnectionState.IDLE) {
    //   _connect();
    // }
    // mqttClientWrapper!.addListener(_connect, ['connectionState.disconnected']);
  }

  // MQTTClientWrapper? mqttClientWrapper;

  // void _connect() {
  //   mqttClientWrapper!.connectMqttClient();
  // }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // : super(key: key);
  PageController _controller = PageController(
    initialPage: 0,
  );

  int _counter = 0;

  static const _kDuration = const Duration(milliseconds: 300);

  static const _kCurve = Curves.ease;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      PageView(
        controller: _controller,
        onPageChanged: (indice) {
          print(indice);
        },
        children: [
          SensorPage(),
          AllarmPage(),
        ],
      ),
      Positioned(
          bottom: 0.0,
          left: 0.0,
          right: 0.0,
          child: Container(
              color: Colors.grey[800]!.withOpacity(0.5),
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: DotsIndicator(
                  controller: _controller,
                  itemCount: 2,
                  onPageSelected: (int page) {
                    _controller.animateToPage(
                      page,
                      duration: _kDuration,
                      curve: _kCurve,
                    );
                  },
                ),
              )))
    ]);
  }

  // Widget connectionState() {
  //   if (widget.mqttClientWrapper == null ||
  //     widget.mqttClientWrapper!.connectionState != MqttCurrentConnectionState.CONNECTED) {
  //       return Icon(Icons.cloud_off_outlined, color: Colors.red, size: 20);
  //   } else {
  //     return Icon(Icons.cloud_outlined, color: Colors.green, size: 20);
  //   }
  // }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
