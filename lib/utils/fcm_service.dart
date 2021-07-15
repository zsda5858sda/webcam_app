import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class FCMService {
  static String payload = '';

  static Future<String?> getToken() {
    return FirebaseMessaging.instance.getToken(
        vapidKey:
            'BOa5kaeCiN4BmjKzLsitUL6p2lMY3KJoJx2ksW2pMnEw61lDEAHdqGTSAYkoFGESIzJDtiOKsycj3JIrTUL-yh4');
  }

  static Future<void> sendToCustomer(String token) async {
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        //fcm server key
        'Authorization':
            'key=AAAAeQeiCcc:APA91bE-CQUwMHTm6_KXzQ7Q7Y2uEYIz7Cxdfz6nVPkZqIMmWO6Wk6F1UOCMiQ9c8n_O-rJqRVDKDeFWGXMJU2KiN5dSA9ZWXEiWFa4b3DVRWk6Sx6WDwha8IiGbjKz792OaybbIahBY'
      },
      body: constructFCMPayload(token),
    );
  }

  static String constructFCMPayload(String token) {
    return jsonEncode({
      'to': token,
      'data': {
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        'screen': '/customer'
      },
      'notification': {'title': '聯邦銀行對保通知', 'body': '點擊通知進入對保畫面'},
    });
  }
}
