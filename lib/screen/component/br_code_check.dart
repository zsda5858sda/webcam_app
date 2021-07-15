import 'dart:math';

import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:hb_check_code/hb_check_code.dart';

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
    final String code = randomAlpha(5);
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
