import 'package:flutter/material.dart';
import 'package:webcam_app/screen/component/app_bar.dart';
import 'package:webcam_app/screen/customer/options/body.dart';
import 'package:webcam_app/utils/response_app.dart';

class CustomerOptionsScreen extends StatelessWidget {
  const CustomerOptionsScreen({Key? key}) : super(key: key);
  static const routeName = '/customer';
  @override
  Widget build(BuildContext context) {
    Size size = ResponsiveApp().mq.size;
    return Scaffold(
      appBar: homeAppBar(),
      body: Body(size: size),
    );
  }
}
