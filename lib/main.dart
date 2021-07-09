import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webcam_app/screen/home_screen.dart';

final Uri uploadURL = Uri.parse(
  'https://vsid.ubt.ubot.com.tw:81/uploadpic',
);
FlutterUploader _uploader = FlutterUploader();

void backgroundHandler(BuildContext context) {
  WidgetsFlutterBinding.ensureInitialized();

  // Notice these instances belong to a forked isolate.
  var uploader = FlutterUploader();

  var notifications = FlutterLocalNotificationsPlugin();

  // Only show notifications for unprocessed uploads.
  SharedPreferences.getInstance().then((preferences) {
    var processed = preferences.getStringList('processed') ?? <String>[];

    if (Platform.isAndroid) {
      uploader.progress.listen((progress) {
        if (processed.contains(progress.taskId)) {
          return;
        }

        notifications.show(
          progress.taskId.hashCode,
          'FlutterUploader Example',
          'Upload in Progress',
          NotificationDetails(
            android: AndroidNotificationDetails(
              'FlutterUploader.Example',
              'FlutterUploader',
              'Installed when you activate the Flutter Uploader Example',
              progress: progress.progress ?? 0,
              icon: 'ic_upload',
              enableVibration: false,
              importance: Importance.low,
              showProgress: true,
              onlyAlertOnce: true,
              maxProgress: 100,
              channelShowBadge: false,
            ),
            iOS: IOSNotificationDetails(),
          ),
        );
      });
    }

    uploader.result.listen((result) {
      if (processed.contains(result.taskId)) {
        return;
      }

      processed.add(result.taskId);
      preferences.setStringList('processed', processed);

      notifications.cancel(result.taskId.hashCode);

      final successful = result.status == UploadTaskStatus.complete;
      alert(context);
      debugPrint(result.status.toString()+'15515');
      var title = 'Upload Complete';
      if (result.status == UploadTaskStatus.failed) {
        title = 'Upload Failed';
        alert(context);
      } else if (result.status == UploadTaskStatus.canceled) {
        title = 'Upload Canceled';
        alert(context);
      }

      notifications
          .show(
        result.taskId.hashCode,
        'FlutterUploader Example',
        title,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'FlutterUploader.Example',
            'FlutterUploader',
            'Installed when you activate the Flutter Uploader Example',
            icon: 'ic_upload',
            enableVibration: !successful,
            importance: result.status == UploadTaskStatus.failed
                ? Importance.high
                : Importance.min,
          ),
          iOS: IOSNotificationDetails(
            presentAlert: true,
          ),
        ),
      )
          .catchError((e, stack) {
        print('error while showing notification: $e, $stack');
      });
    });
  });
}

void alert(BuildContext context) {
  AlertDialog dialog = AlertDialog(
    backgroundColor: Colors.yellow,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(15)),
    ),
    content: Row(
      children: <Widget>[
        Icon(
          Icons.warning,
          color: Colors.red,
          size: 30,
        ),
        Padding(padding: EdgeInsets.only(right: 10)),
        Text(
          "This is a dialog.",
          style: TextStyle(
            color: Colors.red,
            fontSize: 30,
          ),
        ),
      ],
    ),
    actions: <Widget>[
      FlatButton(
        onPressed: () {
          Navigator.pop(context, true);
        },
        child: Text(
          "CLOSE",
          style: TextStyle(color: Colors.black),
        ),
      ),
    ],
  );

  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) => dialog,
  );

  //print("in alert()");
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
  await Permission.storage.request();

  _uploader.setBackgroundHandler(backgroundHandler);

  var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid =
      AndroidInitializationSettings('ic_upload');
  var initializationSettingsIOS = IOSInitializationSettings(
    requestSoundPermission: false,
    requestBadgePermission: false,
    requestAlertPermission: true,
    onDidReceiveLocalNotification:
        (int id, String? title, String? body, String? payload) async {},
  );
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: (payload) async {},
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '視訊系統',
      home: HomeScreen(),
    );
  }
}
