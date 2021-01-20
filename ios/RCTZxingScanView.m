//
//  RCTZxingScanView.m
//  RNIosZxing
//
//  Created by TengYan on 2021/1/19.
//  Copyright © 2021 Facebook. All rights reserved.
//
#import "RCTZxingScanView.h"

#import <React/RCTBridge.h>
#import <React/RCTLog.h>
#import <React/RCTUtils.h>
#import <React/RCTEventDispatcher.h>
#import <React/UIView+React.h>
#import <AVFoundation/AVFoundation.h>
@implementation RCTZxingScanView {
    CGAffineTransform _captureSizeTransform;
     ZXCapture *capture;
     UIView *scanRectView;
     BOOL scanning;
     BOOL isFirstApplyOrientation;

}
@synthesize onBarCodeRead = _onBarCodeRead;


- (void)layoutSubviews
{
    RCTLog(@"In layoutSubviews");
    [super layoutSubviews];
    capture = [[ZXCapture alloc] init];
    capture.sessionPreset = AVCaptureSessionPreset1920x1080;
    capture.camera = capture.back;
    capture.focusMode = AVCaptureFocusModeContinuousAutoFocus;
    capture.delegate = self;

    scanning = NO;
    self.backgroundColor = [UIColor blackColor];
    CGSize screenSize = RCTScreenSize();
    self.frame =CGRectMake(0, 0, screenSize.width, screenSize.height);
    capture.layer.frame =  CGRectMake(0, 0, screenSize.width, screenSize.height);
    [self.layer addSublayer:capture.layer];
//     reset the size
    int width = screenSize.width* 0.9;
    int height =screenSize.height*0.35;
    
    CGRect rect = CGRectMake(screenSize.width/2- width/2,screenSize.height/2 -height/2,width,height);
    scanRectView = [[UIView alloc] initWithFrame:rect];
    scanRectView.backgroundColor = [UIColor blackColor];
    scanRectView.alpha = 0;
    
    [self addSubview :scanRectView];
    [self applyOrientation];
    RCTLog(@"In layoutSubviews---end");
}



#pragma mark - View Controller Methods

- (void)dealloc {
  [capture.layer removeFromSuperlayer];
}




#pragma mark - Private
- (void)applyOrientation {
  UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
  float scanRectRotation;
  float captureRotation;
  
  switch (orientation) {
    case UIInterfaceOrientationPortrait:
      captureRotation = 0;
      scanRectRotation = 90;
      break;
    case UIInterfaceOrientationLandscapeLeft:
      captureRotation = 90;
      scanRectRotation = 180;
      break;
    case UIInterfaceOrientationLandscapeRight:
      captureRotation = 270;
      scanRectRotation = 0;
      break;
    case UIInterfaceOrientationPortraitUpsideDown:
      captureRotation = 180;
      scanRectRotation = 270;
      break;
    default:
      captureRotation = 0;
      scanRectRotation = 90;
      break;
  }
  capture.layer.frame = self.frame;
  CGAffineTransform transform = CGAffineTransformMakeRotation((CGFloat) (captureRotation / 180 * M_PI));
  [capture setTransform:transform];
  [capture setRotation:scanRectRotation];
  
  [self applyRectOfInterest:orientation];
}

- (void)applyRectOfInterest:(UIInterfaceOrientation)orientation {
  CGFloat scaleVideoX, scaleVideoY;
  CGFloat videoSizeX, videoSizeY;
  CGRect transformedVideoRect = scanRectView.frame;
  if([capture.sessionPreset isEqualToString:AVCaptureSessionPreset1920x1080]) {
    videoSizeX = 1080;
    videoSizeY = 1920;
  } else {
    videoSizeX = 720;
    videoSizeY = 1280;
  }
  if(UIInterfaceOrientationIsPortrait(orientation)) {
    scaleVideoX = capture.layer.frame.size.width / videoSizeX;
    scaleVideoY = capture.layer.frame.size.height / videoSizeY;
    
    // Convert CGPoint under portrait mode to map with orientation of image
    // because the image will be cropped before rotate
    // reference: https://github.com/TheLevelUp/ZXingObjC/issues/222
    CGFloat realX = transformedVideoRect.origin.y;
    CGFloat realY = capture.layer.frame.size.width - transformedVideoRect.size.width - transformedVideoRect.origin.x;
    CGFloat realWidth = transformedVideoRect.size.height;
    CGFloat realHeight = transformedVideoRect.size.width;
    transformedVideoRect = CGRectMake(realX, realY, realWidth, realHeight);
    
  } else {
    scaleVideoX = capture.layer.frame.size.width / videoSizeY;
    scaleVideoY = capture.layer.frame.size.height / videoSizeX;
  }
  
  _captureSizeTransform = CGAffineTransformMakeScale(1.0/scaleVideoX, 1.0/scaleVideoY);
  capture.scanRect = CGRectApplyAffineTransform(transformedVideoRect, _captureSizeTransform);
}

