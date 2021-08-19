import 'dart:io';
import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:camera/camera.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webcam_app/main.dart';
import 'package:webcam_app/utils/responsive_app.dart';

const String title = 'FileUpload Sample app';
final Uri uploadURL = Uri.parse(
  'http://localhost:8080/upload',
);
var hintText;
var hintContent;
var photoState = 1;

class CustomerPhotoDocScreen extends StatefulWidget {
  CustomerPhotoDocScreen({Key? key}) : super(key: key);
  static const String routeName = "/photodoc";
  @override
  _CustomerPhotoDocScreen createState() => _CustomerPhotoDocScreen();
}

class _CustomerPhotoDocScreen extends State<CustomerPhotoDocScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
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
  CameraController? controller;
  List<CameraDescription>? cameras;
  var imagePath;
  final Size size = ResponsiveApp().mq.size;
  ImagePicker imagePicker = ImagePicker();
  FlutterUploader _uploader = FlutterUploader();

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
                children: <Widget>[
                  _cameraWidget(),
                  _cameraButton(),
                ],
              ),
            ),
    );
  }

  Widget _cameraWidget() {
    return Expanded(
      flex: 1,
      child: Stack(
        children: <Widget>[
          _cameraPreviewWidget(),
          _cameraScan(),
        ],
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
                    child: RichText(
                      text: TextSpan(
                        text: '請拍攝',
                        style: TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          letterSpacing: 3,
                        ),
                        children: const <TextSpan>[
                          TextSpan(
                            text: '文件',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
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
      child: Image.asset(
        "assets/images/scan3.png",
      ),
    );
  }

  Widget _cameraButton() {
    return Container(
      height: 100,
      alignment: Alignment.center,
      color: Colors.black,
      child: Row(
        children: [
          Spacer(
            flex: 3,
          ),
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
          Spacer(),
          ElevatedButton(
            onPressed: () async {
              var images = await imagePicker.getMultiImage();
              var index = 0;
              List<String> pathList = [];
              if (images != null) {
                images.forEach((image) {
                  index++;
                  String dir = path.dirname(image.path);
                  String newPath =
                      path.join(dir, '0000916-A123456789-$index.jpg');
                  File(image.path).renameSync(newPath);
                  pathList.add(newPath);
                });
                _handleFileUpload(pathList);
              }
            },
            child: Icon(
              Icons.file_upload,
              color: Colors.black,
              size: 30,
            ),
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              padding: EdgeInsets.all(15),
              primary: Colors.white, // <-- Button color
              onPrimary: Colors.red, // <-- Splash color
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _progressSubscription?.cancel();
    _resultSubscription?.cancel();
  }

  Future takePicture() async {
    final image = await controller!.takePicture();
    if (Platform.isAndroid) {
      String filePath = image.path;
      String fileName = image.name;
      String newPath = path.join("/storage/emulated/0/Download", fileName);
      File(newPath).writeAsBytes(await File(filePath).readAsBytes());
      Fluttertoast.showToast(
          msg: "相片儲存於$newPath",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
          fontSize: 20.0);
    }
  }

  void _handleFileUpload(List<String> paths) async {
    await _uploader.enqueue(_buildUpload(
      paths.whereType<String>().toList(),
    ));
  }

  Upload _buildUpload(List<String> paths) {
    final tag = 'upload';

    var url = widget.uploadURL;

    return MultipartFormDataUpload(
      url: url.toString(),
      data: {'name': 'john'},
      files: paths
          .map((e) => FileItem(
                path: e,
                field: 'uploaded_file',
              ))
          .toList(),
      method: UploadMethod.POST,
      tag: tag,
    );
    // }
  }
}
