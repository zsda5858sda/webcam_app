import 'dart:math';

import 'package:flutter/material.dart';
import 'package:webcam_app/db/users_database.dart';
import 'package:webcam_app/model/user.dart';
import 'package:webcam_app/screen/component/br_code_check.dart';
import 'package:webcam_app/screen/component/button.dart';

class CustomerScreen extends StatefulWidget {
  @override
  _CustomerScreen createState() => new _CustomerScreen();
}

class _CustomerScreen extends State<CustomerScreen> {
  final idController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
                BrCodeCheck(size: size, phoneController: phoneController),
                SizedBox(
                  height: size.height * 0.07,
                ),
                ScreenButton(
                    btnName: '註冊',
                    webView: () async {
                      addUser();
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
  }
}
