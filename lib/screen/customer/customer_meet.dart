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
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webcam_app/database/dao/userDao.dart';
import 'package:webcam_app/database/model/user.dart';
import 'package:webcam_app/screen/component/counter.dart';
import 'package:webcam_app/screen/customer/customer_options.dart';
import 'package:webcam_app/screen/customer/thanks.dart';
import 'package:webcam_app/screen/upload/responses_screen.dart';
import 'package:webcam_app/screen/upload/upload_item.dart';
import 'package:webcam_app/utils/http_utils.dart';

FlutterUploader _uploader = FlutterUploader();
CameraController? controller;
List<CameraDescription>? cameras;
String uploadFilePath = "";
bool stillGotTime = true;
double percent = 0.0;
int uploadcount = 0;

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
        print("now the progress is ${progress.progress}");
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
      uploadcount++;
      print("here is uploadcount" + uploadcount.toString());
      notifications.cancel(result.taskId.hashCode);

      final successful = result.status == UploadTaskStatus.complete;

      var title = '上傳成功';
      // if (result.status == UploadTaskStatus.complete) {
      //   File(uploadFilePath).deleteSync();
      // }
      if (result.status == UploadTaskStatus.failed) {
        title = '上傳失敗，即將重新上傳';
        if (stillGotTime) {
          _handleFileUpload([uploadFilePath]);
        }
      } else if (result.status == UploadTaskStatus.canceled) {
        title = 'Upload Canceled';
      }
      iosNotifications.show(result.taskId.hashCode, title, "檔案上傳完成");
      notifications
          .show(
        result.taskId.hashCode,
        '對保影像上傳通知',
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
              presentAlert: true, presentBadge: true, subtitle: "對保影片上傳通知"),
        ),
      )
          .catchError((e, stack) {
        print('error while showing notification: $e, $stack');
      });
    });
  });
}

void _handleFileUpload(List<String> paths) async {
  print("now is file uploading...");
  final prefs = await SharedPreferences.getInstance();
  final binary = prefs.getBool('binary') ?? false;
  await _uploader.enqueue(_buildUpload(
    binary,
    paths.whereType<String>().toList(),
  ));
}

