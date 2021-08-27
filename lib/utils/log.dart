import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:webcam_app/config/config.dart';

Future<void> log(String uid, String userType, String action, String IP) async {
  await http
      .post(Uri.parse(Config.LOG),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8'
          },
          body: jsonEncode(<String, String>{
            'userId': uid,
            'userType': userType,
            'action': action,
            'ip': IP
          }))
      .then((response) {
    print(response.statusCode);
    print(response.body);
  });
}
