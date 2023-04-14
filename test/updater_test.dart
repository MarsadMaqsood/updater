import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:platform/platform.dart';
import 'package:updater/src/api_task.dart';
import 'package:updater/updater.dart';

import 'updater_test.mocks.dart';

@GenerateNiceMocks([MockSpec<Dio>()])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const packageChannel =
      MethodChannel('dev.fluttercommunity.plus/package_info');
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

  testWidgets('Should display updater with Android platform',
      (WidgetTester tester) async {
    MockDio mockDio = MockDio();
    APITask client = APITask();
    when(mockDio.get("https://example.com/updater.json")).thenAnswer((_) =>
        Future(() => Response(
                requestOptions: RequestOptions(
                    path: 'https://codingwithmarsad.web.app/updater.json'),
                data: {
                  "versionCode": 3,
                  "versionName": "1.0.2",
                  "contentText": "Please update your app",
                  "minSupport": 2,
                  "url":
                      "https://www.animatedimages.org/data/media/597/animated-planet-image-0077.gif"
                })));
    client.injectDioForTesting(mockDio);

    Updater.platform = FakePlatform(operatingSystem: Platform.android);
    bool? isAvailable;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Builder(builder: (BuildContext context) {
            return TextButton(
              onPressed: () async {
                isAvailable = await buildUpdater(context).check();
                debugPrint('isAvailable: $isAvailable');
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
    expect(isAvailable, true);
  });

  testWidgets('Should not display updater without Android platform',
      (WidgetTester tester) async {
    Updater.platform = FakePlatform(operatingSystem: Platform.iOS);
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

Updater buildUpdater(BuildContext context) {
  var controller = UpdaterController(
    listener: (UpdateStatus status) {
      debugPrint('UpdaterController Listener: $status');
    },
    onChecked: (bool isAvailable) {
      debugPrint('UpdaterController isAvailable: $isAvailable');
    },
    progress: (current, total) {
      debugPrint('UpdaterController Progress: $current -- $total');
    },
    onError: (status) {
      debugPrint('UpdaterController Error: $status');
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
      debugPrint('model.versionName: ${model.versionName}');
      debugPrint('model.versionCode: ${model.versionCode}');
      debugPrint('model.contentText: ${model.contentText}');
    },
    enableResume: true,
    controller: controller,
  );
}
