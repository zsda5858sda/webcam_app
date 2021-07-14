import 'dart:math';

import 'package:flutter/material.dart';
import 'package:webcam_app/screen/clerk/message_screen.dart';
import 'package:webcam_app/screen/component/hb_widget.dart';
import 'package:webcam_app/screen/component/button.dart';
import 'package:webcam_app/utils/login.dart';
import 'package:webcam_app/utils/response_app.dart';
import 'package:webcam_app/utils/show_dialog_alert.dart';

class ClerkScreen extends StatefulWidget {
  @override
  _ClerkScreen createState() => new _ClerkScreen();
}

class _ClerkScreen extends State<ClerkScreen> {
  final idController = TextEditingController();
  final passwordController = TextEditingController();
  final hbCodeController = TextEditingController();
  Size size = ResponsiveApp().mq.size;

  String code = '';
  @override
  void initState() {
    super.initState();
    code = getCode();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            height: size.height,
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
                    code: code,
                  ),
                  SizedBox(
                    height: size.height * 0.07,
                  ),
                  ScreenButton(
                      btnName: '登入',
                      onPressed: () async {
                        if (code == hbCodeController.text) {
                          await login(
                                  idController.text, passwordController.text)
                              .then((_) => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return MessageScreen();
                                      },
                                    ),
                                  ))
                              .catchError((error) {
                            showAlertDialog(context, "登入失敗", "帳號或密碼錯誤");
                          });
                        } else {
                          showAlertDialog(context, "", "驗證碼錯誤");
                        }
                      })
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String getCode() {
    String _code = "";
    for (var i = 0; i < 6; i++) {
      _code = _code + Random().nextInt(9).toString();
    }
    return _code;
  }
}
