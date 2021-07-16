import 'package:flutter/material.dart';
import 'package:webcam_app/screen/clerk/push_message/body.dart';
import 'package:webcam_app/screen/component/app_bar.dart';

class ClerkPushMessageScreen extends StatelessWidget {
  static final String routeName = '/pushmessage';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: homeAppBar(),
      body: Body(),
    );
  }
}
