// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:webcam_app/screen/upload/responses_screen.dart';

import 'image_upload.dart';

const String title = 'FileUpload Sample app';
final Uri uploadURL = Uri.parse(
  'https://vsid66.ubt.ubot.com.tw:81/uploadpic',
);

FlutterUploader _uploader = FlutterUploader();
var count = 1;
class fileUpload extends StatefulWidget {
  fileUpload({Key? key}) : super(key: key);
  static const String routeName = '/fileupload';
  @override
  _fileUpload createState() => _fileUpload();
}

class _fileUpload extends State<fileUpload> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('ic_upload');
    var initializationSettingsIOS = IOSInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
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
