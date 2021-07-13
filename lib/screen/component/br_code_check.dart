import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hb_check_code/hb_check_code.dart';
import 'package:webcam_app/screen/customer/customer_screen.dart';

class BrCodeCheck extends StatelessWidget {
  const BrCodeCheck({
    Key? key,
    required this.size,
    required this.phoneController,
  }) : super(key: key);

  final Size size;
  final TextEditingController phoneController;

  @override
  Widget build(BuildContext context) {
    String code = "";
    for (var i = 0; i < 6; i++) {
      code = code + Random().nextInt(9).toString();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          child: HBCheckCode(
            backgroundColor: Color(0xFFCCEEF7),
            code: code,
            dotCount: 20,
            width: size.width * 0.3,
            height: size.height * 0.06,
          ),
        ),
        Container(
          width: size.width * 0.3,
          height: size.height * 0.06,
          child: TextField(
            controller: phoneController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: '請輸入驗證碼',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                const Radius.circular(0),
              )),
            ),
          ),
        ),
      ],
    );
  }
}
