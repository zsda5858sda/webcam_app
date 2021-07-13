import 'package:flutter/material.dart';
import 'package:webcam_app/screen/component/button.dart';

class MessagePushing extends StatefulWidget {
  const MessagePushing({Key? key}) : super(key: key);

  @override
  _MessagePushingState createState() => _MessagePushingState();
}

final idController = TextEditingController();
final phoneController = TextEditingController();

class _MessagePushingState extends State<MessagePushing> {
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
                        hintText: '請輸入客戶電話號碼',
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
                  ScreenButton(btnName: '發送推波', webView: () {}),
                  SizedBox(
                    height: size.height * 0.07,
                  ),
                  ScreenButton(btnName: '進行視訊', webView: () {})
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
