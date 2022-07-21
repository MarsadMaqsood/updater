library updater;

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:updater/model/update_model.dart';
import 'package:updater/src/enums.dart';
import 'package:updater/src/update_dialog.dart';
import 'package:updater/src/controller.dart';
import 'model/version_model.dart';

export 'model/version_model.dart';
export 'src/enums.dart' hide DownloadStatus;
export 'src/controller.dart';
export 'model/update_model.dart';

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

  ///Change update dialog content text
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
  ///.callback(UpdateModel model){
  ///   // model.versionName;
  ///   // model.versionCode;
  ///   // model.contentText;
  ///   // model.minSupport;
  ///   // model.downloadUrl;
  ///}
  ///```
  Function(UpdateModel)? callBack;

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

  ///Add elevation to dialog.
  final double? elevation;

  ///This will add delay when checking for an update.
  final Duration? delay;

  ///Function to check for update
  Future<bool> check({withDialog = true}) async {
    if (!Platform.isAndroid) return false;

    if (delay != null) await Future.delayed(delay!);

    _updateController(UpdateStatus.Checking);

    http.Response response = await http.get(Uri.parse(url));
    dynamic data = jsonDecode(response.body);

    UpdateModel model = UpdateModel(
      data['url'],
      data['versionName'],
      data['versionCode'],
      data['minSupport'],
      data['contentText'],
    );

    if (callBack != null) {
      callBack!(model);
    }

    if (contentText == '') {
      contentText = model.contentText;
    }

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    int buildNumber = int.parse(packageInfo.buildNumber);

    if (model.minSupport >= buildNumber) {
      allowSkip = false;
    }

    if (buildNumber < model.versionCode && model.downloadUrl.contains('http')) {
      _updateAvailable(true);
      _updateController(UpdateStatus.Available);

      _downloadUrl = model.downloadUrl;
      if (withDialog) {
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
      }

      return true; // update is available
    }
    _updateAvailable(false);
    return false; // no update is available
  }

  ///Function to resume update
  Future<bool> resume() async {
    if (controller != null) {
      controller!.setValue(UpdateStatus.Resume);
    }

    if (_downloadUrl.isEmpty) {
      await check(withDialog: false);
    }

    _status = UpdateStatus.Paused;

    showDialog(
        context: context,
        barrierDismissible: allowSkip,
        builder: (_) {
          return _buildDialog;
        }).then((value) {
      if (value == null) {
        _status = UpdateStatus.none;
        _updateController(UpdateStatus.DialogDismissed);
      }
    });

    return true;
  }

  ///Function to resume update
  void pause() {
    if (controller != null) {
      controller!.setValue(UpdateStatus.Paused);
    }
  }

  String _downloadUrl = '';
  UpdateStatus _status = UpdateStatus.none;

  // ///Cancel token for canceling [Dio] download.
  // final CancelToken _token = CancelToken();

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
      status: _status,
    );
  }

  _updateController(UpdateStatus updateStatus) {
    if (controller != null) {
      controller!.setValue(updateStatus);
    }
  }

  /// Will return true/false from `check()` if an update is available.
  _updateAvailable(bool value) {
    if (controller != null) {
      controller!.setAvailability(value);
    }
  }
}

///Return the current version of the app
///
///
///```dart
/// VersionModel model = await getAppVersion();
/// print(model.version);
/// print(model.buildNumber);
/// ```
///
Future<VersionModel> getAppVersion() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String version = packageInfo.version;
  String buildNumber = packageInfo.buildNumber;

  return VersionModel(version, buildNumber);
}
