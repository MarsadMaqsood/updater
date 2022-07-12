import 'package:flutter/material.dart';
import 'package:updater/src/core.dart';
import 'package:updater/src/enums.dart';

class UpdaterController extends ChangeNotifier with Download {
  UpdaterController({
    this.listener,
    this.onChecked,
    this.progress,
    this.onError,
  });

  ///Return [UpdateStatus] whenever new event trigger
  ///
  ///[UpdateStatus.Checking] when checking for an update
  ///
  ///[UpdateStatus.Available] when an update is available
  ///
  ///[UpdateStatus.Pending] when an update is preparing to download
  ///
  ///[UpdateStatus.Dowloading] when an update starts downloading
  ///
  ///[UpdateStatus.Completed] when the update is downloaded and ready to install
  ///
  ///[UpdateStatus.DialogDismissed] when update dialog dismissed
  ///
  ///[UpdateStatus.Cancelled] when an update is downloading and canceled
  ///
  ///[UpdateStatus.Failed] when there is an error that stoped the update to download
  void Function(UpdateStatus status)? listener;

  ///Return true/false based on update available or not
  void Function(bool isAvailable)? onChecked;

  ///Retrun download progress
  ///
  ///
  ///```
  /// progress: (int current, int total) {
  ///   debugPrint('Progress: $current -- $total');
  /// },
  ///
  ///```
  void Function(int current, int total)? progress;

  ///Return error
  void Function(Object status)? onError;

  ///Cancel the current download
  // ValueNotifier isCanceled = ValueNotifier(false);

  void cancel() {
    // isCanceled.value = true;
    status = DownloadStatus.isCanceled;
    notifyListeners();
  }

  void pause() {
    status = DownloadStatus.isPaused;
    notifyListeners();
  }

  void resume() {
    status = DownloadStatus.isResumed;
    notifyListeners();
  }

  void setValue(UpdateStatus status) {
    if (listener != null) listener!(status);
    notifyListeners();
  }

  void setAvailability(bool isAvailable) {
    if (onChecked != null) {
      onChecked!(isAvailable);

      notifyListeners();
    }
  }

  void setProgress(current, total) {
    if (progress != null) progress!(current, total);
    notifyListeners();
  }

  void setError(error) {
    if (onError != null) onError!(error);
    notifyListeners();
  }

  @override
  void dispose() {
    listener = null;
    progress = null;
    onError = null;
    super.dispose();
  }
}
