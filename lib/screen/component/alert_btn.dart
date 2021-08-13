import 'package:flutter/material.dart';

class AlertBtn extends StatelessWidget {
  const AlertBtn({
    Key? key,
    required this.size,
    required this.btnName,
    required this.onPress,
  }) : super(key: key);

  final Size size;
  final String btnName;
  final Function onPress;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
          maxHeight: 50, minHeight: 40, minWidth: size.width * 0.68),
      child: Container(
          height: 40,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Color(0xFFCCEEF7),
                    Color(0xFF0099E9),               
                  ])),
          child: TextButton(
            onPressed: () async {
              onPress();
            },
            child: Text(
              btnName,
              style: TextStyle(
                  color: Colors.white, letterSpacing: 20, fontSize: 20),
            ),
          )),
    );
  }
}
