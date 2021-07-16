import 'package:flutter/material.dart';
import 'package:webcam_app/screen/component/app_bar.dart';
import 'body.dart';

class ClerkLoginScreen extends StatelessWidget {
  static const String routeName = '/clerklogin';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: homeAppBar(),
      body: Body(),
    );
  }
}
