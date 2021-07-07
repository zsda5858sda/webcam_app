import 'package:flutter/material.dart';
import 'package:webcam_app/screen/component/app_bar.dart';
import 'package:webcam_app/screen/body.dart';

class HomeScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homeAppBar(context),
      body: Body(),
    );
  }
}

