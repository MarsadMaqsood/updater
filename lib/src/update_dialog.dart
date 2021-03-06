import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:updater/src/download_core.dart';
import 'package:updater/src/enums.dart';
import 'package:updater/src/controller.dart';

class UpdateDialog extends StatefulWidget {
  const UpdateDialog({
    Key? key,
    required this.context,
    required this.controller,
    required this.titleText,
    required this.contentText,
    required this.rootNavigator,
    required this.allowSkip,
    required this.downloadUrl,
    required this.backgroundDownload,
    this.confirmText,
    this.cancelText,
    required this.elevation,
    // required this.token,
    this.status = UpdateStatus.Dowloading,
  }) : super(key: key);

  final BuildContext context;
  final String titleText;
  final String contentText;
  final String? confirmText;
  final String? cancelText;
  final String downloadUrl;
  final bool rootNavigator;
  final bool allowSkip;
  final bool backgroundDownload;
  final double elevation;
  final UpdaterController? controller;
  // final CancelToken token;
  final UpdateStatus status;

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  ValueNotifier<double> progressNotifier = ValueNotifier(0.0);
  ValueNotifier<String> progressPercentNotifier = ValueNotifier('');
  ValueNotifier<String> progressSizeNotifier = ValueNotifier('');

  bool _changeDialog = false;
  var token = CancelToken();
  late DownloadCore core;
  late UpdateStatus status;

  @override
  void initState() {
    super.initState();

    status = widget.status;

    core = DownloadCore(
      url: widget.downloadUrl,
      token: token,
      progressNotifier: progressNotifier,
      progressPercentNotifier: progressPercentNotifier,
      progressSizeNotifier: progressSizeNotifier,
      controller: widget.controller,
      dismiss: _dismiss,
    );
    if (widget.status == UpdateStatus.Paused) {
      core.lastStatus();
    }
    listenUpdate();
  }

  @override
  void dispose() {
    core.dispose();
    progressNotifier.dispose();
    progressPercentNotifier.dispose();
    progressSizeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      elevation: widget.elevation,
      backgroundColor: Colors.white,
      child: _changeDialog || status == UpdateStatus.Paused
          ? _downloadContentWidget()
          : _updateContentWidget(),
    );
  }

  Widget _updateContentWidget() {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.allowSkip)
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () {
                  _dismiss();
                },
                icon: const Icon(Icons.clear_rounded),
              ),
            ),
          Container(
            alignment: Alignment.center,
            child: Text(
              widget.titleText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          // widget.content,
          Container(
            alignment: Alignment.center,
            child: Text(
              widget.contentText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(
            height: 18,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _changeDialog = true;
                  });
                  status = UpdateStatus.Dowloading;

                  core.startDownload();

                  // _startDownload();
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(
                      14,
                    ),
                  ),
                  padding: const EdgeInsets.only(
                    left: 18,
                    right: 18,
                    top: 12,
                    bottom: 12,
                  ),
                  child: Text(
                    '${widget.confirmText}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (widget.allowSkip)
                InkWell(
                  onTap: () {
                    _dismiss();
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    decoration: BoxDecoration(
                      // color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        14,
                      ),
                    ),
                    padding: const EdgeInsets.only(
                      left: 18,
                      right: 18,
                      top: 12,
                      bottom: 12,
                    ),
                    child: Text(
                      '${widget.cancelText}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _downloadContentWidget() {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Downloading...',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ValueListenableBuilder<String>(
                valueListenable: progressSizeNotifier,
                builder: (context, index, _) {
                  return Text(
                    index,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  );
                },
              ),
              ValueListenableBuilder<String>(
                valueListenable: progressPercentNotifier,
                builder: (context, index, _) {
                  return Text(
                    index,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  );
                },
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ValueListenableBuilder<double>(
                  valueListenable: progressNotifier,
                  builder: (context, index, _) {
                    return LinearProgressIndicator(
                      value: index == 0.0 ? null : index,
                      backgroundColor: Colors.grey,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.black),
                    );
                  },
                ),
              ),
              IconButton(
                onPressed: () {
                  if (status == UpdateStatus.Resume) {
                    _updateStatus(UpdateStatus.Paused);
                  } else if (status == UpdateStatus.Paused) {
                    _updateStatus(UpdateStatus.Resume);
                  } else if (status == UpdateStatus.Dowloading) {
                    _updateStatus(UpdateStatus.Cancelled);
                  }

                  if (status == UpdateStatus.Resume) {
                    core.resume();
                  } else {
                    // token.cancel();
                    core.pause();
                  }

                  // _dismiss();
                },
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(),
                icon: Icon(status == UpdateStatus.Dowloading
                    ? Icons.clear_rounded
                    : status == UpdateStatus.Resume
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded),
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          if (widget.backgroundDownload)
            Align(
              alignment: Alignment.bottomRight,
              child: InkWell(
                onTap: () {
                  _dismiss();
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(
                      14,
                    ),
                  ),
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 12,
                    bottom: 12,
                  ),
                  child: const Text(
                    'Hide',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }

  _dismiss() {
    Navigator.of(context, rootNavigator: widget.rootNavigator).pop();
  }

  listenUpdate() {
    widget.controller?.addListener(() {
      // if (widget.controller!.isCanceled.value) {
      //   // token.cancel();
      //   core.pause();
      // }
      if (widget.controller!.status == DownloadStatus.isResumed) {
        widget.controller!.status == DownloadStatus.none;
        core.resume();
      }

      if (widget.controller!.status == DownloadStatus.isPaused ||
          widget.controller!.status == DownloadStatus.isCanceled) {
        widget.controller!.status == DownloadStatus.none;
        core.pause();
      }
    });
  }

  void _updateStatus(UpdateStatus newStatus) {
    setState(() {
      status = newStatus;
      if (!_changeDialog) _changeDialog = true;
    });

    if (widget.controller != null) {
      widget.controller!.setValue(newStatus);
    }
  }
}
