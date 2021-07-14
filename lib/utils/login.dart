import 'package:http/http.dart' as http;

String serveraddress = "vsid.ubt.ubot.com.tw:81";

Future<void> login(String uid, String password) async {
  String encodePassword = Uri.encodeComponent(password);
  String url = 'https://$serveraddress/getAD?user=$uid&pwd=$encodePassword';
  await http.get(
    Uri.parse(url),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8'
    },
  ).then((response) {
    if (!response.body.contains("success")) throw Exception("login error");
  });
}
