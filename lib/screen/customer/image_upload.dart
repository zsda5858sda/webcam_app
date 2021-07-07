import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerPage extends StatefulWidget {
  const ImagePickerPage({Key? key}) : super(key: key);

  @override
  _ImagePickerPageState createState() => _ImagePickerPageState();
}

class _ImagePickerPageState extends State<ImagePickerPage> {
  List<PickedFile>? _imageFileList;

  dynamic _pickImageError;
  final ImagePicker _picker = ImagePicker();
  Dio dio = Dio();
  void _onImageButtonPressed(ImageSource source,
      {BuildContext? context, bool isMultiImage = true}) async {
    if (isMultiImage) {
      try {
        final pickedFileList = await _picker.getMultiImage();
        setState(() {
          _imageFileList = pickedFileList;
        });
        if (null != _imageFileList) {
          final int num = _imageFileList!.length;
          if (num > 5) {
            errorAlert("照片最多上傳五張");
          } else {
            var a = 3;
            for (int i = 0; i < num; i++) {
              Uint8List byteData = await _imageFileList![0].readAsBytes();
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
                successAlert("上傳成功!!");
                debugPrint(multipartFile.filename);
              } else {
                debugPrint(response.statusMessage);
              }
            }
          }
        }
      } catch (e) {
        setState(() {
          _pickImageError = e;
          print(_pickImageError);
        });
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
            onPressed: () {
              _onImageButtonPressed(
                ImageSource.gallery,
                context: context,
                isMultiImage: true,
              );
            },
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
          )
        ],
      ),
    );
  }

  void successAlert(String message) {
    AlertDialog dialog = AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      content: Row(
        children: <Widget>[
          Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 30,
          ),
          Padding(padding: EdgeInsets.only(right: 10)),
          Text(
            message,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: Text(
            "CLOSE",
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => dialog,
    );
  }

  void errorAlert(String message) {
    AlertDialog dialog = AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      content: Row(
        children: <Widget>[
          Icon(
            Icons.cancel_rounded,
            color: Colors.red,
            size: 30,
          ),
          Padding(padding: EdgeInsets.only(right: 10)),
          Text(
            message,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: Text(
            "CLOSE",
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => dialog,
    );
  }
}
