import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:webcam_app/screen/component/app_bar.dart';
import 'package:webcam_app/screen/body.dart';
import 'package:webcam_app/screen/customer/webrtc/customer_meet.dart';
import 'package:webcam_app/utils/response_app.dart';

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
  Widget build(BuildContext context) {
    _configureSelectNotificationSubject();
    return Builder(builder: (context) {
      ResponsiveApp.setMq(context);
      return Scaffold(
        appBar: homeAppBar(),
        body: Body(
          flutterLocalNotificationsPlugin:
              widget.flutterLocalNotificationsPlugin,
          channel: widget.channel,
        ),
      );
    });
  }

  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String? payload) async {
      await Navigator.pushNamed(context, CustomerWebRTC.routeName,
          arguments: {"url": payload});
    });
  }
}
