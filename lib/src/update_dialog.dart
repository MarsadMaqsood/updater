import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class UpdateDialog extends StatefulWidget {
  UpdateDialog({
    Key? key,
    required this.context,
    required this.titleText,
    required this.contentText,
    required this.rootNavigator,
    required this.allowSkip,
    required this.downloadUrl,
    required this.backgroundDownload,
    this.confirmText,
    this.cancelText,
    required this.elevation,
  }) : super(key: key);

  final BuildContext context;
  final String titleText;
  final String contentText;
  final String? confirmText;
  final String? cancelText;
  final String downloadUrl;
  final bool rootNavigator;
  final bool allowSkip;
  final bool backgroundDownload;
  final double elevation;

  @override
  _UpdateDialogState createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  ValueNotifier<double> progressNotifier = ValueNotifier(0.0);
  ValueNotifier<String> progressPercentNotifier = ValueNotifier('');
  ValueNotifier<String> progressSizeNotifier = ValueNotifier('');
  bool _changeDialog = false;
  var token = CancelToken();
  bool _goBackground = false;

  @override
  void dispose() {
    progressNotifier.dispose();
    progressPercentNotifier.dispose();
    progressSizeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      elevation: widget.elevation,
      backgroundColor: Colors.white,
      child: _changeDialog ? _downloadContent() : _updateContent(),
    );
  }

  Widget _updateContent() {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.allowSkip)
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () {
                  _dismiss();
                },
                icon: Icon(Icons.clear_rounded),
              ),
            ),
          Container(
            child: Text(
              '${widget.titleText}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            alignment: Alignment.center,
          ),
          SizedBox(
            height: 8,
          ),
          // widget.content,
          Container(
            child: Text(
              '${widget.contentText}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            alignment: Alignment.center,
          ),
          SizedBox(
            height: 18,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _changeDialog = true;
                  });
                  _downloadApp();
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(
                      14,
                    ),
                  ),
                  padding: EdgeInsets.only(
                    left: 18,
                    right: 18,
                    top: 12,
                    bottom: 12,
                  ),
                  child: Text(
                    '${widget.confirmText}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (widget.allowSkip)
                InkWell(
                  onTap: () {
                    _dismiss();
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    decoration: BoxDecoration(
                      // color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        14,
                      ),
                    ),
                    padding: EdgeInsets.only(
                      left: 18,
                      right: 18,
                      top: 12,
                      bottom: 12,
                    ),
                    child: Text(
                      '${widget.cancelText}',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _downloadContent() {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Downloading...',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ValueListenableBuilder<String>(
                valueListenable: progressSizeNotifier,
                builder: (context, index, _) {
                  return Text(
                    '$index',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  );
                },
              ),
              ValueListenableBuilder<String>(
                valueListenable: progressPercentNotifier,
                builder: (context, index, _) {
                  return Text(
                    '$index',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  );
                },
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ValueListenableBuilder<double>(
                  valueListenable: progressNotifier,
                  builder: (context, index, _) {
                    return LinearProgressIndicator(
                      value: index == 0.0 ? null : index,
                      backgroundColor: Colors.grey,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    );
                  },
                ),
              ),
              IconButton(
                onPressed: () {
                  token.cancel();
                  _dismiss();
                },
                padding: EdgeInsets.all(6),
                constraints: BoxConstraints(),
                icon: Icon(Icons.clear_rounded),
              ),
            ],
          ),
          SizedBox(
            height: 8,
          ),
          if (widget.backgroundDownload)
            Align(
              alignment: Alignment.bottomRight,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _goBackground = true;
                  });
                  _dismiss();
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(
                      14,
                    ),
                  ),
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 12,
                    bottom: 12,
                  ),
                  child: Text(
                    'Hide',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }

  _dismiss() {
    Navigator.of(context, rootNavigator: widget.rootNavigator).pop();
  }

  _downloadApp() async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;

    try {
      await Dio().download(
        widget.downloadUrl,
        '$tempPath/app.apk',
        cancelToken: token,
        options: Options(
          receiveDataWhenStatusError: false,
        ),
        onReceiveProgress: (progress, totalProgress) {
          if (!_goBackground) {
            var percent = progress * 100 / totalProgress;
            progressNotifier.value = progress / totalProgress;
            progressPercentNotifier.value = '${percent.toStringAsFixed(2)} %';

            progressSizeNotifier.value =
                '${_formatBytes(progress, 1)} / ${_formatBytes(totalProgress, 1)}';
          }
          if (progress == totalProgress) {
            if (!_goBackground) _dismiss();
            OpenFile.open('$tempPath/app.apk');
          }
        },
        deleteOnError: true,
      );
    } catch (e) {
      // print('Error: $e');
      print('Download canceled');
    }
  }

  String _formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) +
        ' ' +
        suffixes[i];
  }
}
