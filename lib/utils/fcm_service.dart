import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  String _token = '';

  FCMService() {
    FirebaseMessaging.instance
        .getToken(
            vapidKey:
                'BOa5kaeCiN4BmjKzLsitUL6p2lMY3KJoJx2ksW2pMnEw61lDEAHdqGTSAYkoFGESIzJDtiOKsycj3JIrTUL-yh4')
        .then((value) => setToken(value));
  }

  void setToken(String? token) {
    print('FCM Token: $token');
    _token = token!;
  }

  String getToken() {
    return _token;
  }
}
