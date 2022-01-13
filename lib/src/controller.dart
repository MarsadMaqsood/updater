import 'package:flutter/material.dart';
import 'package:updater/src/enums.dart';

class UpdaterController extends ChangeNotifier {
  UpdaterController({
    this.listener,
    this.progress,
    this.onError,
  });

  Function(UpdateStatus status)? listener;
  Function(int current, int total)? progress;
  Function(Object status)? onError;

  setValue(UpdateStatus status) {
    if (listener != null) listener!(status);
    notifyListeners();
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
