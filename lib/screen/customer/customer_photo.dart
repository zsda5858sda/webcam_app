import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:webcam_app/screen/component/app_bar.dart';
import 'package:dio/dio.dart';
import 'package:camera/camera.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:webcam_app/database/dao/userDao.dart';
import 'package:webcam_app/screen/customer/customer_meet.dart';
import 'package:webcam_app/screen/upload/upload_item.dart';
import 'package:webcam_app/utils/response_app.dart';

const String title = 'FileUpload Sample app';
final Uri uploadURL = Uri.parse(
  'https://vsid.ubt.ubot.com.tw:81/uploadpic',
);
var hintText;
var hintContent;
var photoState = 1;

// FlutterUploader _uploader = FlutterUploader();

// void backgroundHandler() {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Notice these instances belong to a forked isolate.
//   var uploader = FlutterUploader();

//   var notifications = FlutterLocalNotificationsPlugin();

//   // Only show notifications for unprocessed uploads.
//   SharedPreferences.getInstance().then((preferences) {
//     var processed = preferences.getStringList('processed') ?? <String>[];

//     if (Platform.isAndroid) {
//       uploader.progress.listen((progress) {
//         if (processed.contains(progress.taskId)) {
//           return;
//         }

//         notifications.show(
//           progress.taskId.hashCode,
//           'FlutterUploader Example',
//           'Upload in Progress',
//           NotificationDetails(
//             android: AndroidNotificationDetails(
//               'FlutterUploader.Example',
//               'FlutterUploader',
//               'Installed when you activate the Flutter Uploader Example',
//               progress: progress.progress ?? 0,
//               icon: 'ic_upload',
//               enableVibration: false,
//               importance: Importance.low,
//               showProgress: true,
//               onlyAlertOnce: true,
//               maxProgress: 100,
//               channelShowBadge: false,
//             ),
//             iOS: IOSNotificationDetails(),
//           ),
//         );
//       });
//     }

//     uploader.result.listen((result) {
//       if (processed.contains(result.taskId)) {
//         return;
//       }

//       processed.add(result.taskId);
//       preferences.setStringList('processed', processed);

//       notifications.cancel(result.taskId.hashCode);

//       final successful = result.status == UploadTaskStatus.complete;

//       var title = 'Upload Complete';
//       if (result.status == UploadTaskStatus.failed) {
//         title = 'Upload Failed';
//       } else if (result.status == UploadTaskStatus.canceled) {
//         title = 'Upload Canceled';
//       }

//       notifications
//           .show(
//         result.taskId.hashCode,
//         'FlutterUploader Example',
//         title,
//         NotificationDetails(
//           android: AndroidNotificationDetails(
//             'FlutterUploader.Example',
//             'FlutterUploader',
//             'Installed when you activate the Flutter Uploader Example',
//             icon: 'ic_upload',
//             enableVibration: !successful,
//             importance: result.status == UploadTaskStatus.failed
//                 ? Importance.high
//                 : Importance.min,
//           ),
//           iOS: IOSNotificationDetails(
//             presentAlert: true,
//           ),
//         ),
//       )
//           .catchError((e, stack) {
//         print('error while showing notification: $e, $stack');
//       });
//     });
//   });
// }

class CustomerPhotoScreen extends StatefulWidget {
  CustomerPhotoScreen({Key? key}) : super(key: key);
  static const String routeName = "/photo";
  @override
  _CustomerPhotoScreen createState() => _CustomerPhotoScreen();
}

class _CustomerPhotoScreen extends State<CustomerPhotoScreen> {
  @override
  void initState() {
    super.initState();

    // _uploader.setBackgroundHandler(backgroundHandler);

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
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
          appBar: homeAppBar(),
          backgroundColor: Color(0xFF63BED0),
          body: Body(
            uploadURL: uploadURL,
            // uploader: _uploader,
            // onUploadStarted: () {
            //   setState(() {});
            //   debugPrint(_uploader.result.toString());
            // },
          )),
    );
  }
}

