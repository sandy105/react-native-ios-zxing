//
//  ZxingScanViewController.h
//  RNIosZxing
//
//  Created by TengYan on 2021/1/19.
//  Copyright © 2021 Facebook. All rights reserved.
//

#import "ZXingObjC/ZXingObjC.h"
#import "RCTZxingManager.h"
#import <UIKit/UIKit.h>
#import <React/RCTEventDispatcher.h>
#import <React/RCTLog.h>
#import <React/RCTUtils.h>
#import <React/UIView+React.h>
NS_ASSUME_NONNULL_BEGIN
@class RCTZxingManager;

@interface RCTZxingScanView :  UIView<ZXCaptureDelegate>

@property (nullable, nonatomic, copy) RCTDirectEventBlock onBarCodeRead;

@end

NS_ASSUME_NONNULL_END
