import 'package:flutter/material.dart';
import 'package:webcam_app/screen/component/app_bar.dart';
import 'package:webcam_app/screen/clerk/clerk_push_message.dart';
import 'package:webcam_app/screen/component/hb_widget.dart';
import 'package:webcam_app/screen/component/button.dart';
import 'package:webcam_app/utils/hbcode.dart';
import 'package:webcam_app/utils/login.dart';
import 'package:webcam_app/utils/response_app.dart';
import 'package:webcam_app/utils/show_dialog_alert.dart';

class ClerkLoginScreen extends StatefulWidget {
  const ClerkLoginScreen({Key? key}) : super(key: key);
  static final String routeName = '/clerklogin';
  @override
  _ClerkLoginScreenState createState() => _ClerkLoginScreenState();
}

class _ClerkLoginScreenState extends State<ClerkLoginScreen> {
  final idController = TextEditingController();
  final passwordController = TextEditingController();
  final hbCodeController = TextEditingController();
  Size size = ResponsiveApp().mq.size;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: homeAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: size.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)),
                image: DecorationImage(
                  image: AssetImage("assets/images/background.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: new Center(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: size.height * 0.2,
                    ),
                    Container(
                      width: size.width * 0.8,
                      child: TextField(
                        controller: idController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: '請輸入員工編號',
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
                    Container(
                      width: size.width * 0.8,
                      child: TextField(
                        obscureText: true,
                        controller: passwordController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: '請輸入密碼',
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
                    HBCodeWidget(
                      size: size,
                      hbCodeController: hbCodeController,
                    ),
                    SizedBox(
                      height: size.height * 0.07,
                    ),
                    ScreenButton(
                        btnName: '登入',
                        onPressed: () async {
                          if (HBCode.code == hbCodeController.text) {
                            await login(
                                    idController.text, passwordController.text)
                                .then((_) async {
                              await showAlertDialog(
                                  context, "登入成功", "將跳轉至推播頁面");
                              Navigator.pushNamed(
                                  context, ClerkPushMessageScreen.routeName);
                            }).catchError((error) {
                              String message = error.toString().split("|")[1];
                              showAlertDialog(context, "登入失敗", message);
                            });
                          } else {
                            await showAlertDialog(context, "登入失敗", "驗證碼錯誤");
                            setState(() {});
                          }
                        })
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
