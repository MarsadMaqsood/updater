import 'package:flutter/material.dart';
import 'package:updater/updater.dart';

void main() {
  runApp(const AppMain());
}

class AppMain extends StatelessWidget {
  const AppMain({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Test",
      home: MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  dynamic version;

  late UpdaterController controller;
  late Updater updater;

  @override
  void initState() {
    super.initState();
    initializeUpdater();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: TextButton(
                onPressed: () async {
                  VersionModel model = await getAppVersion();
                  setState(() {
                    version = '${model.version}.${model.buildNumber}';
                  });
                },
                child: Text(version ?? 'Get App Version'),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  checkUpdate();
                },
                child: const Text('Check For Update'),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () {
                  updater.resume();
                },
                child: const Text('Resume'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void initializeUpdater() {
    controller = UpdaterController(
      listener: (UpdateStatus status) {
        debugPrint('Listener: $status');
      },
      onChecked: (bool isAvailable) {
        debugPrint('$isAvailable');
      },
      progress: (current, total) {
        // debugPrint('Progress: $current -- $total');
      },
      onError: (status) {
        debugPrint('Error: $status');
      },
    );

    updater = Updater(
      context: context,
      delay: const Duration(milliseconds: 300),
      url:
          'https://firebasestorage.googleapis.com/v0/b/studyproject-242f6.appspot.com/o/Updates%2Fstable.json?alt=media&token=d86751ca-60db-416b-84f8-7f796c86efc6',
      // url: 'https://codingwithmarsad.web.app/updater.json',
      titleText: 'Stay with time',
      // backgroundDownload: false,
      allowSkip: true,
      contentText:
          'Update your app to the latest version to enjoy new feature.',
      callBack: (UpdateModel model) {
        debugPrint(model.versionName);
        debugPrint(model.versionCode.toString());
        debugPrint(model.contentText);
      },
      enableResume: false,
      controller: controller,
    );
  }

  checkUpdate() async {
    bool isAvailable = await updater.check();

    debugPrint('$isAvailable');

    // ///e.g: Cancel downloading after 5 secounds of downloading
    Future.delayed(const Duration(seconds: 5), () {
      // controller.cancel();
    });
  }
}
