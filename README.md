[![Version](https://img.shields.io/pub/v/updater?color=%2354C92F&logo=dart)](https://pub.dev/packages/updater/install)

A package to check for the custom in-app updates for Flutter.

## ⭐ Installing
```
dependencies:
    updater: ^0.0.6
```

## ⚡ Import 
```
import 'package:updater/updater.dart';
```

<img src="https://github.com/MarsadMaqsood/AppUpdate/blob/master/assets/image.gif" alt="alt text" width="300" height="620">

## Properties

```dart
context → BuildContext
url → String
titleText → String
contentText → String
confirmText → String
cancelText → String
elevation → double
rootNavigator → bool
allowSkip → bool
backgroundDownload → bool
callBack → Function(String, int, String, int String)
controller → UpdaterController
```

## UpdateStatus
```dart
UpdateStatus.Checking
UpdateStatus.Available
UpdateStatus.DialogDismissed
UpdateStatus.Pending
UpdateStatus.Dowloading
UpdateStatus.Completed
UpdateStatus.Cancelled
UpdateStatus.Failed
```

## Json Structure

```dart
versionCode → int
versionName → String
minSupport → int
contentText → String
url → String 
```

```json
{
  "versionCode":3,
  "versionName":"1.0.0",
  "contentText":"Please update your app",
  "minSupport":2,
  "url":"/*App Download Url*/"
}
```

```
versionCode:   //Specify new version code
versionName:   //specify version name
minSuppor:     //specify minimum supported version to force update
contentText:   //specify content text, if contentText is not defined in app then this will be use
url:          //App file download link
```

## 📙 How To Use

Inside `pubspec.yaml` file
```yaml
# Specify version code using +VersionCode
version: 0.0.3+1  #Like here the VersionCode is 1
```

```dart
    //Controller
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

    Updater(
        context: context,
        url: 'JSON_FILE_URL',
        titleText: 'Update available',
        // backgroundDownload: false,
        // allowSkip: false,
        contentText:
            'Update your app to the latest version to enjoy new feature.',
        // allowSkip: false,
        callBack: (verName, verCode, contentText, minSupport, downloadUrl) {
          print(
              '$verName - $verCode - $contentText - $minSupport - $downloadUrl');
        },
        controller: controller,
    ).check();
```