import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:webcam_app/config/config.dart';
import 'package:webcam_app/database/dao/userDao.dart';
import 'package:webcam_app/database/model/user.dart';
import 'package:webcam_app/screen/component/alert_btn.dart';
import 'package:dio/dio.dart';
import 'package:camera/camera.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:webcam_app/screen/customer/customer_meet.dart';
import 'package:webcam_app/screen/upload/upload_item.dart';
import 'package:http/http.dart' as http;
import 'package:webcam_app/utils/responsive_app.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

const String title = 'FileUpload Sample app';
final Uri uploadPicUrl = Uri.parse(Config.uploadPic);
FlutterUploader _uploader = FlutterUploader();
var uploadVideoUrl = Uri.parse(Config.uploadPic);

var hintText;
var hintContent;
var photoState = 1;
var now = DateTime.now();
var year = now.year.toString();
var month = now.month < 10 ? "0" + now.month.toString() : now.month.toString();
var day = now.day < 10 ? "0" + now.day.toString() : now.day.toString();
var datetime = year + month + day;

class CustomerPhotoArguments {
  final String agentId;

  CustomerPhotoArguments(this.agentId);
}

class CustomerPhotoScreen extends StatefulWidget {
  CustomerPhotoScreen({Key? key}) : super(key: key);
  static const String routeName = "/photo";
  @override
  _CustomerPhotoScreen createState() => _CustomerPhotoScreen();
}

class _CustomerPhotoScreen extends State<CustomerPhotoScreen> {
  @override
  void initState() {
    photoState = 1;
    super.initState();
    EasyLoading.addStatusCallback((status) {
      print('EasyLoading Status $status');
      if (status == EasyLoadingStatus.dismiss) {
        print('cancel');
      }
    });
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
    final args =
        ModalRoute.of(context)!.settings.arguments as CustomerPhotoArguments;
    String agentId = args.agentId;

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
          backgroundColor: Color(0xFF63BED0),
          body: Body(
            agentId: agentId,
            uploadURL: uploadVideoUrl,
            customerWebRtcUrl: Uri.parse(
                "https://172.20.10.10:82/main/client/index.html?openExternalBrowser=1&agentid=" +
                    agentId),
          )),
    );
  }
}

class Body extends StatefulWidget {
  const Body(
      {Key? key,
      required this.uploadURL,
      required this.customerWebRtcUrl,
      required this.agentId})
      : super(key: key);
  final Uri uploadURL;
  final Uri customerWebRtcUrl;
  final String agentId;

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
  var userId;
  var filePaths = [];
  var fileNames = [];
  final Size size = ResponsiveApp().mq.size;

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void _camera() async {
    cameras = await availableCameras();
    if (cameras != null) {
      controller = CameraController(cameras![0], ResolutionPreset.medium);
      DeviceOrientation? deviceOrientation;
      controller!.lockCaptureOrientation(deviceOrientation);
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
    getUserid();
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
        height: size.height * 0.9,
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

    controller?.dispose();
  }

  // var imageList = <String>[];
  Future takePicture() async {
    var now = DateTime.now();
    var year = now.year.toString();
    var month =
        now.month < 10 ? "0" + now.month.toString() : now.month.toString();
    var day = now.day < 10 ? "0" + now.day.toString() : now.day.toString();
    var datetime = year + month + day;

    final ppp = await controller!.takePicture();
    String filePath = ppp.path;
    String fileName = widget.agentId.toString() +
        '-' +
        userId.toString() +
        '-' +
        datetime +
        '-$photoState.jpg';
    String newPath = path.join(path.dirname(filePath), fileName);
    File(filePath).renameSync(newPath);
    if (photoState <= 3) {
      filePaths.add(newPath);
      fileNames.add(fileName);
      showAlertDialog(context);
    }
  }

  Future<Response<dynamic>> _buildUpload(List<int> imageData, String fileName) {
    var url = uploadPicUrl;

    MultipartFile multipartFile = MultipartFile.fromBytes(
      imageData,
      filename: fileName,
      contentType: MediaType('image', 'jpg'),
    );
    FormData formData = FormData.fromMap({
      "file": multipartFile,
    });
    return Dio().post(
      url.toString(),
      data: formData,
    );
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
        Container(
            width: size.width * 0.6,
            height: 40,
            margin: EdgeInsets.only(left: 5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Color(0xFF0099E9)),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "拍攝完成",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ))
      ]),
      content: Text(
        hintContent,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AlertBtn(
                size: size * 0.1,
                btnName: "確認",
                onPress: () async {
                  if (photoState < 3) {
                    setState(() {
                      photoState++;
                    });
                    print(fileNames);
                    print(filePaths);
                    Navigator.pop(context);
                  } else {
                    print('準備跳頁');
                    print(fileNames);
                    print(filePaths);
                    Navigator.pop(context);
                    await createFile(widget.agentId +
                        '-' +
                        userId +
                        "-" +
                        datetime.toString() +
                        "-location.txt");
                    for (int i = 0; i < fileNames.length; i++) {
                      File file = File(filePaths[i]);
                      print(fileNames.length);
                      Uint8List bytes = file.readAsBytesSync();
                      List<int> imageData = bytes.buffer.asUint8List();
                      await _buildUpload(imageData, fileNames[i])
                          .then((Response<dynamic> response) async {
                        print("回傳訊息" + response.toString());
                        Map<String, dynamic> json =
                            jsonDecode(response.toString());
                        String data = json['message'];
                        print(data);
                        // await HttpUtils().sendLog(userId, data, "1");
                        if (response.statusCode == 200) {
                          print("上傳成功！");
                          File(filePaths[i]).deleteSync();
                          await EasyLoading.show(
                            status: '檔案上傳中',
                            maskType: EasyLoadingMaskType.black,
                          );
                        }
                      });
                    }
                    await EasyLoading.showSuccess('上傳成功，即將進行視訊');
                    Timer(Duration(seconds: 3), () async {
                      await EasyLoading.dismiss();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => CustomerWebRTC(
                                    uploader: _uploader,
                                    uploadURL: widget.uploadURL,
                                    customerWebRtcUrl: widget.customerWebRtcUrl,
                                    agentId: widget.agentId,
                                  )));
                    });
                  }
                  print(photoState);
                }),
            SizedBox(width: size.width * 0.08),
            AlertBtn(
                size: size * 0.1,
                btnName: "重拍",
                onPress: () async {
                  print(photoState);
                  File(filePaths[photoState - 1]).deleteSync();
                  fileNames.removeAt(photoState - 1);
                  filePaths.removeAt(photoState - 1);
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

  Future getUserid() async {
    List<User> userList = await UserDao.instance.readAllNotes();
    debugPrint(userList.first.id);
    userId = userList.first.id;
  }

  Future createFile(String fileName) async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    await http.post(
      Uri.parse(Config.uploadtxt + "?content=$position&fileName=$fileName"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
    ).then((response) {
      var body = json.decode(response.body);
      var logMessage = body['message'];
      print(response.statusCode);
      print(logMessage);
    });
  }

  routeToCustomerWeb() {
    MaterialPageRoute(
        builder: (context) => CustomerWebRTC(
              uploader: _uploader,
              uploadURL: widget.uploadURL,
              customerWebRtcUrl: widget.customerWebRtcUrl,
              agentId: widget.agentId,
            ));
  }
}
