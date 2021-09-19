library updater;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:updater/src/update_dialog.dart';

class Updater {
  Updater({
    required this.url,
    required this.context,
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
  final bool? rootNavigator;

  final bool? backgroundDownload;

  ///Callback which return json data
  Function(String versionName, int versionCode, String contentText,
      int minSupport, String downloadUrl)? callBack;

  ///Add elevation to dialog
  final double? elevation;

  ///Function to check for update
  check() async {
    var response = await http.get(Uri.parse(url));

    var data = jsonDecode(response.body);

    String contentTxt = data['contentText'];
    int versionCodeNew = data['versionCode'];
    String downloadUrl = data['url'];

    if (callBack != null)
      callBack!(data['versionName'], versionCodeNew, contentTxt,
          data['minSupport'], downloadUrl);

    if (contentText == '') {
      contentText = contentTxt;
    }

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    int buildNumber = int.parse(packageInfo.buildNumber);

    if (buildNumber < versionCodeNew && downloadUrl.contains('http')) {
      _downloadUrl = downloadUrl;
      showDialog(
          context: context,
          barrierDismissible: this.allowSkip,
          builder: (_) {
            return _buildDialog;
          });
    }
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
