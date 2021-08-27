import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webcam_app/database/dao/userDao.dart';
import 'package:webcam_app/database/model/user.dart';
import 'package:webcam_app/screen/component/banner_pic.dart';
import 'package:webcam_app/screen/component/custom_appbar.dart';
import 'package:webcam_app/screen/component/input_box.dart';
import 'package:webcam_app/screen/component/request_btn.dart';
import 'package:webcam_app/utils/responsive_app.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'package:webcam_app/utils/show_dialog_alert.dart';

import 'customer_photo.dart';

final List<String> imgList = [
  'assets/images/ＡＤ-1.png',
  'assets/images/ＡＤ-2.png',
  'assets/images/ＡＤ-3.png',
];

class CustomerOptionsScreen extends StatefulWidget {
  const CustomerOptionsScreen({Key? key}) : super(key: key);
  static const routeName = '/customer';
  @override
  _CustomerOptionsScreen createState() => _CustomerOptionsScreen();
}

class _CustomerOptionsScreen extends State<CustomerOptionsScreen> {
  final idController = TextEditingController();

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
                                          showText: true,
                                          HintText: "請輸入行員ID",
                                          size: size,
                                          idController: idController),
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
                                          createFile(agentId +
                                              '-' +
                                              userList.first.id +
                                              "-location" +
                                              '.txt');
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
                                                arguments: CustomerPhotoArguments(agentId));
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
                                          onPress: () {}),
                                      SizedBox(
                                        height: size.height * 0.03,
                                      ),
                                      RequestBtn(
                                        size: size,
                                        btnName: '上傳檔案',
                                        onPress: () {},
                                      ),
                                      SizedBox(
                                        height: size.height * 0.03,
                                      ),
                                      RequestBtn(
                                        size: size,
                                        btnName: '上傳檔案',
                                        onPress: () {},
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
}

Future createFile(String fileName) async {
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
  await http.post(
    Uri.parse("http://172.20.10.10:8080/uploadTxt" +
        "?content=$position&fileName=$fileName"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8'
    },
  );
}
