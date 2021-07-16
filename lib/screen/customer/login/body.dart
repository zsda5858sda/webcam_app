// ignore_for_file: import_of_legacy_library_into_null_safe
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:webcam_app/database/dao/userDao.dart';
import 'package:webcam_app/database/model/user.dart';
import 'package:webcam_app/screen/component/button.dart';
import 'package:webcam_app/screen/component/hb_widget.dart';
import 'package:webcam_app/screen/customer/options/customer_options.dart';
import 'package:webcam_app/utils/fcm_service.dart';
import 'package:webcam_app/utils/hbcode.dart';
import 'package:webcam_app/utils/response_app.dart';
import 'package:webcam_app/utils/show_dialog_alert.dart';

class Body extends StatefulWidget {
  @override
  _Body createState() => new _Body();
}

class _Body extends State<Body> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final hbCodeController = TextEditingController();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Size size = ResponsiveApp().mq.size;
  @override
  void initState() {
    super.initState();
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
                  ),
                  SizedBox(
                    height: size.height * 0.07,
                  ),
                  ScreenButton(
                      btnName: '註冊',
                      onPressed: () async {
                        if (HBCode.code == hbCodeController.text) {
                          String id = idController.text;
                          String phone = phoneController.text;
                          String? token = await FCMService.getToken();
                          addUserToFirestore(phone, token);
                          addUserToLocalDB(id, phone);
                          await showAlertDialog(context, "登入成功", "將跳轉至功能首頁");
                          Navigator.pushNamed(
                              context, CustomerOptionsScreen.routeName);
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

  void addUserToLocalDB(id, phone) {
    final user = User(
      id: id,
      phone: phone,
      webviewUrl: "",
    );
    UserDao.instance.insert(user);
  }

  void addUserToFirestore(phone, token) {
    DocumentReference<Map<String, dynamic>> users =
        FirebaseFirestore.instance.collection('users').doc(phone);
    users.set({"token": token});
  }
}
