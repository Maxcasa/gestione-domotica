import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gestione_domotica/models/stati/stati_layer.dart';
import 'package:gestione_domotica/repositories/firebase/notification_sender.dart';
import 'package:gestione_domotica/repositories/mqtt/mqtt_client_wrapper.dart';
import 'package:gestione_domotica/repositories/mqtt/multi_message_provider.dart';
import 'package:gestione_domotica/views/main_drawer.dart';
import 'package:gestione_domotica/views/page_layer.dart';
import 'package:gestione_domotica/widget/connection_icon.dart';
import 'package:gestione_domotica/widget/icons_indicator.dart';
import 'package:provider/provider.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

// import 'package:logger_flutter/logger_flutter.dart';
/// Pagina di Home contenente diverse schermate che scrollano orizzontalmente
class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key) {
    mqttClientWrapper = MQTTClientWrapper();
    // if (mqttClientWrapper!.connectionState == MqttCurrentConnectionState.IDLE) {
    //   _connect();
    // }
    mqttClientWrapper!.wrapperState = MqttWrapperState.ACTIVE;
    _connect();
    mqttClientWrapper!.addListener(_connect, ['connectionState.disconnected']);
  }

  MQTTClientWrapper? mqttClientWrapper;

  void _connect() {
    mqttClientWrapper!.connectMqttClient();
  }

  void _disconnect() {
    mqttClientWrapper!.disconnect();
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  // : super(key: key);
  final PageController _controller = PageController(
    initialPage: 0,
  );

  // MultiMessageProvider multiMessageProvider = MultiMessageProvider();

  // variabili
  //int _counter = 0;
  ///varibili per la transizione di pagina
  static const _kDuration = Duration(milliseconds: 300);
  static const _kCurve = Curves.ease;

  /// Funzione per la gestione della connessione Mqtt al variare dello
  /// stato LifeCycle dell'applicativo
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print("app in resumed");
        widget.mqttClientWrapper!.wrapperState = MqttWrapperState.ACTIVE;
        widget._connect();
        break;
      case AppLifecycleState.inactive:
        print("app in inactive");
        widget.mqttClientWrapper!.wrapperState = MqttWrapperState.INACTIVE;
        widget._disconnect();
        break;
      case AppLifecycleState.paused:
        print("app in paused");
        widget.mqttClientWrapper!.wrapperState = MqttWrapperState.INACTIVE;
        widget._disconnect();
        break;
      case AppLifecycleState.detached:
        print("app in detached");
        widget.mqttClientWrapper!.wrapperState = MqttWrapperState.INACTIVE;
        widget._disconnect();
        break;
    }
    // setState(() {
    //   _notification = state;
    // });
  }

  @override
  void initState() {
    // multiMessageProvider.addMessage(
    //     'request/set', "{\"status\": \"sensori\"}", ['sensori/get']);
    // multiMessageProvider
    //     .addMessage('request/set', "{\"status\": \"stati\"}", ['stati/get']);
    /// Observer per il LifeCycle
    WidgetsBinding.instance!.addObserver(this);
    super.initState();

    /// Impostazioni per l'invio delle notifiche al sistema
    NotificationSender notificationSender = NotificationSender();
    notificationSender.addReceivedMessageAction((RemoteMessage remoteMessage) {
      _controller.animateToPage(
        0,
        duration: _kDuration,
        curve: _kCurve,
      );
    });

    // FirebaseMessaging.instance
    //     .getInitialMessage()
    //     .then((RemoteMessage? message) {
    //   if (message != null) {
    //     _controller.animateToPage(
    //       0,
    //       duration: _kDuration,
    //       curve: _kCurve,
    //     );
    //     // Navigator.pushNamed(
    //     //   context,
    //     //   '/message',
    //     //   arguments: MessageArguments(message, true),
    //     // );
    //   }
    // });

    // var androidDetails = const AndroidNotificationDetails('1', 'channelName',
    //   'channel Description');
    // var iosDetails = const IOSNotificationDetails();

    //await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

  @override
  void dispose() {
    _controller.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<SchemaStatiModel>(
        builder: (BuildContext context, SchemaStatiModel stati, Widget? child) {
      List<Widget> pageList = [SensorPage()];
      List<IconData> iconsList = [Icons.home_rounded];
      if (stati.getModel("StatoAllarme").isNotEmpty) {
        pageList.add(StatoPage(tipoStato: "StatoAllarme"));
        iconsList.add(Icons.access_alarm_rounded);
      }
      if (stati.getModel("StatoClima").isNotEmpty) {
        pageList.add(StatoPage(tipoStato: "StatoClima"));
        iconsList.add(MdiIcons.sunSnowflake);
      }
      return Scaffold(
          appBar: AppBar(
            leadingWidth: 100,
            leading: ConnectionIcon(),
            title: Text(
              'Gestione Domotica',
              style: Theme.of(context).appBarTheme.titleTextStyle,
            ),
          ),
          endDrawer: const MainDrawer(),
          body: Stack(children: [
            PageView(
              controller: _controller,
              // onPageChanged: (indice) {
              //   print(indice);
              // },
              children: pageList,
            ),
            Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: Container(
                    color: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: IconsIndicator(
                        controller: _controller,
                        iconsList: iconsList,
                        onPageSelected: (int page) {
                          _controller.animateToPage(
                            page,
                            duration: _kDuration,
                            curve: _kCurve,
                          );
                        },
                      ),
                    ))),
            // LogConsoleOnShake(
            //   dark: true,
            //   child: Center(
            //     child: Text("Shake Phone to open Console."),
            //   ),
            // )
          ]));
    });
  }

  bool connectionState() {
    if (widget.mqttClientWrapper == null ||
        widget.mqttClientWrapper!.connectionState !=
            MqttCurrentConnectionState.CONNECTED) {
      return false;
    } else {
      return true;
    }
  }
}

// class AppScrollBehavior extends MaterialScrollBehavior {
//   @override
//   Set<PointerDeviceKind> get dragDevices => {
//         PointerDeviceKind.touch,
//         PointerDeviceKind.mouse,
//       };
// }
