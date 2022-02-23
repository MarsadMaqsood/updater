## 0.0.7
- Updated README.md

## 0.0.6
- Android compileSdkVersion updated to 31.
- Added `onChecked` function in `UpdaterController`
- Added `UpdateStatus.Available` and `UpdateStatus.DialogDismissed`
- Improved error handeling
- Fixed some minor issues

## 0.0.5
- `Check()` will return a boolean based on the update is available or not.
```dart
Future<bool> check() async {
    ...
}
```

## 0.0.4
- Added `UpdateStatus` and `UpdaterController` to handle update callbacks
- Improved performance

## 0.0.3
- Fixed minSupport issue.

## 0.0.2+1
- Added support for background download

## 0.0.1
* Initial release.
