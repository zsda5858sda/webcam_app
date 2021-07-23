import 'package:flutter/material.dart';
import 'package:webcam_app/screen/upload/hb_check_code.dart';
import 'package:webcam_app/utils/hbcode.dart';

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

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Column(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {});
              },
              child: Container(
                child: new HBCheckCode(
                  backgroundColor: Color(0xFFD1E9E3),
                  code: HBCode.getCode(),
                  dotCount: 30,
                  width: widget.size.width * 0.4,
                  height: widget.size.height * 0.08,
                ),
              ),
            ),
            RichText(
                text: TextSpan(
                    style: TextStyle(color: Colors.grey[300]),
                    children: <TextSpan>[TextSpan(text: "（點擊驗證碼以進行刷新）")]))
          ],
        ),
        Container(
          width: widget.size.width * 0.3,
          height: widget.size.height * 0.06,
          child: TextField(
            controller: widget.hbCodeController,
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
