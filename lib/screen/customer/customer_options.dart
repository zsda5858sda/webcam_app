import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:provider/provider.dart';
import 'package:webcam_app/config/config.dart';
import 'package:webcam_app/database/dao/userDao.dart';
import 'package:webcam_app/database/model/user.dart';
import 'package:webcam_app/screen/component/banner_pic.dart';
import 'package:webcam_app/screen/component/counter.dart';
import 'package:webcam_app/screen/component/custom_appbar.dart';
import 'package:webcam_app/screen/component/input_box.dart';
import 'package:webcam_app/screen/component/request_btn.dart';
import 'package:webcam_app/screen/upload/image_upload.dart';
import 'package:webcam_app/screen/upload/responses_screen.dart';
import 'package:webcam_app/utils/responsive_app.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'package:webcam_app/utils/show_dialog_alert.dart';

import 'customer_photo.dart';

final List<String> imgList = [
  'assets/images/ＡＤ-1.png',
  'assets/images/ＡＤ-2.png',
  'assets/images/ＡＤ-3.png',
];
FlutterUploader _uploader = FlutterUploader();

class CustomerOptionsScreen extends StatefulWidget {
  const CustomerOptionsScreen({Key? key}) : super(key: key);
  static const routeName = '/customer';
  @override
  _CustomerOptionsScreen createState() => _CustomerOptionsScreen();
}

class _CustomerOptionsScreen extends State<CustomerOptionsScreen> {
  final idController = TextEditingController();
  final JavascriptRuntime jsRuntime = getJavascriptRuntime();
  Timer? _timer;
  late double _progress;

  var _jsResult;
  double percent = 0.0;

  bool isWebRtc = false;
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
    Size size = ResponsiveApp().mq.size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamed(context, '/');
        return false;
      },
      child: Scaffold(
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
                          width: size.width,
                          margin: EdgeInsets.only(left: 15, right: 15),
                          height: size.height * 0.37,
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30))),
                          child: Column(
                            children: <Widget>[
                              Visibility(
                                  visible: isWebRtc,
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: size.height * 0.1,
                                      ),
                                      InputBox(
                                        isCorrect: true,
                                        showText: true,
                                        HintText: "請輸入行員ID",
                                        size: size,
                                        idController: idController,
                                        verify: () {},
                                      ),
                                      SizedBox(height: size.height * 0.04),
                                      RequestBtn(
                                        size: size,
                                        btnName: "拍攝證件",
                                        onPress: () async {
                                          List<User> userList = await UserDao
                                              .instance
                                              .readAllNotes();
                                          print(userList.first.id);
                                          String agentId = idController.text;
                                          if (agentId == "") {
                                            showAlertDialog(
                                                context, "", "行員ID不能為空");
                                          } else {
                                            String url =
                                                "https://vsid.ubt.ubot.com.tw:81/main/client/index.html?openExternalBrowser=1&agentid=$agentId";
                                            var userDao = UserDao.instance;
                                            Map<String, Object> userJson =
                                                (await userDao.readAllNotes())
                                                    .first
                                                    .toJson();

                                            userJson.update(
                                                "webviewUrl", (value) => url);
                                            User user = User.fromJson(userJson);
                                            await userDao.update(user);

                                            Navigator.pushNamed(context,
                                                CustomerPhotoScreen.routeName,
                                                arguments:
                                                    CustomerPhotoArguments(
                                                        agentId));
                                          }
                                        },
                                      )
                                    ],
                                  )),
                              Visibility(
                                  visible: !isWebRtc,
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(
                                        height: size.height * 0.04,
                                      ),
                                      RequestBtn(
                                          size: size,
                                          btnName: "視訊對保",
                                          onPress: () {
                                            setState(() {
                                              isWebRtc = true;
                                            });
                                          }),
                                      SizedBox(
                                        height: size.height * 0.03,
                                      ),
                                      RequestBtn(
                                          size: size,
                                          btnName: '上傳檔案',
                                          onPress: () async {
                                            _showMyDialog(title);
                                          }),
                                      SizedBox(
                                        height: size.height * 0.03,
                                      ),
                                      RequestBtn(
                                          size: size,
                                          btnName: '上傳檔案',
                                          onPress: () {
                                            _uploader.clearUploads();
                                          }),
                                      SizedBox(
                                        height: size.height * 0.03,
                                      ),
                                      RequestBtn(
                                        size: size,
                                        btnName: '上傳檔案',
                                        onPress: () {
                                          _progress = 0;
                                          _timer?.cancel();
                                          _timer = Timer.periodic(
                                              const Duration(
                                                  milliseconds: 1000),
                                              (Timer timer) {
                                            _progress += 0.03;

                                            if (_progress >= 1) {
                                              _timer?.cancel();
                                              EasyLoading.dismiss();
                                            }
                                          });
                                        },
                                      )
                                    ],
                                  ))
                            ],
                          )),
                    ],
                  )
                ],
              ))),
    );
  }

  Future<String> addFromJs(
      JavascriptRuntime jsRuntime, String num1, String num2) async {
    String blocJs = await rootBundle.loadString("assets/js/bloc.js");
    final jsResult = jsRuntime.evaluate(blocJs + """ add($num1, $num2)""");
    final jsStringResult = jsResult.stringResult;
    return jsStringResult;
  }

  Future<void> _showMyDialog(String title) async {
    double count = 0;
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            var timer = Timer.periodic(Duration(seconds: 1), (timer) {
              setState(() {
                count = count + 0.1;
              });
            });
            if (count == 1) {
              timer.cancel();
            }
            return Visibility(
                visible: true,
                child: AlertDialog(
                  title: Text("Title of Dialog"),
                  content: LinearProgressIndicator(
                    value: count,
                    color: Colors.red,
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text("Change"),
                    ),
                  ],
                ));
          },
        );
      },
    );
  }

  Future<dynamic> evalJS(String id) async {
    String blocJs = await rootBundle.loadString("assets/js/ajv.js");
    final jsResult = jsRuntime.evaluateAsync(blocJs + """ finalCheck("$id")""");
    return jsResult;
  }
}
