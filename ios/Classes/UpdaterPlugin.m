#import "UpdaterPlugin.h"
#if __has_include(<updater/updater-Swift.h>)
#import <updater/updater-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "updater-Swift.h"
#endif

@implementation UpdaterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftUpdaterPlugin registerWithRegistrar:registrar];
}
@end
