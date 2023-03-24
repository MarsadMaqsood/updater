import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:platform/platform.dart';
import 'package:updater/updater.dart';

Updater buildUpdater(BuildContext context) {
  var controller = UpdaterController(
    listener: (UpdateStatus status) {
      debugPrint('Listener: $status');
    },
    onChecked: (bool isAvailable) {
      debugPrint('$isAvailable');
    },
    progress: (current, total) {
      debugPrint('Progress: $current -- $total');
    },
    onError: (status) {
      debugPrint('Error: $status');
    },
  );

  return Updater(
    context: context,
    delay: const Duration(milliseconds: 300),
    url: 'https://example.com/updater.json',
    titleText: 'Stay with time',
    backgroundDownload: false,
    allowSkip: true,
    contentText: 'Update your app to the latest version to enjoy new feature.',
    callBack: (UpdateModel model) {
      debugPrint(model.versionName);
      debugPrint(model.versionCode.toString());
      debugPrint(model.contentText);
    },
    enableResume: true,
    controller: controller,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const packageChannel = MethodChannel('dev.fluttercommunity.plus/package_info');
  final log = <MethodCall>[];

  setUp(() {
    packageChannel.setMockMethodCallHandler((MethodCall methodCall) async {
      log.add(methodCall);
      switch (methodCall.method) {
        case 'getAll':
          return <String, dynamic>{
            'appName': 'updater',
            'buildNumber': '1',
            'packageName': 'io.flutter.plugins.updaterexample',
            'version': '1.0',
            'installerStore': null,
          };
        default:
          assert(false);
          return null;
      }
    });
  });

  test('Should get app version', () async {
    VersionModel model = await getAppVersion();
    String version = '${model.version}.${model.buildNumber}';
    expect(version, '1.0.1');
    expect(
      log,
      <Matcher>[
        isMethodCall('getAll', arguments: null),
      ],
    );
  });

  testWidgets('Should display updater with Android platform', (WidgetTester tester) async {
    Updater.platform = FakePlatform(operatingSystem: Platform.android);
    bool? isAvailable;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Builder(builder: (BuildContext context) {
            return TextButton(
              onPressed: () async {
                isAvailable = await buildUpdater(context).check();
                debugPrint('$isAvailable');
              },
              child: const Text('Get App Version'),
            );
          }),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    var buttonFinder = find.widgetWithText(TextButton, 'Get App Version');
    expect(buttonFinder, findsOneWidget);
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();
    expect(find.text('Stay with time'), findsOneWidget);
    // expect(isAvailable, false);
  });

  testWidgets('Should not display updater without Android platform', (WidgetTester tester) async {
    bool? isAvailable;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Builder(builder: (BuildContext context) {
            return TextButton(
              onPressed: () async {
                isAvailable = await buildUpdater(context).check();
                debugPrint('$isAvailable');
              },
              child: const Text('Get App Version'),
            );
          }),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    var buttonFinder = find.widgetWithText(TextButton, 'Get App Version');
    expect(buttonFinder, findsOneWidget);
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();
    expect(isAvailable, false);
  });

  tearDown(() {
    log.clear();
  });
}
