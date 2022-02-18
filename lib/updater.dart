library updater;

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
  final bool? rootNavigator;

  ///set backgroundDownload value to show or hide background download button
  ///Default is `backgroundDownload = true`
  final bool? backgroundDownload;

  ///Callback which return json data
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
  /// Like `listener ` which will return [UpdateStatus]
  /// `progress` return download progress
  ///  `onError` will return error traces.
  final UpdaterController? controller;

  ///Add elevation to dialog
  final double? elevation;

  /// Will return true/false from check() if an update is available
  bool updateAvailable = false;
  
  ///Function to check for update
  check() async {
    if (this.controller != null)
      this.controller!.setValue(UpdateStatus.Checking);

    var response = await http.get(Uri.parse(url));

    var data = jsonDecode(response.body);

    String contentTxt = data['contentText'];
    int versionCodeNew = data['versionCode'];
    String downloadUrl = data['url'];
    int minSupportVersion = data['minSupport'];

    if (callBack != null)
      callBack!(data['versionName'], versionCodeNew, contentTxt,
          minSupportVersion, downloadUrl);

    if (contentText == '') {
      contentText = contentTxt;
    }

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    int buildNumber = int.parse(packageInfo.buildNumber);

    if (minSupportVersion >= buildNumber) {
      allowSkip = false;
    }

    if (buildNumber < versionCodeNew && downloadUrl.contains('http')) {
      if (controller != null) controller!.setValue(UpdateStatus.Checking);
      _downloadUrl = downloadUrl;
      showDialog(
          context: context,
          barrierDismissible: this.allowSkip,
          builder: (_) {
            return _buildDialog;
          });
		return true; // update is available
    }
	return false; // no update is available
  }

  late String _downloadUrl;

  Widget get _buildDialog =>
      WillPopScope(onWillPop: _onWillPop, child: _buildDialogUI());

  bool _dismissOnTouchOutside = true;
  Future<bool> _onWillPop() async =>
      allowSkip ? this._dismissOnTouchOutside : allowSkip;

  _buildDialogUI() {
    return UpdateDialog(
      context: this.context,
      controller: this.controller ?? null,
      titleText: this.titleText!,
      contentText: this.contentText!,
      confirmText: this.confirmText,
      cancelText: this.cancelText,
      rootNavigator: this.rootNavigator ?? true,
      allowSkip: allowSkip,
      downloadUrl: _downloadUrl,
      backgroundDownload: backgroundDownload!,
      elevation: elevation ?? 0,
    );
  }
}
