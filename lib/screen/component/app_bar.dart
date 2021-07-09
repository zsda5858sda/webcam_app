import 'package:flutter/material.dart';

AppBar homeAppBar(BuildContext context) {
  Size size = MediaQuery.of(context).size;
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    title: Image.asset(
      "assets/images/logo2.png",
      width: size.width * 0.7,
      fit: BoxFit.cover,
    ),
    centerTitle: true,
  );
}
