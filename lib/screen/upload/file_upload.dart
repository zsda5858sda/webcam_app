// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:webcam_app/screen/component/app_bar.dart';
import 'package:webcam_app/screen/upload/responses_screen.dart';

import 'image_upload.dart';

const String title = 'FileUpload Sample app';
final Uri uploadURL = Uri.parse(
  'https://vsid.ubt.ubot.com.tw:81/uploadpic',
);

FlutterUploader _uploader = FlutterUploader();

void backgroundHandler() {
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

      var title = 'Upload Complete';
      if (result.status == UploadTaskStatus.failed) {
        title = 'Upload Failed';
      } else if (result.status == UploadTaskStatus.canceled) {
        title = 'Upload Canceled';
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

class fileUpload extends StatefulWidget {
  fileUpload({Key? key}) : super(key: key);

  @override
  _fileUpload createState() => _fileUpload();
}

class _fileUpload extends State<fileUpload> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    _uploader.setBackgroundHandler(backgroundHandler);

    var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('ic_upload');
    var initializationSettingsIOS = IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: true,
      // onDidReceiveLocalNotification:
      //     (int id, String title, String body, String payload) async {},
    );
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (payload) async {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF63BED0),
      body: _currentIndex == 0
          ? UploadScreen(
              uploader: _uploader,
              uploadURL: uploadURL,
              onUploadStarted: () {
                setState(() => _currentIndex = 1);
              },
            )
          : ResponsesScreen(
              uploader: _uploader,
            ),
    );
  }
}
