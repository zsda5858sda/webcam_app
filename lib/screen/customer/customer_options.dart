import 'package:flutter/material.dart';
import 'package:webcam_app/screen/component/app_bar.dart';
import 'package:webcam_app/screen/home_screen.dart';
import 'package:webcam_app/screen/upload/file_upload.dart';
import 'package:webcam_app/utils/response_app.dart';
import 'package:webcam_app/screen/component/button.dart';
import 'package:webcam_app/screen/customer/customer_manual.dart';

class CustomerOptionsScreen extends StatelessWidget {
  const CustomerOptionsScreen({Key? key}) : super(key: key);
  static const routeName = '/customer';
  @override
  Widget build(BuildContext context) {
    Size size = ResponsiveApp().mq.size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamed(context, '/');
        return false;
      },
      child: Scaffold(
        appBar: homeAppBar(),
        body: Wrap(
          spacing: 4.0,
          runSpacing: 8.0,
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
                    ScreenButton(
                        btnName: '對保',
                        onPressed: () {
                          Navigator.pushNamed(
                              context, CustomerMaunalScreen.routeName);
                        }),
                    SizedBox(
                      height: size.height * 0.07,
                    ),
                    ScreenButton(
                        btnName: '上傳檔案',
                        onPressed: () {
                          Navigator.pushNamed(context, fileUpload.routeName);
                        }),
                    SizedBox(
                      height: size.height * 0.07,
                    ),
                    ScreenButton(btnName: '功能3', onPressed: () {}),
                    SizedBox(
                      height: size.height * 0.07,
                    ),
                    ScreenButton(btnName: '功能4', onPressed: () {}),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
