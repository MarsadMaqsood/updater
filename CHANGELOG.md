## 0.2.0
- Thanks to [gaoshanyu](https://github.com/gaoshanyu) for [#7](https://github.com/MarsadMaqsood/updater/pull/7)
- Fix: [#8](https://github.com/MarsadMaqsood/updater/pull/8)


## 0.1.5
- Updated readme
## 0.1.4
- Added pause and resume support
- Fix: [#5](https://github.com/MarsadMaqsood/updater/pull/5#issue-1407313885) and some other bug

## 0.1.4-experimental-3
- Fix: bug

## 0.1.4-experimental-2
- Fix: issue where downloaded file not opening
- Fix: some other bugs
- Imporved performance

## 0.1.4-experimental-1
- Fix: issue

## 0.1.4-experimental
- Added pause and resume support

## 0.1.3
- Minor bug fixes

## 0.1.2
- Added `controller.cancel();`

## 0.1.1
- Added `getAppVersion()`

## 0.1.0
- Fix: color issue

## 0.0.9
- Performance improvements

## 0.0.8
- Added `delay: ` before checking for an update

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
