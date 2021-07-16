import 'package:flutter/material.dart';
import 'package:webcam_app/screen/component/button.dart';
import 'package:webcam_app/screen/customer/photo/customer_photo.dart';
import 'package:webcam_app/screen/customer/webrtc/customer_manual.dart';

class Body extends StatelessWidget {
  const Body({
    Key? key,
    required this.size,
  }) : super(key: key);

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Wrap(
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
                ScreenButton(
                    btnName: '對保',
                    onPressed: () {
                      Navigator.pushNamed(
                          context, CustomerMaunalScreen.routeName);
                    }),
                SizedBox(
                  height: size.height * 0.07,
                ),
                ScreenButton(btnName: '功能2', onPressed: () {}),
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
    );
  }
}
