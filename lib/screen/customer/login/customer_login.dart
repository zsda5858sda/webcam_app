import 'package:flutter/material.dart';
import 'package:webcam_app/screen/component/app_bar.dart';
import 'package:webcam_app/screen/customer/login/body.dart';

class CustomerLoginScreen extends StatelessWidget {
  static const routeName = '/customerlogin';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: homeAppBar(),
      body: Body(),
    );
  }
}
