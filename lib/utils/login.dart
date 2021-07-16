import 'package:http/http.dart' as http;
import 'package:webcam_app/database/dao/clerkDAO.dart';
import 'package:webcam_app/database/model/clerk.dart';

String serveraddress = "vsid.ubt.ubot.com.tw:81";

Future<void> login(String uid, String password) async {
  String encodePassword = Uri.encodeComponent(password);
  String url = 'https://$serveraddress/getAD?user=$uid&pwd=$encodePassword';
  if (uid.isEmpty || password.isEmpty) {
    throw Exception("|請輸入帳號密碼");
  }

  ClerkDao clerkDao = ClerkDao.instance;
  List<Clerk> clerkList = await clerkDao.readAllNotes();
  if (clerkList.length > 0) clerkDao.delete();
  clerkDao.insert(Clerk(account: uid, password: password));

  await http.get(
    Uri.parse(url),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8'
    },
  ).then((response) {
    if (!response.body.contains("success")) throw Exception("|帳號或密碼錯誤");
  });
}
