import 'package:flutter/material.dart';
import 'package:webcam_app/screen/component/app_bar.dart';
import 'package:webcam_app/screen/body.dart';
import 'package:webcam_app/utils/response_app.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen(
      {Key? key, this.flutterLocalNotificationsPlugin, this.channel})
      : super(key: key);
  final flutterLocalNotificationsPlugin;
  final channel;
  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      ResponsiveApp.setMq(context);
      return Scaffold(
        appBar: homeAppBar(),
        body: Body(
          flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
          channel: channel,
        ),
      );
    });
  }
}
