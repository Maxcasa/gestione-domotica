// import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gestione_domotica/models/remote_conf/remote_connection.dart';
import 'package:gestione_domotica/models/timer/timer_attivazioni.dart';
import 'package:gestione_domotica/repositories/firebase/firebase_options.dart';
import 'package:gestione_domotica/repositories/timers_repository.dart';
import 'package:gestione_domotica/views/home_page.dart';
// import 'package:gestione_domotica/views/main_drawer.dart';
import 'package:provider/provider.dart';
import 'package:gestione_domotica/models/sensori/sensori_layer.dart';
import 'package:gestione_domotica/models/stati/schema_stati_model.dart';
import 'package:gestione_domotica/views/page_layer.dart';
import 'package:gestione_domotica/repositories/mqtt/mqtt_client_wrapper.dart';
import 'models/drawer/main_drawer_provider.dart';
// import 'package:gestione_domotica/widget/connection_icon.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Define a top-level named handler which background/terminated messages will
/// call.
///
/// To verify things are working, check out the native platform logs.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Handling a background message ${message.messageId}');
}

// /// Create a [AndroidNotificationChannel] for heads up notifications
// late AndroidNotificationChannel channel;

/// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (!kIsWeb) {
    // channel = const AndroidNotificationChannel(
    //   'high_importance_channel', // id
    //   'High Importance Notifications', // title
    //   description:
    //       'This channel is used for important notifications.', // description
    //   importance: Importance.high,
    // );

    // flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // /// Create an Android Notification Channel.
    // ///
    // /// We use this channel in the `AndroidManifest.xml` file to override the
    // /// default FCM channel to enable heads up notifications.
    // await flutterLocalNotificationsPlugin
    //     .resolvePlatformSpecificImplementation<
    //         AndroidFlutterLocalNotificationsPlugin>()
    //     ?.createNotificationChannel(channel);

    // /// Requests & displays the current user permissions for this device.
    // NotificationSettings settings =
    //     await FirebaseMessaging.instance.requestPermission(
    //   announcement: true,
    //   carPlay: true,
    //   criticalAlert: true,
    // );
    // if (kDebugMode) {
    //   print('User granted permission: ${settings.authorizationStatus}');
    // }

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  //SchemaSensori(id: 0);
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<SchemaStatiModel>(
      create: (context) => SchemaStatiModel(id: 0),
    ),
    ChangeNotifierProvider<MainDrawerProvider>(
      create: (context) => MainDrawerProvider('assets/json/drawer_list.json'),
    ),
    ChangeNotifierProvider<SchemaSensoriModel>(
        //   create: (_) => SchemaSensori(id: 0),
        create: (context) => SchemaSensoriModel()),
    ChangeNotifierProvider<RemoteConnection>(
      create: (context) => RemoteConnection(),
    ),
    // ChangeNotifierProvider<TimerRepository>(
    //   create: (context) => TimerRepository(),
    // ),

    // nome: 'test sensori',
    // sensori: [
    //   SensoreInfisso(id: 1, nome: 'Sensore 1'),
    //   SensoreLuce(id: 2, nome: 'Sensore 2'),
    // ])),
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key) {
    mqttClientWrapper = MQTTClientWrapper();
    // if (mqttClientWrapper!.connectionState == MqttCurrentConnectionState.IDLE) {
    //   _connect();
    // }
    // mqttClientWrapper!.addListener(_connect, ['connectionState.disconnected']);
  }

  MQTTClientWrapper? mqttClientWrapper;

  void _connect() {
    mqttClientWrapper!.connectMqttClient();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Gestione Domotica',
        scrollBehavior: AppScrollBehavior(),
        theme: ThemeData(
            // Define the default brightness and colors.
            brightness: Brightness.light,
            primaryColor: Colors.brown[200],
            // textTheme: const TextTheme(bodyText2: TextStyle(color: Colors.black)),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.brown[100],
              //       // This will be applied to the "back" icon
              //       // iconTheme: IconThemeData(color: Colors.red),
              //       // This will be applied to the action icon buttons that locates on the right side
              actionsIconTheme: IconThemeData(color: Colors.white),
              //       centerTitle: false,
              //       //elevation: 15,
              //       titleTextStyle: TextStyle(color: Colors.lightBlueAccent)),
            )),
        home: HomePage());
    //connectionState() ? HomePage() : null
  }

  bool connectionState() {
    if (mqttClientWrapper == null ||
        mqttClientWrapper!.connectionState !=
            MqttCurrentConnectionState.CONNECTED) {
      return false;
    } else {
      return true;
    }
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
