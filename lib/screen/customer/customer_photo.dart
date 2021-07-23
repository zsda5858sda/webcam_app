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
          )),
    );
  }
}

class Body extends StatefulWidget {
  const Body({
    Key? key,
    required this.uploadURL,
  }) : super(key: key);
  final Uri uploadURL;

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
        width: size.width,
        height: size.height,
        child: ClipRRect(
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
                  width: size.width,
                  height: size.height * 0.1,
                  color: Colors.black38,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      hintText,
                      style: TextStyle(fontSize: 30, color: Colors.white),
                    ),
                  ),
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
    return Container(
        height: 100,
        color: Colors.black,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: takePicture,
              child: Icon(
                Icons.camera_alt,
                color: Colors.black,
                size: 50,
              ),
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: EdgeInsets.all(15),
                primary: Colors.white, // <-- Button color
                onPrimary: Colors.red, // <-- Splash color
              ),
            ),
          ],
        ));
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
