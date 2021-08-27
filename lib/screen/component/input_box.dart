import 'package:flutter/material.dart';
import 'package:flutter_js/flutter_js.dart';

class InputBox extends StatelessWidget {
  const InputBox(
      {Key? key,
      required this.size,
      required this.idController,
      required this.HintText,
      required this.showText,
      required this.isCorrect,
      required this.verify})
      : super(key: key);

  final Size size;
  final TextEditingController idController;
  final String HintText;
  final bool showText;
  final Function verify;
  final bool isCorrect;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          debugPrint("djbjdsfjdbfmbdsj");
        },
        child: Container(
            margin: EdgeInsets.only(left: 50, right: 50),
            height: size.height * 0.05,
            decoration: BoxDecoration(
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.grey.withOpacity(0.5),
                //     spreadRadius: 2,
                //     blurRadius: 2,
                //     offset: Offset.zero, // changes position of shadow
                //   ),
                // ],
                ),
            child: Center(
              child: TextField(
                onTap: () {
                  verify();
                },
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
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: isCorrect ? Colors.black : Colors.red,
                          width: isCorrect ? 0.0 : 2.0),
                      borderRadius: BorderRadius.all(
                        const Radius.circular(10.0),
                      )),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                    const Radius.circular(10.0),
                  )),
                ),
              ),
            )));
  }
}
