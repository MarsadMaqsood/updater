import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
// import 'package:open_file/open_file.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:updater/updater.dart';
import 'package:updater/utils/constants.dart';

class DownloadCore {
  final CancelToken token;
  final ValueNotifier<double> progressNotifier;
  final ValueNotifier<String> progressPercentNotifier, progressSizeNotifier;
  final String url;
  final UpdaterController? controller;
  final Function dismiss;

  DownloadCore({
    required this.url,
    required this.token,
    required this.progressNotifier,
    required this.progressPercentNotifier,
    required this.progressSizeNotifier,
    this.controller,
    required this.dismiss,
  });

  final _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

  bool _isUpdated = false;
  bool _goBackground = false, _isDisposed = false;

  Future<void> startDownload({isResumed = false}) async {
    // var testURL =
    //     'https://firebasestorage.googleapis.com/v0/b/studyproject-242f6.appspot.com/o/Updates%2Fapp-release.apk?alt=media&token=1bb9b6a9-56de-4469-ac5e-1c4494717e36';

    Directory tempDirectory = await directory();

    List<FileSystemEntity> listEntity = tempDirectory.listSync();

    int length = 0;
    String totalLength = await checkSize();

    if (totalLength.isNotEmpty) {
      totalLength = '${int.parse(totalLength) - 1}';
    }

    if (!isResumed) {
      for (FileSystemEntity entity in listEntity) {
        File file = File(entity.path);
        file.deleteSync();
      }
    }

    listEntity = tempDirectory.listSync();

    for (FileSystemEntity entity in listEntity) {
      File file = File(entity.path);
      length = length + file.lengthSync();
    }

    int index = 0;

    if (listEntity.isNotEmpty) {
      index =
          int.tryParse(listEntity.last.path.split('-').last.split('.').first) ??
              0;
    }

    String fileName =
        '${tempDirectory.path}/app${_getRandomString(10)}-${index + 1}.apk';

    await Dio().download(
      url,
      fileName,
      cancelToken: token,
      onReceiveProgress: (progress, totalProgress) {
        // print('$progress ===  $totalProgress');

        if (!_isUpdated) {
          //Update Controller
          _updateController(UpdateStatus.Dowloading);
          _isUpdated = true;
        }

        //Update Controller
        if (controller != null) {
          controller!.setProgress(progress + length, totalProgress + length);
        }

        //Update progress bar value
        if (!_goBackground || !_isDisposed) {
          var percent = (progress + length) * 100 / totalProgress;
          progressNotifier.value = (progress + length) / totalProgress;
          progressPercentNotifier.value = '${percent.toStringAsFixed(2)} %';

          progressSizeNotifier.value =
              '${formatBytes(progress + length, 1)} / ${formatBytes(totalProgress, 1)}';
        }
        if ((progress + length) == totalProgress) {
          //Update Controller
          _updateController(UpdateStatus.Completed);

          //Dismiss the dialog
          if (!_goBackground) dismiss.call();

          //Open the downloaded apk file
          // OpenFile.open('${tempDirectory.path}/app.apk');
          // OpenFilex.open('${tempDirectory.path}/app.apk');
          OpenFilex.open(fileName);
        }

        if (progress == totalProgress && isResumed) {
          _mergeFiles(tempDirectory.path);
        }
        if (progress > totalProgress) {
          token.cancel();

          throw Exception(
              'progress > totalProgress. Please start download instead of resume');
        }
      },
      options: isResumed
          ? Options(
              headers: {
                // 'range': 'bytes=$length-',
                'range': 'bytes=$length-$totalLength',
              },
              responseType: ResponseType.stream,
            )
          : Options(),
      deleteOnError: false,
    );
  }

  Future<void> lastStatus() async {
    Directory tempDirectory = await directory();
    List<FileSystemEntity> listEntity = tempDirectory.listSync();

    int length = 0;

    for (FileSystemEntity entity in listEntity) {
      length = length + File(entity.path).lengthSync();
    }

    String totalLength = await checkSize();

    var percent = length * 100 / int.parse(totalLength);
    progressNotifier.value = length / int.parse(totalLength);
    progressPercentNotifier.value = '${percent.toStringAsFixed(2)} %';

    progressSizeNotifier.value =
        '${formatBytes(length, 1)} / ${formatBytes(int.parse(totalLength), 1)}';
  }

  void dispose() {
    _goBackground = true;
    _isDisposed = true;
  }

  void _updateController(UpdateStatus updateStatus, [e]) {
    if (controller != null) {
      controller!.setValue(updateStatus);

      if (e != null) {
        controller!.setError(token.isCancelled ? 'Download Cancelled \n$e' : e);
      }
    }
  }

  Future<void> _mergeFiles(tempPath) async {
    Directory tempDir = Directory(tempPath);

    List<FileSystemEntity> listEntity = tempDir.listSync();

    File file = File('$tempPath/app_complete_update.apk');
    if (await file.exists()) {
      file.delete();
    }

    List<int> list = [];

    for (FileSystemEntity entity in listEntity) {
      var byte = await File(entity.path).readAsBytes();
      list.addAll(byte);
    }

    await file.writeAsBytes(list);

    // OpenFile.open(file.path);
    OpenFilex.open(file.path);
  }

  void pause() {
    token.cancel();
  }

  void resume() {
    startDownload(isResumed: true);
  }

  Future<Directory> directory() async {
    Directory tempDir = await getTemporaryDirectory();
    Directory updateDir = Directory('${tempDir.path}/Updates/');

    if (!await updateDir.exists()) {
      await updateDir.create();
    }

    return updateDir;
  }

  Future<String> checkSize() async {
    Response response = await Dio().head(url);
    return (response.headers.value(Headers.contentLengthHeader)) ?? '';
  }

  String _getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(Random().nextInt(_chars.length))));
}
