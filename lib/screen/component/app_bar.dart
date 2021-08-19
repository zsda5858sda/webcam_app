import 'package:flutter/material.dart';
import 'package:webcam_app/utils/responsive_app.dart';

AppBar homeAppBar() {
  Size size = ResponsiveApp().mq.size;
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    title: Image.asset(
      "assets/images/logo2.png",
      width: size.width * 0.7,
      fit: BoxFit.cover,
    ),
    centerTitle: true,
  );
}
