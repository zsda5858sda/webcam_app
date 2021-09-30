import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webcam_app/screen/component/custom_appbar.dart';
import 'package:webcam_app/utils/http_utils.dart';
import 'package:webcam_app/utils/responsive_app.dart';

class ThanksScreen extends StatefulWidget {
  const ThanksScreen(
      {Key? key,
      required this.count,
      required this.userId,
      required this.agentId})
      : super(key: key);
  static const routeName = '/customerlogin';
  final int count;
  final String userId;
  final String agentId;
  @override
  _ThanksScreen createState() => _ThanksScreen();
}

class _ThanksScreen extends State<ThanksScreen> {
  Size size = ResponsiveApp().mq.size;
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    getTotalFileCount(widget.agentId);
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new Scaffold(
          body: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                    Color(0xFF780D0C7),
                    Color(0xFF74CACA),
                    Color(0xFF55BBD2),
                    Color(0xFF23A3E0),
                    Color(0xFF0099E9),
                  ])),
              child: new Stack(
                children: <Widget>[
                  CustomAppBar(size: size),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.only(left: 15, right: 15),
                          height: size.height * 0.8,
                          width: size.width * 0.95,
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30))),
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: size.height * 0.28,
                              ),
                              Text(
                                '感謝您使用',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Color(0xFF028da4),
                                    letterSpacing: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: size.height * 0.02,
                              ),
                              Text(
                                '聯邦視訊服務系統',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Color(0xFF028da4),
                                    letterSpacing: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: size.height * 0.02,
                              ),
                              Text(
                                '祝你有個美好的一天！',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Color(0xFF028da4),
                                    letterSpacing: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          )),
                    ],
                  )
                ],
              ))),
    );
  }

  Future getTotalFileCount(String fileName) async {
    var now = DateTime.now();
    var year = now.year.toString();
    var month =
        now.month < 10 ? "0" + now.month.toString() : now.month.toString();
    var day = now.day < 10 ? "0" + now.day.toString() : now.day.toString();
    var datetime = year + month + day;
    fileName = fileName +
        '-' +
        widget.userId +
        "-" +
        datetime +
        "-customerFileCount.txt";
    HttpUtils().createTxtFile(fileName, widget.count.toString());
  }
}
