// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:hb_check_code/hb_check_code.dart';

class HBCodeWidget extends StatelessWidget {
  const HBCodeWidget({
    Key? key,
    required this.size,
    required this.hbCodeController, 
    required this.code,
  }) : super(key: key);

  final Size size;
  final TextEditingController hbCodeController;
  final String code;

  @override
  Widget build(BuildContext context) {
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
            controller: hbCodeController,
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