class Body extends StatefulWidget {
  const Body({
    Key? key,
    // required this.uploader,
    required this.uploadURL,
    // required this.onUploadStarted,
  }) : super(key: key);
  // final FlutterUploader uploader;
  final Uri uploadURL;
  // final VoidCallback onUploadStarted;

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  StreamSubscription<UploadTaskProgress>? _progressSubscription;
  StreamSubscription<UploadTaskResponse>? _resultSubscription;
  Map<String, UploadItem> _tasks = {};
  CameraController? controller;
  List<CameraDescription>? cameras;
  var imagePath;
  final Size size = ResponsiveApp().mq.size;

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void _camera() async {
    cameras = await availableCameras();
    if (cameras != null) {
      controller = CameraController(cameras![0], ResolutionPreset.medium);
      controller!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _camera();

    // _progressSubscription = widget.uploader.progress.listen((progress) {
    //   final task = _tasks[progress.taskId];
    //   print(
    //       'In MAIN APP: ID: ${progress.taskId}, progress: ${progress.progress}');
    //   if (task == null) return;
    //   if (task.isCompleted()) return;

    //   var tmp = <String, UploadItem>{}..addAll(_tasks);
    //   tmp.putIfAbsent(progress.taskId, () => UploadItem(progress.taskId));
    //   tmp[progress.taskId] =
    //       task.copyWith(progress: progress.progress, status: progress.status);
    //   setState(() => _tasks = tmp);
    // }, onError: (ex, stacktrace) {
    //   print('exception: $ex');
    //   print('stacktrace: $stacktrace');
    // });

    // _resultSubscription = widget.uploader.result.listen((result) {
    //   print(
    //       'IN MAIN APP: ${result.taskId}, status: ${result.status}, statusCode: ${result.statusCode}, headers: ${result.headers}');

    //   var tmp = <String, UploadItem>{}..addAll(_tasks);
    //   tmp.putIfAbsent(result.taskId, () => UploadItem(result.taskId));
    //   tmp[result.taskId] =
    //       tmp[result.taskId]!.copyWith(status: result.status, response: result);

    //   setState(() => _tasks = tmp);
    // }, onError: (ex, stacktrace) {
    //   print('exception: $ex');
    //   print('stacktrace: $stacktrace');
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: cameras == null
          ? Container(
              child: Center(
                child: Text("加載中..."),
              ),
            )
          : Container(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                children: <Widget>[_cameraWidget(), _cameraButton()],
              ),
            ),
    );
  }

  Widget _cameraWidget() {
    return Expanded(
      flex: 1,
      child: Stack(
        children: <Widget>[_cameraPreviewWidget(), _cameraScan()],
      ),
    );
  }

  Widget _cameraPreviewWidget() {
    return Center(
      child: SizedBox(
        width: size.width * 0.85,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: CameraPreview(
            controller!,
            child: buildCameraMask(),
          ),
        ),
      ),
    );
  }

  buildCameraMask() {
    switch (photoState) {
      case 1:
        hintText = '請拍攝身分證正面';
        break;
      case 2:
        hintText = '請拍攝身分證背面';
        break;
      case 3:
        hintText = '請拍攝第二證件正面';
        break;
      default:
    }
    switch (photoState) {
      case 1:
        hintContent = '請繼續拍攝身分證背面';
        break;
      case 2:
        hintContent = '請繼續拍攝第二證件正面';
        break;
      case 3:
        hintContent = '確認後進入視訊！';
        break;
      default:
    }
    Rect? cameraRect;
    if (controller!.value.previewSize != null) {
      cameraRect = cropRect(controller!.value.previewSize);
    }
    return cameraRect != null
        ? Container(
            child: Column(
              children: <Widget>[
                Container(
                  width: size.width * 0.85,
                  height: cameraRect.left * 300 / cameraRect.width,
                  color: Colors.black38,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      hintText,
                      style: TextStyle(fontSize: 22, color: Colors.white),
                    ),
                  ),
                ),
                Spacer(),
                Container(
                  width: size.width * 0.85,
                  height: cameraRect.left * 300 / cameraRect.width,
                  color: Colors.black38,
                ),
              ],
            ),
          )
        : SizedBox();
  }

  Rect cropRect(Size? size) {
    double wh = min(size!.width, size.height);
    if (size.width > size.height) {
      return Offset((size.width - wh) / 2, 0) & Size(wh, wh);
    }
    return Offset(0, (size.height - wh) / 2) & Size(wh, wh);
  }

  Widget _cameraScan() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 50, horizontal: 50),
      child: Image.asset("assets/images/scan3.png"),
    );
  }

  Widget _cameraButton() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: takePicture,
      child: Container(
        height: 80,
        color: Colors.black38,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: GestureDetector(
                  onTap: takePicture,
                  child: Icon(Icons.camera_alt, color: Colors.white, size: 50)),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _progressSubscription?.cancel();
    _resultSubscription?.cancel();
  }

  // var imageList = <String>[];
  Future takePicture() async {
    final ppp = await controller!.takePicture();
    String filePath = ppp.path;
    String fileName = '0000915-A123456789-$photoState.jpg';
    String newPath = path.join(path.dirname(filePath), fileName);
    File(filePath).renameSync(newPath);
    if (photoState <= 3) {
      imagePath = newPath;
      // imageList.add(newPath);
      //       Uint8List byteData = await _image![0].readAsBytes();
      // List<int> imageData = byteData.buffer.asUint8List();
      File file = File(imagePath);
      Uint8List bytes = file.readAsBytesSync();
      List<int> imageData = bytes.buffer.asUint8List();
      await _buildUpload(imageData, fileName)
          .then((Response<dynamic> response) {
        if (response.statusCode == 200) {
          showAlertDialog(context);
        }
      });
    }
  }

  Future<Response<dynamic>> _buildUpload(List<int> imageData, String fileName) {
    var url = widget.uploadURL;

    MultipartFile multipartFile = MultipartFile.fromBytes(
      imageData,
      filename: fileName,
      contentType: MediaType('image', 'jpg'),
    );
    FormData formData = FormData.fromMap({
      "uploaded_file": multipartFile,
    });
    return Dio().post(url.toString(), data: formData);
  }

  void checkResponse() {
    final item = _tasks.values.elementAt(0);
    if (item.response!.statusCode == 200) {
      showAlertDialog(context);
    }
  }

  showAlertDialog(BuildContext context) {
    // Init
    AlertDialog dialog = AlertDialog(
      title: Row(children: [
        Icon(
          Icons.cloud_done,
          color: Colors.green,
        ),
        Text('上傳成功')
      ]),
      content: Text(hintContent),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
                child: Text("確認"),
                onPressed: () async {
                  if (photoState > 3) {
                    final userDao = UserDao.instance;
                    final url = (await userDao.readAllNotes()).first.webviewUrl;
                    Navigator.pushNamed(context, CustomerWebRTC.routeName,
                        arguments: {"url": url});
                  } else {
                    setState(() {
                      photoState++;
                    });
                    Navigator.pop(context);
                  }
                }),
            SizedBox(width: size.width * 0.05),
            FlatButton(
                child: Text("重拍"),
                onPressed: () async {
                  Navigator.pop(context);
                }),
          ],
        ),
      ],
    );

    // Show the dialog
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }
}
