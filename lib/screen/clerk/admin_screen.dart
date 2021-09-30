import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:webcam_app/screen/component/counter.dart';
import 'package:webcam_app/screen/customer/thanks.dart';
import 'package:webcam_app/screen/upload/upload_item.dart';
import 'package:webcam_app/utils/http_utils.dart';

FlutterUploader _uploader = FlutterUploader();
CameraController? controller;
List<CameraDescription>? cameras;
String uploadFilePath = "";
bool stillInTime = true;
late double percent;
int count = 0;
int uploadCount = 0;

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

  // Only show notifications for unprocessed uploads.
  SharedPreferences.getInstance().then((preferences) {
    var processed = preferences.getStringList('processed') ?? <String>[];

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

      print("Upload completed!!!!!");

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

class ClerkWebRTC extends StatefulWidget {
  // dynamic data;
  // CustomerPage(this.data);
  static final String routeName = '/clerkWeb';

  const ClerkWebRTC(
      {Key? key,
      required this.uploader,
      required this.uploadURL,
      required this.webRtcUrl,
      required this.agentId,
      required this.deparment})
      : super(key: key);

  final FlutterUploader uploader;
  final Uri uploadURL;
  final Uri webRtcUrl;
  final String agentId;
  final String deparment;
  @override
  _ClerkWebRtc createState() => new _ClerkWebRtc();
}

class _ClerkWebRtc extends State<ClerkWebRTC> {
  bool recording = false;
  int uploadcount = 0;
  var totalTask = 0;
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  StreamSubscription<UploadTaskProgress>? _progressSubscription;
  StreamSubscription<UploadTaskResponse>? _resultSubscription;
  Timer? _timer;
  bool allowCellular = true;
  bool recordStop = false;

  Map<String, UploadItem> _tasks = {};
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
  double _progress = 0;
  final urlController = TextEditingController();
  var userId;
  @override
  void initState() {
    super.initState();
    _camera();
    _uploader.setBackgroundHandler(backgroundHandler);
    EasyLoading.addStatusCallback((status) {
      print('EasyLoading Status $status');
      if (status == EasyLoadingStatus.dismiss) {
        print('cancel');
      }
    });
    _progressSubscription = widget.uploader.progress.listen((progress) {
      final task = _tasks[progress.taskId];
      if (task == null) return;
      if (task.isCompleted()) return;
      if (!task.isCompleted()) {
        print('In MAIN APP: ID: ${progress.taskId}, progress: ${_progress}');
        _progress = progress.progress!.toDouble() / 100;
        // if (_progress == 1.0) {
        //   uploadcount++;
        //   if (uploadCount == uploadCount) {
        //     print("可以上傳");
        //     EasyLoading.dismiss();
        //     Navigator.push(context,
        //         MaterialPageRoute(builder: (context) => ThanksScreen()));
        //   }
        //   print("here is the upload count" + uploadcount.toString());
        // }
        var tmp = <String, UploadItem>{}..addAll(_tasks);
        tmp.putIfAbsent(progress.taskId, () => UploadItem(progress.taskId));
        tmp[progress.taskId] =
            task.copyWith(progress: progress.progress, status: progress.status);
        setState(() => _tasks = tmp);
      }
    }, onError: (ex, stacktrace) {
      print('exception: $ex');
      print('stacktrace: $stacktrace');
    });

    _resultSubscription = widget.uploader.result.listen((result) {
      var tmp = <String, UploadItem>{}..addAll(_tasks);

      tmp.putIfAbsent(result.taskId, () => UploadItem(result.taskId));
      tmp[result.taskId] =
          tmp[result.taskId]!.copyWith(status: result.status, response: result);
      if (totalTask != 0) {
        if ((totalTask + count) == tmp.length) {
          print("totalTask + 總共錄幾個:" +
              (totalTask + count).toString() +
              " = " +
              tmp.length.toString());
          EasyLoading.showSuccess("影片處理完成！",
              duration: Duration(milliseconds: 2000));
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ThanksScreen(count: count),
                  maintainState: false));
        }
      }
      setState(() => _tasks = tmp);
    }, onError: (ex, stacktrace) {
      print('exception: $ex');
      print('stacktrace: $stacktrace');
    });
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

    SharedPreferences.getInstance()
        .then((sp) => sp.getBool('allowCellular') ?? true)
        .then((result) {
      if (mounted) {
        setState(() {
          allowCellular = result;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var downloadUrl;
    String url = "https://172.20.10.10:82/main/Login.html";
    String finalUrl = url;
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
    var foldertime = year + month + day;
    var counter = Provider.of<Counter>(context);
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
                  initialUrlRequest: URLRequest(url: widget.webRtcUrl),
                  initialOptions: options,
                  pullToRefreshController: pullToRefreshController,
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                    controller.addJavaScriptHandler(
                      handlerName: 'blobToBase64Handler',
                      callback: (data) async {
                        if (data.isNotEmpty) {
                          final String receivedFileInBase64 = data[0];
                          final String receivedMimeType = data[1];
                          // NOTE: create a method that will handle your extensions
                          String agentDevice;
                          if (Platform.isIOS) {
                            agentDevice = "-bi-";
                          } else {
                            agentDevice = "-ba-";
                          }
                          String fileName = widget.agentId +
                              '-' +
                              userId.toString() +
                              '-' +
                              foldertime +
                              agentDevice +
                              datetime.toString() +
                              '-' +
                              widget.deparment +
                              '-' +
                              count.toString();
                          debugPrint("this is fileName:" + fileName);
                          final String yourExtension;
                          if (Platform.isIOS) {
                            yourExtension = "mp4";
                          } else {
                            yourExtension = "webm";
                          }
                          _createFileFromBase64(
                              receivedFileInBase64, fileName, yourExtension);
                          // var timer =
                          //     Timer.periodic(Duration(seconds: 1), (timer) {
                          //   setState(() {
                          //     Provider.of<Counter>(context, listen: false)
                          //         .addCount();
                          //   });
                          //   if (counter.count == 0) {
                          //     timer.cancel();
                          //     stillInTime = false;
                          //     print("上傳時間已到");
                          //   }
                          // });
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
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
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
                    pullToRefreshController!.endRefreshing();
                  },
                  onLoadError: (controller, url, code, message) {
                    pullToRefreshController!.endRefreshing();
                  },
                  onProgressChanged: (controller, progress) {
                    if (progress == 100) {
                      pullToRefreshController!.endRefreshing();
                    }
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
                    if (consoleMessage.message.contains("msg.from")) {
                      userId = consoleMessage.message.substring(9, 19);
                    }
                    if (consoleMessage.message
                            .contains("in mystopRecording now") ||
                        consoleMessage.message
                            .contains("in finalstopRecording now")) {
                      count++;
                    }
                    if (consoleMessage.message.contains("錄影結束")) {
                      print("總共錄了 ${count}個檔案");
                      totalTask = _tasks.length;
                      recordStop = true;
                      await EasyLoading.showSuccess("錄影結束，請稍等影片處理...",
                          duration: Duration(milliseconds: 2000));
                      await EasyLoading.show(
                        status: '正在處理對保影片，請稍候...',
                        maskType: EasyLoadingMaskType.black,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ])),
      ),
    );
  }

  var startTime;
  _createFileFromBase64(
      String base64content, String fileName, String yourExtension) async {
    var bytes = base64Decode(base64content.replaceAll('\n', ''));
    final output;
    if (Platform.isAndroid) {
      output = await getApplicationDocumentsDirectory();
    } else {
      output = await getApplicationDocumentsDirectory();
    }
    final file = File("${output!.path}/$fileName.$yourExtension");
    await file.writeAsBytes(bytes.buffer.asUint8List());
    print("${output.path}/${fileName}.${yourExtension}");
    print("thw webm fileName is ${fileName}.webm");
    // await GallerySaver.saveVideo(file.path);
    Timer(Duration(seconds: 1), () async {
      await EasyLoading.dismiss();
    });
    _handleFileUpload([file.path]);
    uploadFilePath = file.path;
    // Timer(Duration(seconds: 10), () {
    //   print('Hello world');
    // });
    // File(file.path).deleteSync();
  }

  Future getTotalFileCount(String fileName) async {
    var now = DateTime.now();
    var year = now.year.toString();
    var month =
        now.month < 10 ? "0" + now.month.toString() : now.month.toString();
    var day = now.day < 10 ? "0" + now.day.toString() : now.day.toString();
    var datetime = year + month + day;
    fileName = fileName + '-' + userId + "-" + datetime + "-agentFileCount.txt";
    HttpUtils().createTxtFile(fileName, count.toString());
  }

  void _handleFileUpload(List<String> paths) async {
    uploadCount++;
    final prefs = await SharedPreferences.getInstance();
    final binary = prefs.getBool('binary') ?? false;
    await widget.uploader
        .enqueue(_buildUpload(
      binary,
      paths.whereType<String>().toList(),
    ))
        .whenComplete(() {
      if (recordStop) {
        print("總共錄了 ${count}個檔案");
        getTotalFileCount(widget.agentId);
      }
    });
  }

  Upload _buildUpload(bool binary, List<String> paths) {
    final tag = 'upload';

    var url = widget.uploadURL;
    print('this is fileName' + paths.toString());
    print('this is fileUrl' + url.toString());

    return MultipartFormDataUpload(
      url: url.toString(),
      data: {'name': 'john'},
      files: paths
          .map((e) => FileItem(
                path: e,
                field: 'file',
              ))
          .toList(),
      method: UploadMethod.POST,
      tag: tag,
    );
  }
}
