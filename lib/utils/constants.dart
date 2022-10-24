import 'dart:math';

import 'package:flutter/rendering.dart';

String formatBytes(int bytes, int decimals) {
  if (bytes <= 0) return "0 B";
  const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
  var i = (log(bytes) / log(1024)).floor();
  return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
}

String getRandomString(int length) {
  const chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  return String.fromCharCodes(Iterable.generate(
      length, (_) => chars.codeUnitAt(Random().nextInt(chars.length))));
}

void printError(dynamic text) {
  debugPrint('\x1B[31m${text.toString()}\x1B[0m');
}

void printWarning(dynamic text) {
  debugPrint('\x1B[33m${text.toString()}\x1B[0m');
}

void printInfo(dynamic text) {
  debugPrint('\x1B[37m${text.toString()}\x1B[0m');
}
