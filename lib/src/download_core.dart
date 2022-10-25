import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:updater/updater.dart';
import 'package:updater/utils/constants.dart';

class DownloadCore {
  final String id;
  final String url;
  CancelToken token;
  final ValueNotifier<double> progressNotifier;
  final ValueNotifier<String> progressPercentNotifier, progressSizeNotifier;

  final UpdaterController? controller;
  final Function dismiss;

  DownloadCore({
    required this.id,
    required this.url,
    required this.token,
    required this.progressNotifier,
    required this.progressPercentNotifier,
    required this.progressSizeNotifier,
    this.controller,
    required this.dismiss,
  });

  bool _isUpdated = false;
  bool _isDisposed = false;

  Future<void> startDownload({isResumed = false}) async {
    Directory tempDirectory = await directory();

    List<FileSystemEntity> listEntity = tempDirectory.listSync();

    int downloadedLength = 0;

    String totalLength = await checkFileSize();

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
      downloadedLength = downloadedLength + file.lengthSync();
    }

    int index = 0;

    if (listEntity.isNotEmpty) {
      index =
          int.tryParse(listEntity.last.path.split('-').last.split('.').first) ??
              0;
    }

    String fileName = '${tempDirectory.path}/app$id-${index + 1}.apk';

    // String fileName =
    //     '${tempDirectory.path}/app${getRandomString(10)}-${index + 1}.apk';
    i++;
    try {
      // printInfo(i);
      await Dio().download(
        url,
        fileName,
        cancelToken: token,
        onReceiveProgress: (currentProgress, totalProgress) {
          // printInfo('$currentProgress ===  $totalProgress');

          if (!_isUpdated) {
            controller?.setValue(UpdateStatus.Dowloading);
            _isUpdated = true;
          }

          controller?.setProgress(currentProgress + downloadedLength,
              totalProgress + downloadedLength);

          // if (!_goBackground || !_isDisposed) {
          if (!_isDisposed) {
            double progress = (currentProgress + downloadedLength) /
                (totalProgress + downloadedLength);

            double percent = progress * 100;

            progressNotifier.value = progress;
            progressPercentNotifier.value = '${percent.toStringAsFixed(2)} %';

            progressSizeNotifier.value =
                '${formatBytes(currentProgress + downloadedLength, 1)} / ${formatBytes((totalProgress + downloadedLength), 1)}';
          }

          ///Current progress + old progress (the bytes already downloaded)
          if ((currentProgress + downloadedLength) == totalProgress) {
            //Update Controller
            controller?.setValue(UpdateStatus.Completed);

            //Dismiss the dialog
            if (!_isDisposed) dismiss.call();

            //Open the downloaded apk file
            // OpenFilex.open('${tempDirectory.path}/app.apk');
            OpenFilex.open(fileName);
          }

          if (currentProgress == totalProgress && isResumed) {
            controller?.setValue(UpdateStatus.Completed);
            dismiss.call();
            _mergeFiles(tempDirectory);
          }

          if (currentProgress > totalProgress) {
            token.cancel();

            throw Exception(
                'progress > totalProgress. Please start download instead of resume.');
          }
        },
        options: isResumed
            ? Options(
                headers: {
                  'range': 'bytes=$downloadedLength-',
                  // 'range': 'bytes=$downloadedLength-$totalLength',
                },
                responseType: ResponseType.stream,
              )
            : Options(),
        deleteOnError: false,
      );
    } catch (e) {
      // printInfo(i);
      printError(e);
    }
  }

  int i = 0;

  Future<void> lastDownloadProgress() async {
    Directory tempDirectory = await directory();
    List<FileSystemEntity> listEntity = tempDirectory.listSync();

    int length = 0;

    for (FileSystemEntity entity in listEntity) {
      length = length + File(entity.path).lengthSync();
    }

    String totalLength = await checkFileSize();
    if (totalLength.isEmpty) totalLength = '0';

    var percent = length * 100 / int.parse(totalLength);
    progressNotifier.value = length / int.parse(totalLength);
    progressPercentNotifier.value = '${percent.toStringAsFixed(2)} %';

    progressSizeNotifier.value =
        '${formatBytes(length, 1)} / ${formatBytes(int.parse(totalLength), 1)}';
  }

  void dispose() {
    // _goBackground = true;
    _isDisposed = true;
  }

  Future<void> _mergeFiles(Directory tempDir) async {
    List<FileSystemEntity> listEntity = tempDir.listSync();

    File file = File('${tempDir.path}/app_complete_update.apk');
    if (await file.exists()) {
      await file.delete();
    }

    List<int> list = [];

    for (FileSystemEntity entity in listEntity) {
      var byte = await File(entity.path).readAsBytes();
      list.addAll(byte);
    }

    await file.writeAsBytes(
      list,
    );

    // OpenFile.open(file.path);
    OpenFilex.open(file.path);
  }

  void cancel() {
    token.cancel();
    dispose();
    dismiss.call();
  }

  void pause() {
    token.cancel();
    // token = CancelToken();
  }

  void resume() {
    if (_isDisposed) {
      throw Exception(
          'Download is canceled. Start the download again and pause instead of cancel to resume.');
    }
    token = CancelToken();
    startDownload(isResumed: true);
  }

  Future<Directory> directory() async {
    Directory tempDir = await getTemporaryDirectory();
    Directory updateDirctory = Directory('${tempDir.path}/Updater/');

    if (!await updateDirctory.exists()) {
      await updateDirctory.create();
    }

    return updateDirctory;
  }

  Future<String> checkFileSize() async {
    try {
      Response response = await Dio().head(url);
      return (response.headers.value(Headers.contentLengthHeader)) ?? '';
    } catch (e) {
      return '';
    }
  }
}
