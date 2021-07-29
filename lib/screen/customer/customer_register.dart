import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:webcam_app/screen/component/app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webcam_app/database/dao/userDao.dart';
import 'package:webcam_app/database/model/user.dart';
import 'package:webcam_app/screen/component/hb_widget.dart';
import 'package:webcam_app/screen/customer/customer_options.dart';
import 'package:webcam_app/utils/fcm_service.dart';
import 'package:webcam_app/utils/hbcode.dart';
import 'package:webcam_app/utils/response_app.dart';
import 'package:webcam_app/utils/show_dialog_alert.dart';

class CustomerRegisterScreen extends StatefulWidget {
  const CustomerRegisterScreen({Key? key}) : super(key: key);
  static const routeName = '/customerlogin';

  @override
  _CustomerRegisterScreenState createState() => _CustomerRegisterScreenState();
}

class _CustomerRegisterScreenState extends State<CustomerRegisterScreen> {
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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: homeAppBar(),
      body: Wrap(
        spacing: 4.0,
        runSpacing: 8.0,
        children: <Widget>[
          Column(
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
                        height: size.height * 0.15,
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
                              const Radius.circular(10.0),
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
                              const Radius.circular(10.0),
                            )),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.04,
                      ),
                      HBCodeWidget(
                        size: size,
                        hbCodeController: hbCodeController,
                      ),
                      SizedBox(
                        height: size.height * 0.26,
                      ),
                      ConstrainedBox(
                        constraints:
                            BoxConstraints.tightFor(width: 300, height: 50),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (HBCode.code == hbCodeController.text) {
                              String id = idController.text;
                              String phone = phoneController.text;
                              String? token = await FCMService.getToken();
                              addUserToFirestore(phone, token);
                              addUserToLocalDB(id, phone);
                              // subscribe to topic on each app start-up
                              await FirebaseMessaging.instance
                                  .subscribeToTopic('customer');
                              await showAlertDialog(
                                  context, "登入成功", "將跳轉至功能首頁");
                              Navigator.popAndPushNamed(
                                  context, CustomerOptionsScreen.routeName);
                            } else {
                              showAlertDialog(context, "", "驗證碼錯誤");
                            }
                          },
                          child: RichText(
                            text: TextSpan(
                                style: TextStyle(fontSize: 20), text: '註冊'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
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
