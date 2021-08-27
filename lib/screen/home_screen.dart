import 'dart:async';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/subjects.dart';
import 'package:webcam_app/config/config.dart';
import 'package:webcam_app/database/dao/userDao.dart';
import 'package:webcam_app/database/model/user.dart';
import 'package:webcam_app/screen/clerk/clerk_login.dart';
import 'package:webcam_app/screen/component/button.dart';
import 'package:webcam_app/screen/component/counter.dart';
import 'package:webcam_app/screen/customer/customer_meet.dart';
import 'package:webcam_app/screen/customer/customer_photo_doc.dart';
import 'package:webcam_app/screen/customer/customer_register.dart';
import 'package:webcam_app/screen/customer/customer_options.dart';
import 'package:webcam_app/screen/customer/customer_photo.dart';
import 'package:webcam_app/utils/responsive_app.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:animations/animations.dart';

import 'component/home_screen_logo.dart';

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

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  Size size = ResponsiveApp().mq.size;
  late AnimationController _controller2;
  late AnimationController _controller;

  @override
  void initState() {
    _configureSelectNotificationSubject();
    _configureFirebaseMessage();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _controller2 = AnimationController(
      value: 0.0,
      duration: const Duration(milliseconds: 5000),
      reverseDuration: const Duration(milliseconds: 10000000000),
      vsync: this,
    )..addStatusListener((AnimationStatus status) {
        setState(() {
          // setState needs to be called to trigger a rebuild because
          // the 'HIDE FAB'/'SHOW FAB' button needs to be updated based
          // the latest value of [_controller.status].
        });
      });
    _controller = AnimationController(
      value: 0.0,
      duration: const Duration(milliseconds: 2000),
      reverseDuration: const Duration(milliseconds: 100000),
      vsync: this,
    )..addStatusListener((AnimationStatus status) {
        setState(() {
          // setState needs to be called to trigger a rebuild because
          // the 'HIDE FAB'/'SHOW FAB' button needs to be updated based
          // the latest value of [_controller.status].
        });
      });
    _controller.forward();
    _controller2.forward();
    checkIOSVersion();
    super.initState();
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _configureSelectNotificationSubject();
  //   _configureFirebaseMessage();
  // }

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
          body: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                  Color(0xFF780D0C7),
                  Color(0xFF74CACA),
                  Color(0xFF55BBD2),
                  Color(0xFF23A3E0),
                  Color(0xFF0099E9),
                ])),
            child: new Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: <Color>[
                                Color(0xFF7dcfc8),
                                Color(0xFF79ccc9),
                                Color(0xFF70c8cb),
                                Color(0xFF69c4cd),
                              ])),
                          child: FadeScaleTransition(
                            animation: _controller,
                            child: HomeScreenLogo(),
                          )),
                    ),
                    Expanded(
                        flex: 1,
                        child: FadeScaleTransition(
                          animation: _controller,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(color: Color(0xFF028da4)),
                            alignment: Alignment.center,
                            child: Text(
                              "視訊服務系統",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  letterSpacing: 6),
                            ),
                          ),
                        )),
                    Expanded(
                        flex: 6,
                        child: Container(
                          height: 400,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: <Color>[
                                Color(0xFF69c4cd),
                                Color(0xFF4db7d4),
                                Color(0xFF30a9dd),
                                Color(0xFF22a3e0),
                              ])),
                        )),
                  ],
                ),
                FadeScaleTransition(
                  animation: _controller2,
                  child: Container(
                    margin: EdgeInsets.only(left: 15, right: 15, bottom: 40),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30)),
                        border: Border.all(width: 2.0, color: Colors.white)),
                  ),
                ),
                Column(
                  children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.65,
                    ),
                    ScreenButton(
                      btnName: "貴賓專區",
                      onPressed: () async {
                        List<User> userList =
                            await UserDao.instance.readAllNotes();
                        userList.length > 0
                            ? Navigator.pushNamed(
                                context, CustomerOptionsScreen.routeName)
                            : Navigator.pushNamed(
                                context, CustomerRegisterScreen.routeName);
                      },
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    ScreenButton(
                      btnName: "行員登入",
                      onPressed: () => Navigator.pushNamed(
                          context, ClerkLoginScreen.routeName),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void checkIOSVersion() async {
    if (Platform.isIOS) {
      var iosInfo = await DeviceInfoPlugin().iosInfo;
      var systemName = iosInfo.systemName;
      var version = iosInfo.systemVersion;
      if (double.parse(version) < 14.3) {
        print("您當前的IOS版本為$version，系統最低需求為14.7，很抱歉無法提供使用");
        _showMyDialog("系統需求偵測通知", "您當前的IOS版本為$version，系統最低需求為14.7，很抱歉無法提供使用");
      }
    }
  }

  Future<void> _showMyDialog(String title, String content) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(content),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('了解'),
              onPressed: () {
                exit(0);
              },
            ),
          ],
        );
      },
    );
  }

  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String? payload) async {
      await updateUrl(payload!);
      print(payload);
      Navigator.pushNamed(context, CustomerPhotoScreen.routeName,
          arguments: CustomerPhotoArguments(payload));
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
            payload: message.data['agentId']);
      }
      print("recieve notification");
    });

    // 背景監聽消息
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("在背景執行時收到訊息");
      String agentId = message.data['agentId'];
      updateUrl(Config.WEBRTC_URL + '&agentid=$agentId');
      Navigator.pushNamed(context, CustomerPhotoScreen.routeName,
          arguments: CustomerPhotoArguments(agentId));
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
