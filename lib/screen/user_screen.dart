import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:webcam_app/screen/user_meet.dart';
import 'admin_screen.dart';
import 'button.dart';

class UserScreen extends StatefulWidget {
  @override
  _UserScreen createState() => new _UserScreen();
}

class _UserScreen extends State<UserScreen> {
  final myController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: new Center(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: size.height * 0.1,
              ),
              // Container(
              //   child: Image.asset("assets/images/ubLogo.png"),
              // ),
              SizedBox(
                height: size.height * 0.07,
              ),
              Container(
                width: size.width * 0.8,
                child: TextField(
                  controller: myController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: '請輸入行員ID',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                      const Radius.circular(20.0),
                    )),
                  ),
                ),
              ),
              SizedBox(
                height: size.height * 0.07,
              ),
              ScreenButton(
                btnName: "進行視訊",
                webView: () async {
                  dynamic data = [myController.text];
                  WidgetsFlutterBinding.ensureInitialized();
                  await Permission.camera.request();
                  await Permission.microphone.request();

                  if (Platform.isAndroid) {
                    await AndroidInAppWebViewController
                        .setWebContentsDebuggingEnabled(true);
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return CustomerPage(data);
                      },
                    ),
                  );
                },
              )
            ],
          ),
        ) /* add child content here */,
      ),
    );
  }
}
