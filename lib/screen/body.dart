import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:webcam_app/screen/file_upload.dart';
import 'package:webcam_app/screen/user_login.dart';
import 'admin_screen.dart';
import 'user_login.dart';
import 'button.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 100,
          ),
          ScreenButton(
            btnName: "客戶登入",
            webView: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return FileUpload();
                  },
                ),
              );
            },
          ),
          SizedBox(
            height: 50,
          ),
          ScreenButton(
            btnName: "行員登入",
            webView: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return ClerkPage();
                  },
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
