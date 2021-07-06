import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:webcam_app/screen/app_bar.dart';

class ImagePickerPage extends StatefulWidget {
  const ImagePickerPage({Key? key}) : super(key: key);

  @override
  _ImagePickerPageState createState() => _ImagePickerPageState();
}

class _ImagePickerPageState extends State<ImagePickerPage> {
  List<PickedFile>? _image;
  final picker = ImagePicker();
  Dio dio = Dio();
  Future _getImageFromGallery() async {
    var image = await picker.getMultiImage();
    setState(() {
      _image = image;
    });
    final int num = _image!.length;
    var a = 3;
    for (int i = 0; i < num; i++) {
      Uint8List byteData = await _image![0].readAsBytes();
      List<int> imageData = byteData.buffer.asUint8List();
      a = a + 1;
      var n = a.toString();
      MultipartFile multipartFile = MultipartFile.fromBytes(
        imageData,
        filename: 'work01T-A123456789-' + n + '.jpg',
        contentType: MediaType('image', 'jpg'),
      );
      FormData formData = FormData.fromMap({
        "uploaded_file": multipartFile,
      });
      var url = "https://vsid.ubt.ubot.com.tw:81/uploadpic";
      var response = await dio.post(url, data: formData);
      if (response.statusCode == 200) {
        debugPrint("上傳成功");
        debugPrint(multipartFile.filename);
      } else {
        debugPrint(response.statusMessage);
      }
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
            onPressed: _getImageFromGallery,
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
            onPressed: _getImageFromGallery,
            child: Text('不上傳文件',
                style:
                    TextStyle(color: Colors.red, fontSize: size.width * 0.06)),
            textColor: Colors.white,
            shape: RoundedRectangleBorder(
                side: BorderSide(
                    color: Colors.red, width: 1, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(30)),
          )
        ],
      ),
    );
  }
}
