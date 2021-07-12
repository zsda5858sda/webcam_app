import 'package:flutter/material.dart';
import 'package:webcam_app/screen/component/button.dart';
import 'package:webcam_app/screen/customer/customer_meet.dart';

class CustomerScreen extends StatefulWidget {
  @override
  _CustomerScreen createState() => new _CustomerScreen();
}

class _CustomerScreen extends State<CustomerScreen> {
  final myController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
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
                height: size.height * 0.1,
              ),
              // Container(
              //   child: Image.asset("assets/images/ubLogo.png"),
              // ),
              SizedBox(
                height: size.height * 0.07,
              ),
              Container(
                width: size.width * 0.8,
                child: TextField(
                  controller: myController,
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
                  controller: myController,
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
              ScreenButton(btnName: '註冊', webView: () {})
              // ScreenButton(
              //   btnName: "註冊",
              //   webView: () async {
              //     dynamic data = [myController.text];
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) {
              //           return CustomerPage(data);
              //         },
              //       ),
              //     );
              //   },
              // )
            ],
          ),
        ) /* add child content here */,
      ),
    );
  }
}