#pragma mark - Private Methods

- (NSString *)barcodeFormatToString:(ZXBarcodeFormat)format {
  switch (format) {
    case kBarcodeFormatAztec:
      return @"Aztec";
      
    case kBarcodeFormatCodabar:
      return @"CODABAR";
      
    case kBarcodeFormatCode39:
      return @"Code 39";
      
    case kBarcodeFormatCode93:
      return @"Code 93";
      
    case kBarcodeFormatCode128:
      return @"Code 128";
      
    case kBarcodeFormatDataMatrix:
      return @"Data Matrix";
      
    case kBarcodeFormatEan8:
      return @"EAN-8";
      
    case kBarcodeFormatEan13:
      return @"EAN-13";
      
    case kBarcodeFormatITF:
      return @"ITF";
      
    case kBarcodeFormatPDF417:
      return @"PDF417";
      
    case kBarcodeFormatQRCode:
      return @"QR Code";
      
    case kBarcodeFormatRSS14:
      return @"RSS 14";
      
    case kBarcodeFormatRSSExpanded:
      return @"RSS Expanded";
      
    case kBarcodeFormatUPCA:
      return @"UPCA";
      
    case kBarcodeFormatUPCE:
      return @"UPCE";
      
    case kBarcodeFormatUPCEANExtension:
      return @"UPC/EAN extension";
      
    default:
      return @"Unknown";
  }
}

#pragma mark - ZXCaptureDelegate Methods

- (void)captureCameraIsReady:(ZXCapture *)capture {
    RCTLog(@"captureCameraIsReady");
  scanning = YES;
}

- (void)captureResult:(ZXCapture *)capture result:(ZXResult *)result {
    RCTLog(@"captureResult");
  if (!scanning) return;
  if (!result) return;
  
  // We got a result.
  [capture stop];
  scanning = NO;
  
  // Display found barcode location
  CGAffineTransform inverse = CGAffineTransformInvert(_captureSizeTransform);
  NSMutableArray *points = [[NSMutableArray alloc] init];
  NSString *location = @"";
  for (ZXResultPoint *resultPoint in result.resultPoints) {
    CGPoint cgPoint = CGPointMake(resultPoint.x, resultPoint.y);
    CGPoint transformedPoint = CGPointApplyAffineTransform(cgPoint, inverse);
    transformedPoint = [scanRectView convertPoint:transformedPoint toView:scanRectView.window];
    NSValue* windowPointValue = [NSValue valueWithCGPoint:transformedPoint];
    location = [NSString stringWithFormat:@"%@ (%f, %f)", location, transformedPoint.x, transformedPoint.y];
    [points addObject:windowPointValue];
  }
  
  // Display information about the result onscreen.
  NSString *formatString = [self barcodeFormatToString:result.barcodeFormat];
  NSString *display = [NSString stringWithFormat:@"{Format: %@,Contents:%@}",
                formatString, result.text];
    RCTLog(@"display: %@", display);
    NSDictionary * dic = @{ @"format":formatString,
                            @"content":result.text
    };
    if (_onBarCodeRead)  {
        RCTLog(@"onBarCodeRead: %@", dic);
        _onBarCodeRead(dic);
    }
//  // Vibrate
//  AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
  
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
    scanning = YES;
    [capture start];
  });
}

@end



