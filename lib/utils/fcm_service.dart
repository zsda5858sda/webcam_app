import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:webcam_app/config/config.dart';

class FCMService {
  static String payload = '';

  static Future<String?> getToken() {
    return FirebaseMessaging.instance.getToken(vapidKey: Config.FCM_VAPID_KEY);
  }

  static Future<void> sendToCustomer(String token, String agentId) async {
    await http.post(
      Uri.parse(Config.FCM_SEND),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        //fcm server key
        'Authorization': 'key=' + Config.FCM_SERVER_KEY
      },
      body: constructFCMPayload(token, agentId),
    );
  }

  static String constructFCMPayload(String token, String agentId) {
    return jsonEncode({
      'to': token,
      'data': {'url': Config.WEBRTC_URL + '&agentid=$agentId'},
      'notification': {'title': '聯邦銀行對保通知', 'body': '點擊通知進入對保畫面'},
    });
  }
}
