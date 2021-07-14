import 'dart:math';

import 'package:flutter/material.dart';
import 'package:webcam_app/screen/component/button.dart';
import 'package:webcam_app/screen/component/hb_widget.dart';
import 'package:webcam_app/utils/fcm_service.dart';
import 'package:webcam_app/utils/response_app.dart';
import 'package:webcam_app/utils/show_dialog_alert.dart';

class CustomerScreen extends StatefulWidget {
  @override
  _CustomerScreen createState() => new _CustomerScreen();
}

class _CustomerScreen extends State<CustomerScreen> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final hbCodeController = TextEditingController();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Size size = ResponsiveApp().mq.size;

  String code = '';
  @override
  void initState() {
    super.initState();
    code = getCode();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4.0,
      runSpacing: 8.0,
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
                      hintText: '請輸入身分證字號',
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
                    controller: phoneController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: '請輸入電話號碼',
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
                    btnName: '註冊',
                    onPressed: () async {
                      if (code == hbCodeController.text) {
                      } else {
                        showAlertDialog(context, "", "驗證碼錯誤");
                      }
                    })
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future addUser() async {
    final user = User(
      id: idController.text,
      phone: phoneController.text,
    );
    await UserDatabase.instance.create(user);
  String getCode() {
    String code = "";
    for (var i = 0; i < 6; i++) {
      code = code + Random().nextInt(9).toString();
    }
    return code;
  }
}
