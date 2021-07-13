import 'package:flutter/material.dart';
import 'package:webcam_app/screen/component/app_bar.dart';
import 'clerk_screen.dart';

class ClerkLoginScreen extends StatelessWidget {
  const ClerkLoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: homeAppBar(context),
      body: ClerkScreen(),
    );
  }
}
