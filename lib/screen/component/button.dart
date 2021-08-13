import 'package:flutter/material.dart';

class ScreenButton extends StatelessWidget {
  ScreenButton({
    Key? key,
    required this.btnName,
    required this.onPressed,
  }) : super(key: key);

  final String btnName;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFD5E8F2),
                    ),
                  ),
                ),
                SizedBox(
                  width: 200.0,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(16.0),
                      primary: Color(0xFF305E75),
                      textStyle: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      onPressed();
                    },
                    child: Text(btnName),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
