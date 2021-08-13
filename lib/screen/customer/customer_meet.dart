import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webcam_app/database/dao/userDao.dart';
import 'package:webcam_app/database/model/user.dart';
import 'package:http/http.dart' as http;

FlutterUploader _uploader = FlutterUploader();
CameraController? controller;
List<CameraDescription>? cameras;

void _camera() async {
  cameras = await availableCameras();
  if (cameras != null) {
    controller = CameraController(cameras![1], ResolutionPreset.medium);
    controller!.initialize().then((_) {});
  }
}

void backgroundHandler() {
  WidgetsFlutterBinding.ensureInitialized();

  // Notice these instances belong to a forked isolate.
  var uploader = FlutterUploader();

  var notifications = FlutterLocalNotificationsPlugin();
  var iosNotifications = IOSFlutterLocalNotificationsPlugin();

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
      iosNotifications.show(result.taskId.hashCode, title, "檔案上傳完成");
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

class CustomerWebRTC extends StatefulWidget {
  // dynamic data;
  // CustomerPage(this.data);
  static final String routeName = '/customerWeb';

  const CustomerWebRTC(
      {Key? key,
      required this.uploader,
      required this.uploadURL,
      required this.customerWebRtcUrl,
      required this.agentId})
      : super(key: key);

  final FlutterUploader uploader;
  final Uri uploadURL;
  final Uri customerWebRtcUrl;
  final String agentId;
  @override
  _CustomerWebRtc createState() => new _CustomerWebRtc();
}

class _CustomerWebRtc extends State<CustomerWebRTC> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
          useOnDownloadStart: true,
          useShouldOverrideUrlLoading: true,
          mediaPlaybackRequiresUserGesture: false,
          javaScriptEnabled: true),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  PullToRefreshController? pullToRefreshController;
  double progress = 0;
  final urlController = TextEditingController();
  var userId;
  @override
  void initState() {
    super.initState();
    _camera();
    getUserid();
    _uploader.setBackgroundHandler(backgroundHandler);
    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.blue,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var downloadUrl;
    String url = "https://172.20.10.10:82/main/Login.html";
    // String agentId = widget.data[0].toString();
    var now = DateTime.now();
    var year = now.year.toString();
    var month =
        now.month < 10 ? "0" + now.month.toString() : now.month.toString();
    var day = now.day < 10 ? "0" + now.day.toString() : now.day.toString();
    var hour = now.hour < 10 ? "0" + now.hour.toString() : now.hour.toString();
    var min =
        now.minute < 10 ? "0" + now.minute.toString() : now.minute.toString();
    var sec =
        now.second < 10 ? "0" + now.second.toString() : now.second.toString();
    var datetime = year + month + day + hour + min + sec;
    dynamic arguments = ModalRoute.of(context)!.settings.arguments;
    // String url = arguments["url"];
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          body: SafeArea(
              child: Column(children: <Widget>[
        Expanded(
          child: Stack(
            children: [
              InAppWebView(
                key: webViewKey,
                initialUrlRequest: URLRequest(url: widget.customerWebRtcUrl),
                initialOptions: options,
                pullToRefreshController: pullToRefreshController,
                onWebViewCreated: (controller) {
                  webViewController = controller;
                  print("webviewOnCreated");
                  controller.addJavaScriptHandler(
                    handlerName: 'blobToBase64Handler',
                    callback: (data) async {
                      print("data is not empty??" + data.isNotEmpty.toString());
                      if (data.isNotEmpty) {
                        final String receivedFileInBase64 = data[0];
                        final String receivedMimeType = data[1];
                        // NOTE: create a method that will handle your extensions
                        print("this is recievedFile" + receivedFileInBase64);
                        print("this is recievedMime" + receivedMimeType);
                        var platform = Platform.isIOS ? "-i-" : "-a-";
                        var fileName =
                            widget.agentId + '-' + userId + platform + datetime;
                        debugPrint(fileName);
                        final String yourExtension = "webm";
                        _createFileFromBase64(
                            receivedFileInBase64, fileName, yourExtension);
                      } else {
                        debugPrint('data is empty!!');
                      }
                    },
                  );
                },
                onLoadStart: (controller, url) {
                  setState(() {});
                },
                onReceivedServerTrustAuthRequest:
                    (controller, challenge) async {
                  return ServerTrustAuthResponse(
                      action: ServerTrustAuthResponseAction.PROCEED);
                },
                androidOnPermissionRequest:
                    (controller, origin, resources) async {
                  return PermissionRequestResponse(
                      resources: resources,
                      action: PermissionRequestResponseAction.GRANT);
                },
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  var uri = navigationAction.request.url;

                  if (![
                    "http",
                    "https",
                    "file",
                    "chrome",
                    "data",
                    "javascript",
                    "about",
                    "blob:"
                  ].contains(uri!.scheme)) {
                    if (await canLaunch(url)) {
                      // Launch the App
                      await launch(
                        url,
                      );
                      // and cancel the request
                      return NavigationActionPolicy.CANCEL;
                    }
                  }

                  return NavigationActionPolicy.ALLOW;
                },
                onLoadStop: (controller, url) async {
                  debugPrint("now the userId is:" + userId);
                  String uId = userId.toString();
                  pullToRefreshController!.endRefreshing();
                  pullToRefreshController!.endRefreshing();
                  controller.evaluateJavascript(
                      source: 'var testUserId = "' + uId + '";');
                },
                onLoadError: (controller, url, code, message) {
                  pullToRefreshController!.endRefreshing();
                },
                onProgressChanged: (controller, progress) {
                  if (progress == 100) {
                    pullToRefreshController!.endRefreshing();
                  }
                  setState(() {
                    this.progress = progress / 100;
                  });
                },
                onUpdateVisitedHistory: (controller, url, androidIsReload) {
                  setState(() {});
                },
                onDownloadStart: (controller, url) async {
                  print("onDownloadStart $url");
                },
                onConsoleMessage: (controller, consoleMessage) async {
                  print(consoleMessage);
                  if (consoleMessage.message.contains('blob')) {
                    setState(() {
                      downloadUrl = consoleMessage.message;
                    });
                  }
                  if (consoleMessage.message.contains('in RecordStart')) {
                    getStartTimeTxt(widget.agentId);
                  }
                  if (consoleMessage.message
                      .contains('in mystopRecording now')) {
                    getStopTimeTxt(widget.agentId);
                  }
                },
              ),
              progress < 1.0
                  ? LinearProgressIndicator(value: progress)
                  : Container(),
            ],
          ),
        ),
      ]))),
    );
  }

  var startTime;
  _createFileFromBase64(
      String base64content, String fileName, String yourExtension) async {
    print("now is in createFileBase64");
    var bytes = base64Decode(base64content.replaceAll('\n', ''));
    debugPrint('below is byte bro');
    final output;
    if (Platform.isAndroid) {
      output = await getExternalStorageDirectory();
    } else {
      output = await getApplicationDocumentsDirectory();
    }
    final file = File("${output!.path}/$fileName.$yourExtension");
    await file.writeAsBytes(bytes.buffer.asUint8List());
    print("${output.path}/${fileName}.webm");
    Timer(Duration(seconds: 3), () async {
      _handleFileUpload([file.path]);
    });
    // File(file.path).deleteSync();
  }

  void _handleFileUpload(List<String> paths) async {
    print("now is file uploading...");
    final prefs = await SharedPreferences.getInstance();
    final binary = prefs.getBool('binary') ?? false;
    await widget.uploader.enqueue(_buildUpload(
      binary,
      paths.whereType<String>().toList(),
    ));
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
                field: 'videofile',
              ))
          .toList(),
      method: UploadMethod.POST,
      tag: tag,
    );
  }

  Future getUserid() async {
    List<User> userList = await UserDao.instance.readAllNotes();
    debugPrint(userList.first.id);
    userId = userList.first.id;
  }

  Future getStartTimeTxt(String fileName) async {
    List<User> userList = await UserDao.instance.readAllNotes();
    fileName = fileName + '-' + userList.first.id + "-recordStartTime.txt";
    var now = DateTime.now();
    this.startTime = now;
    await http.post(
      Uri.parse("http://172.20.10.10:8080/uploadTxt" +
          "?content=$now&fileName=$fileName"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
    );
  }

  Future getStopTimeTxt(String fileName) async {
    List<User> userList = await UserDao.instance.readAllNotes();
    fileName = fileName + '-' + userList.first.id + "-recordStopTime.txt";
    var now = DateTime.now();
    String totals = now.difference(this.startTime).inSeconds.toString();
    print("here is totalSec" + totals);
    await http.post(
      Uri.parse("http://172.20.10.10:8080/uploadTxt" +
          "?content=$totals&fileName=$fileName"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8'
      },
    );
  }
}
