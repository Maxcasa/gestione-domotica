import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationSender {
  // costruttori
  static final NotificationSender _instance = NotificationSender._internal();

  factory NotificationSender() {
    return _instance;
  }

  // costruttori
  NotificationSender._internal() {
    const sound = 'domo_allarm';
    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel 2', // id
        'High Importance Notifications', // title
        description:
            'This channel is used for important notifications.', // description
        importance: Importance.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(sound),
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
        for (var element in onReceivedMessageActionList) {
          element(message);
        }
      }

      // if (message != null) {
      //   _controller.animateToPage(
      //     0,
      //     duration: _kDuration,
      //     curve: _kCurve,
      //   );
      // Navigator.pushNamed(
      //   context,
      //   '/message',
      //   arguments: MessageArguments(message, true),
      // );
      //}
    });

    FirebaseMessaging.instance.subscribeToTopic('fcm_test');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      sendMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      for (var element in onReceivedMessageActionList) {
        element(message);
      }
      // _controller.animateToPage(
      //   0,
      //   duration: _kDuration,
      //   curve: _kCurve,
      // );
      // Navigator.pushNamed(
      //   context,
      //   '/message',
      //   arguments: MessageArguments(message, true),
      // );
    });
  }

  void addReceivedMessageAction(
      Function(RemoteMessage) onReceivedMessageAction) {
    onReceivedMessageActionList.add(onReceivedMessageAction);
  }

  void sendMessage(RemoteMessage message) {
    Map<String, dynamic> messageData = message.data;
    //RemoteNotification? notification = message.notification;
    //AndroidNotification? androidNotification = message.notification?.android;
    if (messageData != null && !kIsWeb) {
      // _controller.animateToPage(
      //   0,
      //   duration: _kDuration,
      //   curve: _kCurve,
      // );

      // var generalNotificationDetails =
      //   NotificationDetails(android: androidDetails, iOS: iosDetails)

      // flutterLocalNotificationsPlugin.show(
      //   notification.hashCode, notification.title, notification.
      //   body, generalNotificationDetails);
      flutterLocalNotificationsPlugin.show(
        messageData.hashCode,
        messageData['title'],
        messageData['body'],
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            // TODO add a proper drawable resource to android, for now using
            //      one that already exists in example app.
            icon: '@mipmap/ic_launcher',
            playSound: channel.playSound,
            sound: channel.sound,
            // sound: notification.android.sound!,
          ),
        ),
      );
    }
  }

  List<Function(RemoteMessage)> onReceivedMessageActionList = [];

  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  /// Create a [AndroidNotificationChannel] for heads up notifications
  late AndroidNotificationChannel channel;
}
