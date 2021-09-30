import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:webcam_app/config/config.dart';
import 'package:webcam_app/database/dao/userDao.dart';
import 'package:webcam_app/database/model/user.dart';
import 'package:webcam_app/screen/component/banner_pic.dart';
import 'package:webcam_app/screen/component/custom_appbar.dart';
import 'package:webcam_app/screen/component/hb_widget.dart';
import 'package:webcam_app/screen/component/input_box.dart';
import 'package:webcam_app/screen/component/rich_text.dart';
import 'package:webcam_app/screen/customer/customer_options.dart';
import 'package:webcam_app/utils/fcm_service.dart';
import 'package:http/http.dart' as http;
import 'package:webcam_app/utils/hbcode.dart';
import 'package:webcam_app/utils/http_utils.dart';
import 'package:webcam_app/utils/responsive_app.dart';
import 'package:webcam_app/utils/show_dialog_alert.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:flutter_js/flutter_js.dart';

final List<String> imgList = [
  'assets/images/ＡＤ-1.png',
  'assets/images/ＡＤ-2.png',
  'assets/images/ＡＤ-3.png',
];

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
  final JavascriptRuntime jsRuntime = getJavascriptRuntime();

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  Size size = ResponsiveApp().mq.size;
  bool _validate = false;
  bool idFormat = false;
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    List<int> list = [1, 2, 3, 4, 5];
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new Scaffold(
          body: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                    Color(0xFF780D0C7),
                    Color(0xFF74CACA),
                    Color(0xFF55BBD2),
                    Color(0xFF23A3E0),
                    Color(0xFF0099E9),
                  ])),
              child: new Stack(
                children: <Widget>[
                  BannerPic(size: size, imgList: imgList),
                  CustomAppBar(size: size),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.only(left: 15, right: 15),
                          height: size.height * 0.37,
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30))),
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: size.height * 0.04,
                              ),
                              InputBox(
                                isCorrect: !idFormat,
                                showText: true,
                                size: size,
                                idController: idController,
                                HintText: "請輸入身分證",
                                verify: () {},
                              ),
                              Visibility(
                                child: SmallTitle(title: "證件格式錯誤"),
                                visible: idFormat,
                              ),
                              SizedBox(
                                height: size.height * 0.01,
                              ),
                              InputBox(
                                  isCorrect: true,
                                  size: size,
                                  idController: phoneController,
                                  HintText: "請輸入電話號碼",
                                  showText: true,
                                  verify: () async {
                                    String blocJs = await rootBundle
                                        .loadString("assets/js/ajv.js");
                                    String cId = idController.text;
                                    var asyncResult =
                                        await jsRuntime.evaluateAsync(
                                            blocJs + """ mixCheck("$cId")""");
                                    jsRuntime.executePendingJob();
                                    final promiseResolved = await jsRuntime
                                        .handlePromise(asyncResult);
                                    if (promiseResolved.stringResult
                                        .contains('"validateResult":true')) {
                                      print("身分證格式正確");
                                      setState(() {
                                        idFormat = false;
                                      });
                                    } else {
                                      print("身分證格式錯誤" +
                                          promiseResolved.stringResult);
                                      setState(() {
                                        idFormat = true;
                                      });
                                    }
                                  }),
                              SizedBox(
                                height: size.height * 0.01,
                              ),
                              SmallTitle(title: "驗證碼"),
                              HBCodeWidget(
                                size: size,
                                hbCodeController: hbCodeController,
                              ),
                              SizedBox(
                                height: size.height * 0.01,
                              ),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                    maxHeight: 60,
                                    minHeight: 40,
                                    minWidth: size.width * 0.68),
                                child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)),
                                        gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: <Color>[
                                              Color(0xFF80d0c7),
                                              Color(0xFF775caca),
                                              Color(0xFF5cbed0),
                                              Color(0xFF2ba6de),
                                              Color(0xFF0d9ce6),
                                              Color(0xFF0199e8),
                                            ])),
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.all(16.0),
                                        primary: Color(0xFF5991ae),
                                      ),
                                      onPressed: () async {
                                        if (HBCode.code ==
                                            hbCodeController.text) {
                                          String id =
                                              idController.text.toUpperCase();
                                          String phone = phoneController.text;
                                          String? token =
                                              await FCMService.getToken();
                                          try {
                                            if (id.isEmpty || phone.isEmpty) {
                                              throw new NullThrownError();
                                            }
                                            if (idFormat) {
                                              throw new Exception(["證件格式錯誤"]);
                                            }
                                            await register(id, phone, token);
                                            addUserToLocalDB(id, phone);
                                            await showAlertDialog(
                                                context, "註冊成功", "將跳轉至功能首頁");
                                            Navigator.pushNamed(
                                                context,
                                                CustomerOptionsScreen
                                                    .routeName);
                                          } on NullThrownError catch (_) {
                                            await showAlertDialog(
                                                context, "註冊失敗", "身分證或電話不能為空值");
                                          } on Exception catch (error) {
                                            await showAlertDialog(context,
                                                "註冊失敗", error.toString());
                                            HttpUtils().sendLog(
                                                id, error.toString(), "2");
                                          }
                                        } else {
                                          showAlertDialog(context, "", "驗證碼錯誤");
                                        }
                                      },
                                      child: Text(
                                        "註冊",
                                        style: TextStyle(
                                            color: Colors.white,
                                            letterSpacing: 20,
                                            fontSize: 20),
                                      ),
                                    )),
                              )
                            ],
                          )),
                    ],
                  )
                ],
              ))),
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

  Future<void> register(id, phone, token) async {
    String result = await HttpUtils().register(id, phone, token);
    await HttpUtils().sendLog(phone, result, "2");
  }
}
