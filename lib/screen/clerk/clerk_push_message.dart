import 'package:flutter/material.dart';
import 'package:webcam_app/screen/component/app_bar.dart';
import 'package:webcam_app/database/dao/clerkDao.dart';
import 'package:webcam_app/database/model/clerk.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:webcam_app/screen/component/app_bar.dart';
import 'package:webcam_app/database/dao/clerkDao.dart';
import 'package:webcam_app/database/model/clerk.dart';
import 'package:webcam_app/screen/component/button.dart';
import 'package:webcam_app/screen/customer/customer_meet.dart';
import 'package:webcam_app/utils/fcm_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webcam_app/utils/response_app.dart';

FlutterUploader _uploader = FlutterUploader();
var uploadUrl = "https://vsid.ubt.ubot.com.tw:81/main/Login.html";
class ClerkPushMessageScreen extends StatelessWidget {
  static final String routeName = '/pushmessage';
  final TextEditingController phoneController = TextEditingController();
  final Size size = ResponsiveApp().mq.size;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: homeAppBar(),
      body: Wrap(
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
                      controller: phoneController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: '請輸入客戶電話號碼',
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
                  ScreenButton(
                      btnName: '發送推播',
                      onPressed: () async {
                        String token = '';
                        String phone = phoneController.text;
                        final DocumentReference document = FirebaseFirestore
                            .instance
                            .collection("users")
                            .doc(phone);
                        await document
                            .get()
                            .then<dynamic>((DocumentSnapshot snapshot) async {
                          Map<String, dynamic> data =
                              snapshot.data() as Map<String, dynamic>;
                          token = data['token'];
                        });
                        List<Clerk> clerk =
                            await ClerkDao.instance.readAllNotes();
                        FCMService.sendToCustomer(token, clerk.first.account);
                      }),
                  SizedBox(
                    height: size.height * 0.07,
                  ),
                  ScreenButton(
                    btnName: '進行視訊',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CustomerWebRTC(
                              uploader: _uploader, uploadURL: Uri.parse(uploadUrl))),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
