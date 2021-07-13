import 'package:flutter/material.dart';
import 'package:webcam_app/screen/clerk/clerk_login.dart';
import 'package:webcam_app/screen/customer/customer_login.dart';
import 'clerk/admin_screen.dart';
import 'component/button.dart';

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 100,
          ),
          ScreenButton(
            btnName: "客戶登入",
            onPressed: () {
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
            onPressed: () async {
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
