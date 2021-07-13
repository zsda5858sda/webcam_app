import 'package:flutter/material.dart';
import 'package:webcam_app/screen/customer/customer_login.dart';
import 'clerk/admin_screen.dart';
import 'component/button.dart';

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  // static const MethodChannel methodChannel =
  //     MethodChannel('flutter_screen_recording');

  // String _batteryLevel = 'Battery level: unknown.';
  // Future<void> _getBatteryLevel() async {
  //   String batteryLevel;
  //   try {
  //     final int? result = await methodChannel.invokeMethod('startRecordScreen');
  //     batteryLevel = 'Battery level: $result%.';
  //   } on PlatformException {
  //     batteryLevel = 'Failed to get battery level.';
  //   }
  //   setState(() {
  //     _batteryLevel = batteryLevel;
  //     print(_batteryLevel);
  //   });
  // }

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
                    return ClerkPage();
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
