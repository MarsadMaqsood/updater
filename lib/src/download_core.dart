import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class DownloadCore {
  final CancelToken token;

  DownloadCore({required this.token});

  final _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

  void startDownload({isResumed = false, index}) async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = '${tempDir.path}/Updates/';

    var testURL =
        'https://firebasestorage.googleapis.com/v0/b/studyproject-242f6.appspot.com/o/Updates%2Fapp-release.apk?alt=media&token=1bb9b6a9-56de-4469-ac5e-1c4494717e36';

    List<FileSystemEntity> listEntity = tempDir.listSync();

    int length = 0;

    for (FileSystemEntity entity in listEntity) {
      File file = File(entity.path);
      length = await file.length();
      if (!isResumed) {
        file.deleteSync();
      }
    }

    String fileName = '$tempPath/app${index ??= _getRandomString(10)}.apk';

    var response = await Dio().download(
      testURL,
      fileName,
      cancelToken: token,
      onReceiveProgress: (c, t) {
        print('$c ===  $t');

        if (c == t) {
          OpenFile.open(fileName);
          return;
        }
        if (c == t && isResumed) {
          _mergeFiles(tempPath);
        }
      },
      options: isResumed
          ? Options(
              headers: {
                'range': 'bytes=$length-${24390046 - 1}',
              },
              responseType: ResponseType.stream,
            )
          : Options(),
      deleteOnError: false,
    );
  }

  void _mergeFiles(tempPath) async {
    Directory tempDir = Directory(tempPath);

    List<FileSystemEntity> listEntity = tempDir.listSync();

    File file = File('$tempPath/app_complete_update.apk');
    if (await file.exists()) {
      file.delete();
    }

    dynamic bytes;

    for (FileSystemEntity entity in listEntity) {
      bytes = await bytes + File(entity.path).readAsBytes();
    }

    await file.writeAsBytes(bytes);

    OpenFile.open(file.path);
  }

  void pause() {
    token.cancel();
  }

  void resume() {
    startDownload(isResumed: true, index: _getRandomString(10));
  }

  String _getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(Random().nextInt(_chars.length))));
}
