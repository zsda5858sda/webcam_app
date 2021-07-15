import 'package:flutter/material.dart';

import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:webcam_app/screen/upload/upload_item.dart';

typedef CancelUploadCallback = Future<void> Function(String id);

class UploadItemView extends StatelessWidget {
  final UploadItem item;
  final CancelUploadCallback onCancel;

  UploadItemView({
    Key? key,
    required this.item,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                item.id,
                style: Theme.of(context)
                    .textTheme
                    .caption!
                    .copyWith(fontFamily: 'monospace'),
              ),
              Container(
                height: 5.0,
              ),
              Text(item.status!.description),
              Container(height: 5.0),
              if (item.status == UploadTaskStatus.running)
                LinearProgressIndicator(value: item.progress!.toDouble() / 100),
              if (item.status == UploadTaskStatus.complete ||
                  item.status == UploadTaskStatus.failed) ...[
                Text('HTTP status code: ${item.response!.statusCode}'),
                if (item.response!.response != null)
                  Text(
                    item.response!.response!,
                    style: Theme.of(context)
                        .textTheme
                        .caption!
                        .copyWith(fontFamily: 'monospace'),
                  ),
              ]
            ],
          ),
        ),
        if (item.status == UploadTaskStatus.running)
          Container(
            height: 50,
            width: 50,
            child: IconButton(
              icon: Icon(Icons.cancel),
              onPressed: () => onCancel(item.id),
            ),
          )
      ],
    );
  }
}
