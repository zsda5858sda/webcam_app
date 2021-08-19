import 'package:flutter/material.dart';
import 'package:webcam_app/utils/hb_check_code.dart';
import 'package:webcam_app/utils/hbcode.dart';
import 'package:webcam_app/utils/responsive_app.dart';

class HBCodeWidget extends StatefulWidget {
  const HBCodeWidget(
      {Key? key, required this.size, required this.hbCodeController})
      : super(key: key);
  final Size size;
  final TextEditingController hbCodeController;
  @override
  _HBCodeWidgetState createState() => _HBCodeWidgetState();
}

class _HBCodeWidgetState extends State<HBCodeWidget> {
  @override
  void initState() {
    super.initState();
  }

  Size size = ResponsiveApp().mq.size;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          // onTap: () {
          //   setState(() {});
          // },
          child: Container(
            width: size.width * 0.28,
            height: size.height * 0.05,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(30))),
            child: new HBCheckCode(
              backgroundColor: Color(0xFFD1E9E3),
              code: HBCode.getCode(),
              dotCount: 30,
              width: widget.size.width * 0.3,
              height: widget.size.height * 0.06,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10))),
          width: size.width * 0.4,
          height: size.height * 0.05,
          child: TextField(
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.bottom,
            controller: widget.hbCodeController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: '請輸入驗證碼',
              hintStyle: TextStyle(color: Colors.grey, fontSize: 20),
              border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10))),
            ),
          ),
        ),
      ],
    );
  }
}
