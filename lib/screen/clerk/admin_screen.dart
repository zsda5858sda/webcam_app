import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

class ClerkPage extends StatefulWidget {
  @override
  _ClerkPage createState() => new _ClerkPage();
}

class _ClerkPage extends State<ClerkPage> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  PullToRefreshController? pullToRefreshController;
  String url = "";
  double progress = 0;
  final urlController = TextEditingController();

  @override
  void initState() {
    super.initState();

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
                initialUrlRequest: URLRequest(
                    url: Uri.parse(
                        "https://vsid.ubt.ubot.com.tw:81/main/Login.html")),
                initialOptions: options,
                pullToRefreshController: pullToRefreshController,
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
                onLoadStart: (controller, url) async {
                  setState(() {
                    this.url = url.toString();
                    urlController.text = this.url;
                  });
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
                    "about"
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
                  setState(() {
                    this.url = url.toString();
                    urlController.text = this.url;
                  });
                  // if (Platform.isIOS && this.url.contains("Svideocall2.html")) {
                  //   var js =
                  //       "window.addEventListener('flutterInAppWebViewPlatformReady', function(event) {window.flutter_inappwebview.callHandler('mySum', 12, 2, 50).then(function(result) {console.log(result);});});";
                  //   var script = UserScript(
                  //       source: js,
                  //       injectionTime:
                  //           UserScriptInjectionTime.AT_DOCUMENT_START);
                  //   await controller.addUserScript(userScript: script);

                  //   controller.addJavaScriptHandler(
                  //       handlerName: "mySum",
                  //       callback: (args) {
                  //         // Here you receive all the arguments from the JavaScript side
                  //         // that is a List<dynamic>
                  //         print("From the JavaScript side:");
                  //         print(args);
                  //         return args
                  //             .reduce((value, element) => value + element);
                  //       });
                  // }

                  // if (this.url.contains("Svideocall2.html")) {
                  //   FlutterScreenRecording.startRecordScreen(
                  //           DateTime.now().toString())
                  //       .then((value) => print("start record"));
                  // }
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
                    urlController.text = this.url;
                  });
                },
                onUpdateVisitedHistory: (controller, url, androidIsReload) {
                  setState(() {
                    this.url = url.toString();
                    urlController.text = this.url;
                  });
                },
                onConsoleMessage: (controller, consoleMessage) {
                  // if (consoleMessage.message.contains("RecordStart")) {
                  //   print(consoleMessage);
                  //   FlutterScreenRecording.startRecordScreen(
                  //           DateTime.now().toString(),
                  //           titleNotification: '開始錄影')
                  //       .then((value) => print("screen record start"));
                  // }
                },
              ), //
              progress < 1.0
                  ? LinearProgressIndicator(value: progress)
                  : Container(),
            ],
          ),
        ),
      ]))),
    );
  }
}
