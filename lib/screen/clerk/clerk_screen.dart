import 'package:flutter/material.dart';
import 'package:hb_check_code/hb_check_code.dart';
import 'package:random_string/random_string.dart';
import 'package:webcam_app/db/users_database.dart';
import 'package:webcam_app/model/user.dart';
import 'package:webcam_app/screen/clerk/message_screen.dart';
import 'package:webcam_app/screen/component/br_code_check.dart';
import 'package:webcam_app/screen/component/button.dart';

class ClerkScreen extends StatefulWidget {
  @override
  _ClerkScreen createState() => new _ClerkScreen();
}

class _ClerkScreen extends State<ClerkScreen> {
  final idController = TextEditingController();
  final phoneController = TextEditingController();
  final code = randomAlpha(5);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
                      controller: phoneController,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child: HBCheckCode(
                          backgroundColor: Color(0xFFCCEEF7),
                          code: code,
                          dotCount: 20,
                          width: size.width * 0.3,
                          height: size.height * 0.06,
                        ),
                      ),
                      Container(
                        width: size.width * 0.3,
                        height: size.height * 0.06,
                        child: TextField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: '請輸入驗證碼',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                              const Radius.circular(0),
                            )),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.height * 0.07,
                  ),
                  ScreenButton(
                      btnName: '登入',
                      onPressed: () async {
                        addUser();
                      })
                ],
              ),
            ),
          ),
        ],
      ),
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
