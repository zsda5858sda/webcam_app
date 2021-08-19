import 'dart:convert';

import 'package:dart_ipify/dart_ipify.dart';
import 'package:http/http.dart' as http;
import 'package:webcam_app/config/config.dart';
import 'package:webcam_app/database/dao/clerkDAO.dart';
import 'package:webcam_app/database/model/clerk.dart';

class HttpUtils {
  Future<String> sendLog(String uid, String action, String userType) async {
    var result;
    // var ip = await Ipify.ipv4();
    var ip = "0.0.0.0";
    await http.post(Uri.parse(Config.LOG), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8'
    }, body: """
    {
      "userId": "$uid",
      "userType": $userType,
      "action": "$action",
      "ip": "$ip"
    }
    """).then((response) {
      var responseJson = json.decode(response.body);
      result = responseJson["message"];
      print(responseJson);
      if (responseJson["code"] == "1") {
        throw Exception(responseJson["message"]);
      }
    });
    return result;
  }

  Future<String> login(String uid, String password) async {
    var result;
    if (uid.isEmpty || password.isEmpty) {
      throw Exception("|請輸入帳號密碼");
    }

    ClerkDao clerkDao = ClerkDao.instance;
    List<Clerk> clerkList = await clerkDao.readAllNotes();
    if (clerkList.length > 0) clerkDao.delete();
    clerkDao.insert(Clerk(account: uid, password: password));

    await http.post(
      Uri.parse(Config.LOGIN),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: """
    {
      "loginId": "$uid",
      "loginP_ss": "$password"
    }
    """,
    ).then((response) {
      var responseJson = json.decode(response.body);
      result = responseJson["message"];
      print(responseJson);
      if (responseJson["code"] == "1") {
        throw Exception("|帳號或密碼錯誤");
      }
    });
    return result;
  }

  Future<String> register(String cid, String phone, String token) async {
    var result;
    await http.post(
      Uri.parse(Config.CUSTOMER),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
      body: """
      {
        "customerPhone": "$phone",
        "customerId": "$cid",
        "token": "$token"
      }
      """,
    ).then((response) {
      var responseJson = json.decode(response.body);
      result = responseJson["message"];
      print(responseJson);
      if (responseJson["code"] == 1) {
        throw new Exception(result);
      }
    });
    return result;
  }

  Future<dynamic> getToken(String customerPhone) async {
    var result;
    await http
        .get(
      Uri.parse(Config.CUSTOMER_TOKEN + "?customerPhone=$customerPhone"),
    )
        .then((response) {
      var responseJson = json.decode(response.body);
      result = responseJson;
      print(responseJson);
      if (responseJson["code"] == 1) {
        throw new Exception(result["message"]);
      }
    });
    return result;
  }
}
