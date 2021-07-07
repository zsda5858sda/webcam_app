import 'package:flutter/material.dart';
import 'package:webcam_app/screen/user/file_upload.dart';
import 'clerk/admin_screen.dart';
import 'component/button.dart';

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
