import 'package:flutter/material.dart';
import 'package:webcam_app/screen/clerk/clerk_login.dart';
import 'package:webcam_app/screen/customer/customer_login.dart';
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
                    return LoginScreen();
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
                    return ClerkLoginScreen();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
