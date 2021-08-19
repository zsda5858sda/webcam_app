import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:webcam_app/database/dao/clerkDao.dart';
import 'package:webcam_app/database/model/clerk.dart';
import 'package:webcam_app/screen/component/banner_pic.dart';
import 'package:webcam_app/screen/component/custom_appbar.dart';
import 'package:webcam_app/screen/component/hb_widget.dart';
import 'package:webcam_app/screen/component/input_box.dart';
import 'package:webcam_app/screen/component/request_btn.dart';
import 'package:webcam_app/screen/component/rich_text.dart';
import 'package:webcam_app/screen/customer/customer_photo.dart';
import 'package:webcam_app/utils/fcm_service.dart';
import 'package:webcam_app/utils/hbcode.dart';
import 'package:webcam_app/utils/http_utils.dart';
import 'package:webcam_app/utils/responsive_app.dart';
import 'package:webcam_app/utils/show_dialog_alert.dart';
import 'package:select_form_field/select_form_field.dart';

import 'admin_screen.dart';

final List<String> imgList = [
  'assets/images/ＡＤ-1.png',
  'assets/images/ＡＤ-2.png',
  'assets/images/ＡＤ-3.png',
];

final String webRtcUrl =
    "https://172.20.10.10:82/main/Svideocall2.html?agentid=";
// "https://172.20.10.10:82/main/Svideocall2.html?agentid=";

FlutterUploader _uploader = FlutterUploader();

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
  final phoneController = TextEditingController();
  Size size = ResponsiveApp().mq.size;
  bool isLogin = true;
  String? labelText;
  final List<Map<String, dynamic>> _items = [
    {
      'value': 900,
      'label': '消費金融部',
      'icon': Icon(Icons.stop),
    },
    {
      'value': 903,
      'label': '車輛貸款部',
      'icon': Icon(Icons.fiber_manual_record),
    },
    {
      'value': 905,
      'label': '保險代理部',
      'icon': Icon(Icons.fiber_manual_record),
    },
    {
      'value': 907,
      'label': '理財貸款部',
      'icon': Icon(Icons.fiber_manual_record),
    },
    {
      'value': 202,
      'label': '企業金融部',
      'icon': Icon(Icons.fiber_manual_record),
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int? _value;
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new Scaffold(
          body: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                    Color(0xFF7dcfc8),
                    Color(0xFF79ccc9),
                    Color(0xFF70c8cb),
                    Color(0xFF69c4cd),
                    Color(0xFF4db7d4),
                    Color(0xFF30a9dd),
                    Color(0xFF22a3e0),
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
                      Visibility(
                        visible: isLogin,
                        child: Container(
                            margin: EdgeInsets.only(left: 15, right: 15),
                            height: size.height * 0.37,
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30))),
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: size.height * 0.02,
                                ),
                                SmallTitle(title: "請輸入員工編號"),
                                InputBox(
                                    size: size,
                                    idController: idController,
                                    showText: true,
                                    HintText: "請輸入員工編號"),
                                SizedBox(
                                  height: size.height * 0.01,
                                ),
                                SmallTitle(title: "請輸入密碼"),
                                InputBox(
                                  size: size,
                                  idController: passwordController,
                                  HintText: "請輸入密碼",
                                  showText: false,
                                ),
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
                                      minHeight: 50.0,
                                      maxHeight: double.infinity,
                                      minWidth: size.width * 0.68),
                                  child: Container(
                                      height: 40,
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
                                      child: RequestBtn(
                                        size: size,
                                        btnName: "登入",
                                        onPress: () async {
                                          if (HBCode.code ==
                                              hbCodeController.text) {
                                            var uid = idController.text;
                                            var message;
                                            await HttpUtils()
                                                .login(uid,
                                                    passwordController.text)
                                                .then((String result) async {
                                              message = result;

                                              await showAlertDialog(
                                                  context, "登入成功", "將跳轉至推播頁面");
                                              setState(() {
                                                isLogin = !isLogin;
                                              });
                                            }).catchError((error) {
                                              String message = error
                                                  .toString()
                                                  .split("|")[1];
                                              showAlertDialog(
                                                  context, "登入失敗", message);
                                            });
                                            await HttpUtils()
                                                .sendLog(uid, message, "1");
                                          } else {
                                            await showAlertDialog(
                                                context, "登入失敗", "驗證碼錯誤");
                                            setState(() {});
                                          }
                                        },
                                      )),
                                )
                              ],
                            )),
                      ),
                      Visibility(
                        visible: !isLogin,
                        child: Container(
                            margin: EdgeInsets.only(left: 15, right: 15),
                            height: size.height * 0.37,
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30))),
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: size.height * 0.02,
                                ),
                                SmallTitle(title: "請輸入顧客電話號碼"),
                                InputBox(
                                    showText: true,
                                    size: size,
                                    idController: phoneController,
                                    HintText: "請輸入顧客電話號碼"),
                                SizedBox(
                                  height: size.height * 0.01,
                                ),
                                Container(
                                    height: 40,
                                    width: size.width * 0.6,
                                    child: SelectFormField(
                                      type: SelectFormFieldType
                                          .dropdown, // or can be dialog
                                      initialValue: 'circle',
                                      labelText:
                                          labelText == null ? "消費金融部" : null,
                                      items: _items,
                                      onChanged: (val) {
                                        setState(() {
                                          labelText = val;
                                          print(labelText);
                                        });
                                      },
                                      onSaved: (val) => print(val),
                                    )),
                                SizedBox(
                                  height: size.height * 0.04,
                                ),
                                RequestBtn(
                                  size: size,
                                  btnName: "發送推播",
                                  onPress: () async {
                                    String phone = phoneController.text;
                                    List<Clerk> clerk =
                                        await ClerkDao.instance.readAllNotes();
                                    try {
                                      var response =
                                          await HttpUtils().getToken(phone);
                                      String token = response["data"];
                                      String message = response["message"];
                                      HttpUtils().sendLog(
                                          clerk.first.account.toString(),
                                          message,
                                          "1");
                                      print(token);
                                      print(clerk.first.account.toString());
                                      print("---------------");
                                      FCMService.sendToCustomer(
                                          token, clerk.first.account);
                                      showAlertDialog(context, "推播成功", "已傳送通知");
                                    } on Exception catch (error) {
                                      await HttpUtils().sendLog(
                                          clerk.first.account.toString(),
                                          error.toString(),
                                          "1");
                                      showAlertDialog(
                                          context, "推播失敗", error.toString());
                                    }
                                  },
                                ),
                                SizedBox(
                                  height: size.height * 0.03,
                                ),
                                RequestBtn(
                                  size: size,
                                  btnName: "進行視訊",
                                  onPress: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ClerkWebRTC(
                                              deparment: labelText.toString(),
                                              agentId: "0000915",
                                              uploader: _uploader,
                                              uploadURL: uploadVideoUrl,
                                              webRtcUrl: Uri.parse(webRtcUrl +
                                                  idController.text),
                                            )),
                                  ),
                                )
                              ],
                            )),
                      )
                    ],
                  )
                ],
              ))),
    );
  }
}
