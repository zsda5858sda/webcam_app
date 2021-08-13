import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    Key? key,
    required this.size,
  }) : super(key: key);

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(left: 15, right: 15),
        height: size.height * 0.15,
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30))),
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                  top: size.height * 0.08, left: 30, right: 30),
              child: Image(
                  image: AssetImage("assets/images/UB_LOGO_C.png")),
            )
          ],
        ));
  }
}