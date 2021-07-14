import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:webcam_app/screen/clerk/clerk_login.dart';
import 'package:webcam_app/screen/customer/customer_login.dart';
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
                // TODO add a proper drawable resource to android, for now using
                //      one that already exists in example app.
                icon: 'launch_background',
              ),
            ));
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
            btnName: "客戶登入",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return LoginScreen();
                  },
                ),
              );
            },
          ),
          SizedBox(
            height: 50,
          ),
          ScreenButton(
            btnName: "行員登入",
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return ClerkLoginScreen();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
