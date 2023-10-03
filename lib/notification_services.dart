

import 'dart:math';

import 'package:eduapp/activities/routine_list.dart';
import 'package:eduapp/activities/routine_list.dart';
import 'package:eduapp/activities/routine_list.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'activities/calender_list.dart';

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  void subscribe () async
  {
    await messaging.subscribeToTopic('mytopic');
    print('Done');
  }
  void requestNotificationPermission()async{
    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true
    );

    if(settings.authorizationStatus == AuthorizationStatus.authorized){
      print("User granted");
    }else if(settings.authorizationStatus == AuthorizationStatus.provisional){
      print("User provisional granted");
    }else{
      print("User denied");
    }
  }
  void initLocalNotifications(BuildContext context, RemoteMessage message)async{
    var androidInitializationSettings = const AndroidInitializationSettings('@drawable/ic_launcher');
    var iosInitialization = const DarwinInitializationSettings();
    var initializationSetting = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitialization,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSetting,
      onDidReceiveNotificationResponse: (payload){
        Route route = MaterialPageRoute(builder: (context) => Routine());
        Navigator.push(context, route);
      }
    );
  }
  void firebaseInit(BuildContext context){
    FirebaseMessaging.instance.getInitialMessage().then((message){
      initLocalNotifications(context, message!);
      showNotification(message);

    });


    FirebaseMessaging.onMessage.listen((message) {
      if (kDebugMode) {
        print(message.notification!.title.toString());
        print(message.notification!.body.toString());
      }
      initLocalNotifications(context, message);
      showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      initLocalNotifications(context, message);
      showNotification(message);
    });
  }

  Future<void> showNotification(RemoteMessage message)async{

    AndroidNotificationChannel channel = AndroidNotificationChannel(
        Random.secure().nextInt(100000).toString(),
        'High Importance Notification',
        importance: Importance.max,
    );

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        channel.id.toString(),
        channel.name.toString(),
        channelDescription: 'your channel description',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'ticker'
        );

    const DarwinNotificationDetails darwinNotificationDetails =  DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails
    );

    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
          0,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          notificationDetails);
    });
  }

  Future<String> getDeviceToken()async{
    String? token = await messaging.getToken();
    return token!;
  }

  void isTokenRefresh()async{
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      print("refresh");
    });
  }


}