import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:webcam_app/database/dao/userDao.dart';
import 'package:webcam_app/database/model/user.dart';
import 'package:webcam_app/screen/clerk/clerk_login.dart';
import 'package:webcam_app/screen/component/app_bar.dart';
import 'package:webcam_app/screen/component/button.dart';
import 'package:webcam_app/screen/customer/customer_meet.dart';
import 'package:webcam_app/screen/customer/customer_photo_doc.dart';
import 'package:webcam_app/screen/customer/customer_register.dart';
import 'package:webcam_app/screen/customer/customer_options.dart';
import 'package:webcam_app/screen/customer/customer_photo.dart';
import 'package:webcam_app/utils/response_app.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final BehaviorSubject<String?> selectNotificationSubject =
    BehaviorSubject<String?>();

class HomeScreen extends StatefulWidget {
  const HomeScreen(
      {Key? key, this.flutterLocalNotificationsPlugin, this.channel})
      : super(key: key);
  final flutterLocalNotificationsPlugin;
  final channel;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _configureSelectNotificationSubject();
    _configureFirebaseMessage();
  }

  @override
  void dispose() {
    selectNotificationSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      ResponsiveApp.setMq(context);
      return WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
          appBar: homeAppBar(),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 100,
                ),
                ScreenButton(
                  btnName: "客戶端",
                  onPressed: () async {
                    List<User> userList = await UserDao.instance.readAllNotes();
                    userList.length > 0
                        ? Navigator.pushNamed(
                            context, CustomerOptionsScreen.routeName)
                        : Navigator.pushNamed(
                            context, CustomerRegisterScreen.routeName);
                    // final userDao = UserDao.instance;
                    // final url = (await userDao.readAllNotes()).first.webviewUrl;
                    // Navigator.pushNamed(context, CustomerWebRTC.routeName,
                    //     arguments: {"url": url});
                  },
                ),
                SizedBox(
                  height: 50,
                ),
                ScreenButton(
                  btnName: "行員端",
                  onPressed: () =>
                      Navigator.pushNamed(context, ClerkLoginScreen.routeName),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String? payload) async {
      await updateUrl(payload!);
      Navigator.pushNamed(context, CustomerPhotoScreen.routeName);
    });
  }

  void _configureFirebaseMessage() {
    final flutterLocalNotificationsPlugin =
        widget.flutterLocalNotificationsPlugin;
    final channel = widget.channel;
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
      updateUrl(message.data['url']);
      Navigator.pushNamed(context, CustomerPhotoScreen.routeName);
    });
  }

  Future<void> updateUrl(String payload) async {
    var userDao = UserDao.instance;
    Map<String, Object> userJson =
        (await userDao.readAllNotes()).first.toJson();

    userJson.update("webviewUrl", (value) => payload);
    User user = User.fromJson(userJson);
    await userDao.update(user);
  }
}