Upload _buildUpload(bool binary, List<String> paths) {
  final tag = 'upload';

  var url = "https://vsid66.ubt.ubot.com.tw/webcam_api/fileuploadservlet";

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
  double _progress = 0;
  InAppWebViewController? webViewController;
  StreamSubscription<UploadTaskProgress>? _progressSubscription;
  StreamSubscription<UploadTaskResponse>? _resultSubscription;
  Timer? _timer;
  int count = 0;
  int uploadCount = 0;
  int totalTask = 0;
  bool recordEnd = false;
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
  double currentProgress = 0.0;
  late String numb;
  final urlController = TextEditingController();
  var userId;
  @override
  void initState() {
    super.initState();
    _camera();
    getUserid();
    EasyLoading.addStatusCallback((status) {
      print('EasyLoading Status $status');
      if (status == EasyLoadingStatus.dismiss) {
        print('cancel');
      }
    });
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
    _progressSubscription = widget.uploader.progress.listen((progress) {
      final task = _tasks[progress.taskId];
      if (task == null) return;
      if (task.isCompleted()) return;
      if (!task.isCompleted()) {
        print('In MAIN APP: ID: ${progress.taskId}, progress: ${_progress}');
        _progress = progress.progress!.toDouble() / 100;
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
      numb = result.taskId;
      print("now the num is ${numb}");

      tmp.putIfAbsent(result.taskId, () => UploadItem(result.taskId));
      tmp[result.taskId] =
          tmp[result.taskId]!.copyWith(status: result.status, response: result);
      print("total finished tasked is " + tmp.length.toString());
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
                  builder: (context) => ThanksScreen(
                        count: count,
                        userId: userId,
                        agentId: widget.agentId,
                      ),
                  maintainState: false));
        }
      }
      setState(() => _tasks = tmp);
    }, onError: (ex, stacktrace) {
      print('exception: $ex');
      print('stacktrace: $stacktrace');
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
                        var platform = Platform.isIOS ? "-i-" : "-a-";
                        var fileName = widget.agentId +
                            '-' +
                            userId +
                            '-' +
                            foldertime +
                            platform +
                            datetime +
                            "-" +
                            count.toString();
                        debugPrint(fileName);
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
                        //         .addCount2();
                        //   });
                        //   if (counter.count2 == 0) {
                        //     timer.cancel();
                        //     stillGotTime = false;
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
                    var now = DateTime.now();
                    var year = now.year.toString();
                    var month = now.month < 10
                        ? "0" + now.month.toString()
                        : now.month.toString();
                    var day = now.day < 10
                        ? "0" + now.day.toString()
                        : now.day.toString();
                    var datetime = year + month + day;
                    getStartTimeTxt(widget.agentId, datetime);
                  }
                  if (consoleMessage.message
                          .contains("in mystopRecording now") ||
                      consoleMessage.message
                          .contains("in finalstopRecording now")) {
                    count++;
                  }
                  if (consoleMessage.message.contains("錄影結束")) {
                    recordEnd = true;
                    var now = DateTime.now();
                    var year = now.year.toString();
                    var month = now.month < 10
                        ? "0" + now.month.toString()
                        : now.month.toString();
                    var day = now.day < 10
                        ? "0" + now.day.toString()
                        : now.day.toString();
                    var datetime = year + month + day;
                    getStopTimeTxt(widget.agentId, datetime);
                    await EasyLoading.showSuccess("錄影結束，請稍等影片處理...",
                        duration: Duration(milliseconds: 2000));
                    await EasyLoading.show(
                      status: '正在處理對保影片，請稍候...',
                      maskType: EasyLoadingMaskType.black,
                    );
                  }
                  // if (consoleMessage.message.contains("很抱歉，我們無法和您建立視訊連結")) {
                  //   _showMyDialog("無法建立視訊", "很抱歉，我們無法和您建立視訊連結");
                  // }
                },
              ),
            ],
          ),
        ),
      ]))),
    );
  }

  var startTime;
  var countFileName;
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
    print("${output.path}/${fileName}.${yourExtension}");
    _handleFileUpload([file.path]);
    uploadFilePath = file.path;
    // File(file.path).deleteSync();
  }

  void _handleFileUpload(List<String> paths) async {
    print("now is file uploading...");
    uploadCount++;
    final prefs = await SharedPreferences.getInstance();
    final binary = prefs.getBool('binary') ?? false;
    await widget.uploader
        .enqueue(_buildUpload(
      binary,
      paths.whereType<String>().toList(),
    ))
        .whenComplete(() {
      if (recordEnd) {
        totalTask = _tasks.length;
        print("總共錄了 ${count}個檔案");
        getTotalFileCount(widget.agentId);
      }
    });
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
                field: 'file',
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
    userId = userList.first.id;
    if (userId.toString().length == 11) {
      userId = userId.toString().substring(0, 10);
    }
  }

  Future getTotalFileCount(String fileName) async {
    var now = DateTime.now();
    var year = now.year.toString();
    var month =
        now.month < 10 ? "0" + now.month.toString() : now.month.toString();
    var day = now.day < 10 ? "0" + now.day.toString() : now.day.toString();
    var datetime = year + month + day;
    fileName =
        fileName + '-' + userId + "-" + datetime + "-customerFileCount.txt";
    HttpUtils().createTxtFile(fileName, count.toString());
  }

  Future getStartTimeTxt(String fileName, String timeStamp) async {
    List<User> userList = await UserDao.instance.readAllNotes();
    var userId = userList.first.id.toString();
    if (userId.length == 11) {
      userId = userId.substring(0, 10);
    }
    fileName =
        fileName + '-' + userId + "-" + timeStamp + "-recordStartTime.txt";
    countFileName = fileName;
    var now = DateTime.now();
    this.startTime = now;
    HttpUtils().createTxtFile(fileName, now.toString());
  }

  Future getStopTimeTxt(String fileName, String timeStamp) async {
    List<User> userList = await UserDao.instance.readAllNotes();
    var userId = userList.first.id.toString();
    if (userId.length == 11) {
      userId = userId.substring(0, 10);
    }
    fileName =
        fileName + '-' + userId + "-" + timeStamp + "-recordStopTime.txt";
    var now = DateTime.now();
    String totals = now.difference(this.startTime).inSeconds.toString();
    print("here is totalSec" + totals);
    HttpUtils().createTxtFile(fileName, totals);
  }

  Future<void> _showMyDialog(String title, String content) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(content),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('了解'),
              onPressed: () {
                Navigator.pushNamed(context, CustomerOptionsScreen.routeName);
              },
            ),
          ],
        );
      },
    );
  }
}
