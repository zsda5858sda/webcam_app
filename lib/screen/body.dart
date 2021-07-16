import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:webcam_app/database/dao/userDao.dart';
import 'package:webcam_app/database/model/user.dart';
import 'component/button.dart';

class Body extends StatelessWidget {
  const Body({Key? key, this.flutterLocalNotificationsPlugin, this.channel})
      : super(key: key);
  final flutterLocalNotificationsPlugin;
  final channel;

  @override
  Widget build(BuildContext context) {
    // 監聽消息
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                icon: 'launch_background',
              ),
            ),
            payload: message.data['url']);
      }
    });

    // 背景監聽消息
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("在背景執行時收到訊息");
      Navigator.pushNamed(context, '/customer');
    });

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 100,
          ),
          ScreenButton(
            btnName: "客戶端",
            onPressed: () async {
              List<User> userList = await UserDao.instance.readAllNotes();
              if (userList.length > 0) {
                print('客戶已註冊');
              } else {
                Navigator.pushNamed(context, '/customer');
              }
            },
          ),
          SizedBox(
            height: 50,
          ),
          ScreenButton(
            onPressed: () => Navigator.pushNamed(context, '/clerk'),
            btnName: "行員端",
          ),
        ],
      ),
    );
  }
}
