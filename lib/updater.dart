library updater;

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:updater/src/enums.dart';
import 'package:updater/src/update_dialog.dart';
import 'package:updater/src/controller.dart';

export 'src/enums.dart';
export 'src/controller.dart';

class Updater {
  Updater({
    required this.context,
    required this.url,
    this.controller,
    this.allowSkip = true,
    this.confirmText = 'Update',
    this.cancelText = 'Next Time',
    this.titleText = 'Update Available',
    this.contentText = '',
    this.rootNavigator = true,
    this.callBack,
    this.backgroundDownload = true,
    this.elevation,
    this.delay,
  }) : assert(url.contains('http') == true, "Update url is not valid!");

  ///Build Context
  final BuildContext context;

  ///Json file url to check for update
  final String url;

  ///Allow the dialog to cancel or skip
  ///Default is `allowSkip = true`
  bool allowSkip;

  ///Set confirm button text
  final String? confirmText;

  ///Set cancel button text
  final String? cancelText;

  ///Set update dialog title text
  final String? titleText;

  ///Set update dialog content text
  String? contentText;

  ///Set rootNavigator value to dismiss dialog
  ///Default is `rootNavigator = true`
  final bool rootNavigator;

  ///set `backgroundDownload` value to show or hide background download button
  ///Default is `backgroundDownload = true`
  final bool? backgroundDownload;

  ///Callback which return json data
  ///
  ///`String versionName`, `int versionCode`, `String contentText`, `int minSupport`, `String downloadUrl`
  ///
  ///```dart
  ///.callback(String versionName,
  ///     int versionCode,
  ///     String contentText,
  ///     int minSupport,
  ///     String downloadUrl){
  ///
  ///}
  ///```
  Function(String versionName, int versionCode, String contentText,
      int minSupport, String downloadUrl)? callBack;

  ///UpdaterController to handle callbacks
  ///
  /// `listener ` will return the [UpdateStatus]
  ///
  /// `progress` will return the  download progress
  ///
  /// `onError` will return the error traces.
  ///
  /// `onChecked` will return true or false based on update available or not
  final UpdaterController? controller;

  ///Add elevation to dialog
  final double? elevation;

  ///This will add delay when checking for an update
  final Duration? delay;

  /// Will return true/false from check() if an update is available
  bool updateAvailable = false;

  ///Function to check for update
  Future<bool> check() async {
    if (delay != null) await Future.delayed(delay!);

    _updateController(UpdateStatus.Checking);

    var response = await http.get(Uri.parse(url));

    var data = jsonDecode(response.body);

    String contentTxt = data['contentText'];
    int versionCodeNew = data['versionCode'];
    String downloadUrl = data['url'];
    int minSupportVersion = data['minSupport'];

    if (callBack != null) {
      callBack!(data['versionName'], versionCodeNew, contentTxt,
          minSupportVersion, downloadUrl);
    }

    if (contentText == '') {
      contentText = contentTxt;
    }

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    int buildNumber = int.parse(packageInfo.buildNumber);

    if (minSupportVersion >= buildNumber) {
      allowSkip = false;
    }

    if (buildNumber < versionCodeNew && downloadUrl.contains('http')) {
      _updateAvailable(true);
      _updateController(UpdateStatus.Available);

      _downloadUrl = downloadUrl;

      showDialog(
          context: context,
          barrierDismissible: allowSkip,
          builder: (_) {
            return _buildDialog;
          }).then((value) {
        if (value == null) {
          _updateController(UpdateStatus.DialogDismissed);
        }
      });

      return true; // update is available
    }
    _updateAvailable(false);
    return false; // no update is available
  }

  late String _downloadUrl;

  Widget get _buildDialog =>
      WillPopScope(onWillPop: _onWillPop, child: _buildDialogUI());

  final bool _dismissOnTouchOutside = true;
  Future<bool> _onWillPop() async =>
      allowSkip ? _dismissOnTouchOutside : allowSkip;

  _buildDialogUI() {
    return UpdateDialog(
      context: context,
      controller: controller,
      titleText: titleText!,
      contentText: contentText!,
      confirmText: confirmText,
      cancelText: cancelText,
      rootNavigator: rootNavigator,
      allowSkip: allowSkip,
      downloadUrl: _downloadUrl,
      backgroundDownload: backgroundDownload!,
      elevation: elevation ?? 0,
    );
  }

  _updateController(UpdateStatus updateStatus) {
    if (controller != null) {
      controller!.setValue(updateStatus);
    }
  }

  _updateAvailable(bool value) {
    if (controller != null) {
      controller!.setAvailability(value);
    }
  }
}
