import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webcam_app/screen/clerk/clerk_login.dart';
import 'package:webcam_app/screen/clerk/clerk_push_message.dart';
import 'package:webcam_app/screen/customer/customer_photo_doc.dart';
import 'package:webcam_app/screen/customer/customer_register.dart';
import 'package:webcam_app/screen/customer/customer_options.dart';
import 'package:webcam_app/screen/customer/customer_photo.dart';
import 'package:webcam_app/screen/customer/customer_manual.dart';
import 'package:webcam_app/screen/customer/customer_meet.dart';
import 'package:webcam_app/screen/home_screen.dart';
import 'package:webcam_app/screen/upload/file_upload.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';

/// Create a [AndroidNotificationChannel] for heads up notifications
var channel;
FlutterUploader _uploader = FlutterUploader();
var uploadUrl = "https://vsid.ubt.ubot.com.tw:81/uploadvideo";

/// Initialize the [FlutterLocalNotificationsPlugin] package.
var flutterLocalNotificationsPlugin;

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();
Future<void> main() async {
  // 視覺輔助排版工具
  // debugPaintSizeEnabled = true;
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
  await Permission.storage.request();
  await Permission.camera.request();
  await Permission.microphone.request();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  _uploader.setBackgroundHandler(backgroundHandler);
  await initPlatformState();
  if (!kIsWeb) {
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    // await FirebaseMessaging.instance
    //     .setForegroundNotificationPresentationOptions(
    //   alert: true,
    //   badge: true,
    //   sound: true,
    // );
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    /// Note: permissions aren't requested here just to demonstrate that can be
    /// done later
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
            onDidReceiveLocalNotification:
                (int id, String? title, String? body, String? payload) async {
              didReceiveLocalNotificationSubject.add(ReceivedNotification(
                  id: id, title: title, body: body, payload: payload));
            });
    const MacOSInitializationSettings initializationSettingsMacOS =
        MacOSInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false);
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: initializationSettingsMacOS);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async {
      if (payload != null) {
        debugPrint('notification payload: $payload');
      }
      selectNotificationSubject.add(payload);
    });
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '視訊系統',
      home: HomeScreen(
        flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
        channel: channel,
      ),
      routes: {
        CustomerRegisterScreen.routeName: (context) => CustomerRegisterScreen(),
        CustomerOptionsScreen.routeName: (context) => CustomerOptionsScreen(),
        CustomerPhotoScreen.routeName: (context) => CustomerPhotoScreen(),
        CustomerWebRTC.routeName: (context) => CustomerWebRTC(
            uploader: _uploader, uploadURL: Uri.parse(uploadUrl)),
        CustomerMaunalScreen.routeName: (context) => CustomerMaunalScreen(),
        CustomerPhotoDocScreen.routeName: (context) => CustomerPhotoDocScreen(),
        ClerkLoginScreen.routeName: (context) => ClerkLoginScreen(),
        ClerkPushMessageScreen.routeName: (context) => ClerkPushMessageScreen(),
        fileUpload.routeName: (context) => fileUpload()
      },
    );
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

class ReceivedNotification {
  var id;
  var title;
  var body;
  var payload;

  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });
}

Future<void> initPlatformState() async {
  bool jailbroken;
  bool developerMode;
  // Platform messages may fail, so we use a try/catch PlatformException.
  try {
    jailbroken = await FlutterJailbreakDetection.jailbroken;
    developerMode = await FlutterJailbreakDetection.developerMode;
  } on PlatformException {
    jailbroken = true;
    developerMode = true;
  }

  // If the widget was removed from the tree while the asynchronous platform
  // message was in flight, we want to discard the reply rather than calling
  // setState to update our non-existent appearance.
  if (jailbroken) {
    print('now is in jailbroken! Plz fix it');
  } else if (developerMode) {
    print('Its developing now');
  } else {
    print("Its safe now");
  }
}

void backgroundHandler() {
  WidgetsFlutterBinding.ensureInitialized();

  // Notice these instances belong to a forked isolate.
  var uploader = FlutterUploader();
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  // Only show notifications for unprocessed uploads.
  SharedPreferences.getInstance().then((preferences) {
    var processed = preferences.getStringList('processed') ?? <String>[];

    uploader.result.listen((result) {
      if (processed.contains(result.taskId)) {
        return;
      }

      processed.add(result.taskId);
      preferences.setStringList('processed', processed);

      var title = 'Upload Complete';
      if (result.status == UploadTaskStatus.failed) {
        title = 'Upload Failed';
      } else if (result.status == UploadTaskStatus.canceled) {
        title = 'Upload Canceled';
      }
      flutterLocalNotificationsPlugin
          .show(
        result.taskId.hashCode,
        'FlutterUploader Example',
        title,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            'This channel is used for important notifications.',
            icon: 'launch_background',
          ),
        ),
      )
          .catchError((e, stack) {
        print('error while showing notification: $e, $stack');
      });
    });
  });
}
