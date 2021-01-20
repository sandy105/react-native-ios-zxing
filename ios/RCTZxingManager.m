
#import "RCTZxingManager.h"
#import <Foundation/Foundation.h>
#import "RCTZxingScanView.h"
#import <React/RCTBridge.h>
#import <React/RCTUIManager.h>
#import <React/RCTEventDispatcher.h>
#import <React/RCTLog.h>
#import <React/RCTUtils.h>
#import <React/UIView+React.h>
@implementation RCTZxingManager
- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE(ZxingScanView);
RCT_EXPORT_VIEW_PROPERTY(onBarCodeRead, RCTDirectEventBlock)

RCT_EXPORT_METHOD(checkVideoAuthorizationStatus:(RCTPromiseResolveBlock)resolve
                  reject:(__unused RCTPromiseRejectBlock)reject) {
    RCTLog(@"checkVideoAuthorizationStatus---");
#ifdef DEBUG
    if (![[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSCameraUsageDescription"]) {
        RCTLogWarn(@"Checking video permissions without having key 'NSCameraUsageDescription' defined in your Info.plist. If you do not add it your app will crash when being built in release mode. You will have to add it to your Info.plist file, otherwise RNCamera is not allowed to use the camera.  You can learn more about adding permissions here: https://stackoverflow.com/a/38498347/4202031");
        resolve(@(NO));
        return;
    }
#endif
    __block NSString *mediaType = AVMediaTypeVideo;
    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
        resolve(@(granted));
    }];
}
RCT_EXPORT_METHOD(checkRecordAudioAuthorizationStatus:(RCTPromiseResolveBlock)resolve
                  reject:(__unused RCTPromiseRejectBlock)reject) {
    if (![[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSMicrophoneUsageDescription"]) {
        RCTLogWarn(@"Checking audio permissions without having key 'NSMicrophoneUsageDescription' defined in your Info.plist. Audio Recording for your video files is therefore disabled. If you do not need audio on your recordings is is recommended to set the 'captureAudio' property on your component instance to 'false', otherwise you will have to add the key 'NSMicrophoneUsageDescription' to your Info.plist. If you do not your app will crash when being built in release mode. You can learn more about adding permissions here: https://stackoverflow.com/a/38498347/4202031");
        resolve(@(NO));
        return;
    } else {
#ifdef DEBUG
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            resolve(@(granted));
        }];
#else
        resolve(@(YES));
#endif
    }
}

- (UIView *)view
{
    return [[RCTZxingScanView alloc] init];
}

@end

