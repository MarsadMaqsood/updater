library updater;

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:updater/model/update_model.dart';
import 'package:updater/src/enums.dart';
import 'package:updater/src/update_dialog.dart';
import 'package:updater/src/controller.dart';
import 'package:updater/utils/constants.dart';
import 'model/version_model.dart';

export 'model/version_model.dart';
export 'src/enums.dart';
export 'src/controller.dart';
export 'model/update_model.dart';

class Updater {
  Updater({
    this.id,
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
    this.enableResume = true,
  }) : assert(url.contains('http') == true, "Update url is not valid!") {
    id ??= getRandomString(8);
  }

  ///Unique id of download process
  String? id;

  ///Build Context
  final BuildContext context;

  ///Json file url to check for update
  final String url;

  ///Allow the dialog to cancel or skip
  /// This also controll the `barrierDismissible` property of dialog
  ///Default is `allowSkip = true`
  bool allowSkip;

  ///Set confirm button text
  final String? confirmText;

  ///Set cancel button text
  final String? cancelText;

  ///Set update dialog title text
  final String? titleText;

  ///Change update dialog content text
  String contentText;

  ///Set rootNavigator value to dismiss dialog
  ///Default is `rootNavigator = true`
  final bool rootNavigator;

  ///set `backgroundDownload` value to show or hide background download button
  ///Default is `backgroundDownload = true`
  final bool? backgroundDownload;

  ///Callback, which returns JSON data
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

  ///Enable or disable resume feature.
  final bool enableResume;

  ///Function to check for update
  Future<bool> check({withDialog = true}) async {
    if (!Platform.isAndroid) return false;

    if (delay != null) await Future.delayed(delay!);

    controller?.setValue(UpdateStatus.Checking);

    http.Response response = await http.get(Uri.parse(url));
    dynamic data = jsonDecode(response.body);

    UpdateModel model = UpdateModel(
      data['url'],
      data['versionName'],
      data['versionCode'],
      data['minSupport'],
      data['contentText'],
    );

    ///Throw exception if provided download url is not valid
    if (!model.downloadUrl.contains('http')) {
      throw Exception(
          'Invalid download url.\nDownload url should contain http / https.');
    }

    ///Update value in callback function
    if (callBack != null) callBack!(model);

    ///Set server value to `contentText` if `contentText` value is empty
    if (contentText.isEmpty) contentText = model.contentText;

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    int buildNumber = int.parse(packageInfo.buildNumber);

    ///Return `false` if current build number is greater
    ///than the update version.
    if (buildNumber >= model.versionCode) {
      _updateAvailable = false;
      return false;
    }

    ///Override the `allowSkip` parameter to `false`
    /// if minimum supported version is greater or equal to the current build number
    if (model.minSupport >= buildNumber) {
      allowSkip = false;
    }

    _updateAvailable = true;

    controller?.setValue(UpdateStatus.Available);

    _downloadUrl = model.downloadUrl;

    if (withDialog) {
      showDialog(
          context: context,
          barrierDismissible: allowSkip,
          builder: (_) {
            return _buildDialog;
          }).then((value) {
        if (value == null) {
          controller?.setValue(UpdateStatus.DialogDismissed);
        }
      });
    }

    return true; // update is available
  }

  // ///Function to resume update
  // Future<void> resume() async {
  //   controller?.setValue(UpdateStatus.Resume);

  //   ///if download url is empty then again check for update.
  //   if (_downloadUrl.isEmpty) {
  //     bool isAvailable = await check(withDialog: false);
  //     if (!isAvailable) {
  //       throw Exception(
  //           'Download Url is empty and no update is currently available');
  //     }
  //   }

  //   _status = UpdateStatus.Paused;

  //   showDialog(
  //       context: context,
  //       barrierDismissible: allowSkip,
  //       builder: (_) {
  //         return _buildDialog;
  //       }).then((value) {
  //     if (value == null) {
  //       _status = UpdateStatus.none;

  //       controller?.setValue(UpdateStatus.DialogDismissed);
  //     }
  //   });
  // }

  // ///Function to resume update
  // void pause() {
  //   if (controller == null) {
  //     _token.cancel();
  //     return;
  //   }
  //   controller?.setValue(UpdateStatus.Paused);
  // }

  // void cancel() {
  //   _status = UpdateStatus.Cancelled;
  //   if (controller == null) {
  //     _token.cancel();
  //     return;
  //   }
  //   controller?.setValue(UpdateStatus.Cancelled);
  // }

  ///App download url
  String _downloadUrl = '';

  ///Current update status
  final UpdateStatus _status = UpdateStatus.none;

  ///Cancel token for canceling [Dio] download.
  final CancelToken _token = CancelToken();

  Widget get _buildDialog => WillPopScope(
        onWillPop: () async {
          return allowSkip;
        },
        child: _buildDialogUI,
      );

  // final bool _dismissOnTouchOutside = true;
  // Future<bool> _onWillPop() async =>
  // allowSkip ? _dismissOnTouchOutside : allowSkip;

  Widget get _buildDialogUI {
    return UpdateDialog(
      context: context,
      id: id!,
      controller: controller,
      titleText: titleText!,
      contentText: contentText,
      confirmText: confirmText,
      cancelText: cancelText,
      rootNavigator: rootNavigator,
      allowSkip: allowSkip,
      downloadUrl: _downloadUrl,
      backgroundDownload: backgroundDownload!,
      elevation: elevation ?? 0,
      status: _status,
      enableResume: enableResume,
      token: _token,
    );
  }

  /// Will return true/false from `check()` if an update is available.
  set _updateAvailable(bool value) {
    // if (controller != null) {
    controller?.setAvailability(value);
    // }
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
