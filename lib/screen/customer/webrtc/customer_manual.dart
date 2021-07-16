import 'package:flutter/material.dart';
import 'package:webcam_app/database/dao/userDao.dart';
import 'package:webcam_app/database/model/user.dart';
import 'package:webcam_app/screen/component/app_bar.dart';
import 'package:webcam_app/screen/component/button.dart';
import 'package:webcam_app/screen/customer/photo/customer_photo.dart';
import 'package:webcam_app/utils/response_app.dart';

class CustomerMaunalScreen extends StatelessWidget {
  static const String routeName = '/maunal';
  @override
  Widget build(BuildContext context) {
    Size size = ResponsiveApp().mq.size;
    final idController = TextEditingController();
    return Scaffold(
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
                        height: size.height * 0.2,
                      ),
                      Container(
                        width: size.width * 0.8,
                        child: TextField(
                          controller: idController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            hintText: '請輸入行員ID',
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
                      ScreenButton(
                          btnName: '下一步',
                          onPressed: () async {
                            String agentId = idController.text;
                            String url =
                                "https://vsid.ubt.ubot.com.tw:81/main/client/index.html?openExternalBrowser=1&agentid=$agentId";
                            var userDao = UserDao.instance;
                            Map<String, Object> userJson =
                                (await userDao.readAllNotes()).first.toJson();
                            
                            userJson.update("webviewUrl", (value) => url);
                            User user = User.fromJson(userJson);
                            await userDao.update(user);

                            Navigator.pushNamed(
                                context, CustomerPhotoScreen.routeName);
                          })
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
