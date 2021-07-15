import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webcam_app/screen/upload/upload_item.dart';

var hintText;
var hintContent;
var photoState = 1;

class CustomCameraPage extends StatefulWidget {
  const CustomCameraPage({
    Key? key,
    required this.uploader,
    required this.uploadURL,
    required this.onUploadStarted,
  }) : super(key: key);
  final FlutterUploader uploader;
  final Uri uploadURL;
  final VoidCallback onUploadStarted;

  @override
  _CustomCameraPageState createState() => _CustomCameraPageState();
}

class _CustomCameraPageState extends State<CustomCameraPage> {
  StreamSubscription<UploadTaskProgress>? _progressSubscription;
  StreamSubscription<UploadTaskResponse>? _resultSubscription;
  Map<String, UploadItem> _tasks = {};
  CameraController? controller;
  List<CameraDescription>? cameras;
  int _currentIndex = 0;
  var imagePath;

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

    _progressSubscription = widget.uploader.progress.listen((progress) {
      final task = _tasks[progress.taskId];
      print(
          'In MAIN APP: ID: ${progress.taskId}, progress: ${progress.progress}');
      if (task == null) return;
      if (task.isCompleted()) return;

      var tmp = <String, UploadItem>{}..addAll(_tasks);
      tmp.putIfAbsent(progress.taskId, () => UploadItem(progress.taskId));
      tmp[progress.taskId] =
          task.copyWith(progress: progress.progress, status: progress.status);
      setState(() => _tasks = tmp);
    }, onError: (ex, stacktrace) {
      print('exception: $ex');
      print('stacktrace: $stacktrace');
    });

    _resultSubscription = widget.uploader.result.listen((result) {
      print(
          'IN MAIN APP: ${result.taskId}, status: ${result.status}, statusCode: ${result.statusCode}, headers: ${result.headers}');

      var tmp = <String, UploadItem>{}..addAll(_tasks);
      tmp.putIfAbsent(result.taskId, () => UploadItem(result.taskId));
      tmp[result.taskId] =
          tmp[result.taskId]!.copyWith(status: result.status, response: result);

      setState(() => _tasks = tmp);
    }, onError: (ex, stacktrace) {
      print('exception: $ex');
      print('stacktrace: $stacktrace');
    });
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
    var size = MediaQuery.of(context).size;
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
    var size = MediaQuery.of(context).size;
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

  var imageList = <String>[];
  int i = 0;
  Future takePicture() async {
    final ppp = await controller!.takePicture();
    String dir = path.dirname(ppp.path);
    String newPath = path.join(dir, '0000915-A123456789-${photoState}.jpg');
    File(ppp.path).renameSync(newPath);
    if (photoState <= 3) {
      setState(() {
        photoState++;
        imagePath = newPath;
        imageList.add(newPath);
      });
      _handleFileUpload([imageList[i]]);
      debugPrint(imageList[i].toString());
      i++;
    }
  }

  void _handleFileUpload(List<String> paths) async {
    final prefs = await SharedPreferences.getInstance();
    final binary = prefs.getBool('binary') ?? false;
    var result = 1;
    await widget.uploader
        .enqueue(_buildUpload(
          binary,
          paths.whereType<String>().toList(),
        ))
        .then((value) => checkResponse());

    widget.onUploadStarted();
  }

  Upload _buildUpload(bool binary, List<String> paths) {
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
        SizedBox(),
        Text('上傳成功')
      ]),
      content: Text(hintContent),
      actions: [
        ElevatedButton(
            child: Text("確認"),
            onPressed: () {
              Navigator.pop(context);
            }),
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
