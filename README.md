[![Version](https://img.shields.io/pub/v/updater?color=%2354C92F&logo=dart)](https://pub.dev/packages/updater/install)

A package to check for the custom in-app updates for Flutter.

## ⭐ Installing
```
dependencies:
    updater: ^0.2.4
```

## ⚡ Import 
```
import 'package:updater/updater.dart';
```


|  | Android | IOS |
| --- | --- | --- |
| Supported | ✔️ |  ❌


<img src="https://raw.githubusercontent.com/MarsadMaqsood/AppUpdate/master/assets/image.gif" alt="alt text" width="300" height="620">

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
delay → Duration
enableResume → bool
```

## UpdateStatus
```dart
UpdateStatus.Checking
UpdateStatus.Pending
UpdateStatus.Available
UpdateStatus.Dowloading
UpdateStatus.Paused
UpdateStatus.Resume
UpdateStatus.Cancelled
UpdateStatus.Completed
UpdateStatus.DialogDismissed
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

## ⚙ Setup

<details><summary>Android</summary>

- Add `REQUEST_INSTALL_PACKAGES` permission to open and install apk file

```xml
<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
```


</details>

## 📙 How To Use

Inside `pubspec.yaml` file
```yaml
# Specify version code using +VersionCode
version: 1.0.0+1  #Like here the VersionCode is 1
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


    Updater updater = Updater(
        context: context,
        controller: controller,
        url: 'JSON_FILE_URL',
        titleText: 'Update available',
        // backgroundDownload: false,
        // allowSkip: false,
        contentText:
            'Update your app to the latest version to enjoy new feature.',
        callBack: (UpdateModel model) {

          print(model.versionName);
          print(model.versionCode);
          print(model.contentText);
          
        },
        
        enableResume: false,
    );
    updater.check();
    
    
    //To cancel the download
    //controller.cancel();


    //To pause the download
    //controller.pause();

    //To resume the download
    //controller.resume();

    
    
```



