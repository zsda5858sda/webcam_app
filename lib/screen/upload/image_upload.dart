// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:webcam_app/screen/server_behavior.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({
    Key? key,
    required this.uploader,
    required this.uploadURL,
    required this.onUploadStarted,
  }) : super(key: key);

  final FlutterUploader uploader;
  final Uri uploadURL;
  final VoidCallback onUploadStarted;

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  ImagePicker imagePicker = ImagePicker();

  ServerBehavior _serverBehavior = ServerBehavior.defaultOk200;

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) {
      imagePicker.getLostData().then((lostData) {
        if (lostData.isEmpty) {
          return;
        }

        if (lostData.type == RetrieveType.image) {
          _handleFileUpload([lostData.file!.path]);
        }
        if (lostData.type == RetrieveType.video) {
          _handleFileUpload([lostData.file!.path]);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(top: 10, left: 40, right: 40, bottom: 10),
      margin: EdgeInsets.all(20),
      width: size.width * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(30)),
      ),
      child: Column(
        children: <Widget>[
          Container(
              child: Image.asset(
            "assets/images/logo.png",
            height: size.height * 0.2,
            width: size.width * 0.5,
          )),
          SizedBox(
            height: size.height * 0.005,
          ),
          Text(
            "文件上傳說明:",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: size.width * 0.07,
                color: Color(0xFF63BED0)),
          ),
          SizedBox(
            height: size.height * 0.02,
          ),
          Text(
            "請先拍攝文件後再回傳到此頁面上傳文件照片",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: size.width * 0.01,
              fontSize: size.width * 0.05,
            ),
          ),
          SizedBox(
            height: size.height * 0.3,
          ),
          // ignore: deprecated_member_use
          FlatButton(
            minWidth: size.width * 0.5,
            height: size.height * 0.08,
            onPressed: () => getImage(binary: true),
            child: Text('上傳文件(多選)',
                style:
                    TextStyle(color: Colors.blue, fontSize: size.width * 0.06)),
            textColor: Colors.white,
            shape: RoundedRectangleBorder(
                side: BorderSide(
                    color: Colors.blue, width: 1, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(30)),
          ),
          SizedBox(
            height: size.height * 0.02,
          ),
          // ignore: deprecated_member_use
          FlatButton(
            minWidth: size.width * 0.5,
            height: size.height * 0.08,
            onPressed: () {},
            child: Text('不上傳文件',
                style:
                    TextStyle(color: Colors.red, fontSize: size.width * 0.06)),
            textColor: Colors.white,
            shape: RoundedRectangleBorder(
                side: BorderSide(
                    color: Colors.red, width: 1, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(30)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () => widget.uploader.cancelAll(),
                child: Text('Cancel All'),
              ),
              Container(width: 20.0),
              ElevatedButton(
                onPressed: () {
                  widget.uploader.clearUploads();
                },
                child: Text('Clear Uploads'),
              )
            ],
          ),
        ],
      ),
    );
  }

  Future getImage({required bool binary}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('binary', binary);

    var images = await imagePicker.getMultiImage();
    int count = 4;
    if (images!.isNotEmpty) {
      for (PickedFile image in images) {
        String dir = path.dirname(image.path);
        String newPath = path.join(dir, 'work01T-A12345678-$count.jpg');
        count++;
        File(image.path).renameSync(newPath);
        debugPrint(newPath);
        _handleFileUpload([newPath]);
        debugPrint(image.path.toString());
      }
    }
  }

  void _handleFileUpload(List<String> paths) async {
    final prefs = await SharedPreferences.getInstance();
    final binary = prefs.getBool('binary') ?? false;

    await widget.uploader.enqueue(_buildUpload(
      binary,
      paths.whereType<String>().toList(),
    ));

    widget.onUploadStarted();
  }

  Upload _buildUpload(bool binary, List<String> paths) {
    final tag = 'upload';

    var url = widget.uploadURL;

    // if (binary) {
    //   return RawUpload(
    //     url: url.toString(),
    //     path: paths.first,
    //     method: UploadMethod.POST,
    //     tag: tag,
    //   );
    // } else {
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
