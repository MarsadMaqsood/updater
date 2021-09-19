import 'package:flutter/material.dart';
import 'package:updater/updater.dart';

void main() {
  runApp(AppMain());
}

class AppMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () {
              checkUpdate();
            },
            child: Text('Check For Update'),
          ),
        ),
      ),
    );
  }

  checkUpdate() {
    Updater(
      context: context,
      url: 'https://codingwithmarsad.web.app/update.json',
      titleText: 'Stay with time',
      // backgroundDownload: false,
      // allowSkip: false,
      contentText:
          'Update your app to the latest version to enjoy new feature.',
      // allowSkip: false,
    ).check();
  }
}
