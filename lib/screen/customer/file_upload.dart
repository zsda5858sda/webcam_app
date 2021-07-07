import 'package:flutter/material.dart';
import 'package:webcam_app/screen/customer/image_upload.dart';

class FileUpload extends StatelessWidget {
  const FileUpload({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF63BED0),
      body: ImagePickerPage(),
    );
  }
}
