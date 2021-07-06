import 'package:flutter/material.dart';
import 'package:webcam_app/screen/image_upload.dart';

import 'app_bar.dart';
import 'body.dart';


class HomeScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homeAppBar(context),
      body: Body(),
    );
  }
}

