import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gestione_domotica/repositories/mqtt/mqtt_client_wrapper.dart';
import 'package:gestione_domotica/repositories/mqtt/multi_message_provider.dart';
import 'package:gestione_domotica/views/main_drawer.dart';
import 'package:gestione_domotica/views/page_layer.dart';
import 'package:gestione_domotica/widget/connection_icon.dart';
import 'package:gestione_domotica/widget/icons_indicator.dart';

// import 'package:logger_flutter/logger_flutter.dart';

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
  bool active = true;

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
  int _counter = 0;

  static const _kDuration = const Duration(milliseconds: 300);

  static const _kCurve = Curves.ease;

  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  /// Create a [AndroidNotificationChannel] for heads up notifications
  late AndroidNotificationChannel channel;

  // AppLifecycleState _notification;
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
    WidgetsBinding.instance!.addObserver(this);
    super.initState();

    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        description:
            'This channel is used for important notifications.', // description
        importance: Importance.high,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      /// Create an Android Notification Channel.
      ///
      /// We use this channel in the `AndroidManifest.xml` file to override the
      /// default FCM channel to enable heads up notifications.
      flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        _controller.animateToPage(
          0,
          duration: _kDuration,
          curve: _kCurve,
        );
        // Navigator.pushNamed(
        //   context,
        //   '/message',
        //   arguments: MessageArguments(message, true),
        // );
      }
    });

    FirebaseMessaging.instance.subscribeToTopic('fcm_test');

    // var androidDetails = const AndroidNotificationDetails('1', 'channelName',
    //   'channel Description');
    // var iosDetails = const IOSNotificationDetails();

    //await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        _controller.animateToPage(
          0,
          duration: _kDuration,
          curve: _kCurve,
        );

        // var generalNotificationDetails =
        //   NotificationDetails(android: androidDetails, iOS: iosDetails)

        // flutterLocalNotificationsPlugin.show(
        //   notification.hashCode, notification.title, notification.
        //   body, generalNotificationDetails);
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      _controller.animateToPage(
        0,
        duration: _kDuration,
        curve: _kCurve,
      );
      // Navigator.pushNamed(
      //   context,
      //   '/message',
      //   arguments: MessageArguments(message, true),
      // );
    });
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
        body: RefreshIndicator(
            // reload page
            onRefresh: () => _refresh(),
            child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                child: Stack(children: [
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
                          color: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.all(20.0),
                          child: Center(
                            child: IconsIndicator(
                              controller: _controller,
                              iconsList: const [
                                Icons.home_rounded,
                                Icons.access_alarm_rounded
                              ],
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
                ]))));
  }

  Future<void> _refresh() async {
    print("REFRESH");
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
