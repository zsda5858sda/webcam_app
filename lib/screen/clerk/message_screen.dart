import 'package:flutter/material.dart';
import 'package:webcam_app/screen/clerk/message_push.dart';
import 'package:webcam_app/screen/component/app_bar.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: homeAppBar(),
      body: MessagePushing(),
    );
  }
}
