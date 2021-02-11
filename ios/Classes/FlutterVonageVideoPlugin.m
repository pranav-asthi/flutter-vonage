#import "FlutterVonageVideoPlugin.h"
#if __has_include(<flutter_vonage_video/flutter_vonage_video-Swift.h>)
#import <flutter_vonage_video/flutter_vonage_video-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_vonage_video-Swift.h"
#endif

@implementation FlutterVonageVideoPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterVonageVideoPlugin registerWithRegistrar:registrar];
}
@end
