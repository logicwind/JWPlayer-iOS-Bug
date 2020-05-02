//
//  JWRemoteInterfaceController.h
//  JWBestPracticeApps
//
//  Created by Karim Mourra on 3/17/16.
//  Copyright © 2016 Karim Mourra. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <WatchConnectivity/WatchConnectivity.h>
#import "JWRemoteTerminologyHelper.h"

@interface JWRemoteInterfaceController : WKInterfaceController <WCSessionDelegate>

@property (nonatomic) WCSession *session;

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *controls;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceSlider *seekBar;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfacePicker *hiddenSeeker;

@property (nonatomic) BOOL videoIsPaused;
@property (nonatomic) BOOL seeking;

@property (nonatomic) NSInteger seekToPercentage;
@property (nonatomic) NSInteger currentTimePercentage;

@end
