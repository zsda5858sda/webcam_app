import 'package:flutter/material.dart';

class ResponsiveApp {
  static MediaQueryData _mediaQueryData = MediaQueryData();

  MediaQueryData get mq => _mediaQueryData;

  static void setMq(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
  }
}
