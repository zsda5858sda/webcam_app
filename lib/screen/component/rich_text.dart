import 'package:flutter/material.dart';

class SmallTitle extends StatelessWidget {
  const SmallTitle({
    Key? key, required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      margin: EdgeInsets.only(left: 60),
      child: RichText(
        text: TextSpan(
          text: title,
          style: TextStyle(
            color: Color(0xFF006697),
          ),
        ),
      ),
    );
  }
}
