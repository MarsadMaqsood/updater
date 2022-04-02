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
  UpdaterController controller = UpdaterController(
    listener: (UpdateStatus status) {
      print('Listener: $status');
    },
    onChecked: (bool isAvailable) {
      print(isAvailable);
    },
    progress: (current, total) {
      print('Progress: $current -- $total');
    },
    onError: (status) {
      print('Error: $status');
    },
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () {
              checkUpdate();
            },
            child: const Text('Check For Update'),
          ),
        ),
      ),
    );
  }

  checkUpdate() async {
    bool isAvailable = await Updater(
      context: context,
      delay: const Duration(milliseconds: 300),
      url: 'https://codingwithmarsad.web.app/updater.json',
      titleText: 'Stay with time',
      // backgroundDownload: false,
      // allowSkip: false,
      contentText:
          'Update your app to the latest version to enjoy new feature.',
      // allowSkip: false,
      callBack:
          (versionName, versionCode, contentText, minSupport, downloadUrl) {},
      controller: controller,
    ).check();

    print(isAvailable);
  }
}
