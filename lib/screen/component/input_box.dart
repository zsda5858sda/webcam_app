import 'package:flutter/material.dart';

class InputBox extends StatelessWidget {
  const InputBox({
    Key? key,
    required this.size,
    required this.idController,
    required this.HintText, required this.showText,
  }) : super(key: key);

  final Size size;
  final TextEditingController idController;
  final String HintText;
  final bool showText ;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(left: 50, right: 50),
        height: size.height * 0.05,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 2,
              offset: Offset.zero, // changes position of shadow
            ),
          ],
        ),
        child: Center(
          child: TextField(
            enableSuggestions: false,
            autocorrect: false,
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.bottom,
            controller: idController,
            obscureText: !showText,
            decoration: InputDecoration(
              alignLabelWithHint: true,
              filled: true,
              fillColor: Colors.white,
              hintText: HintText,
              hintStyle: TextStyle(color: Colors.grey, fontSize: 20),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                const Radius.circular(10.0),
              )),
            ),
          ),
        ));
  }
}
