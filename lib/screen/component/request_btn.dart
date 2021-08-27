import 'package:flutter/material.dart';

class RequestBtn extends StatelessWidget {
  const RequestBtn({
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
          height: size.height*0.055,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Color(0xFF780D0C7),
                    Color(0xFF74CACA),
                    Color(0xFF55BBD2),
                    Color(0xFF23A3E0),
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
