import 'package:flutter/material.dart';
import 'package:webcam_app/screen/user_screen.dart';

import 'app_bar.dart';

class LoginScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homeAppBar(context),
      body: UserScreen(),
    );
  }
}