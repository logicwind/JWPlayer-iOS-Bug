//
//  JWRemoteCastingDevicesController.h
//  JWBestPracticeApps
//
//  Created by Karim Mourra on 6/28/16.
//  Copyright © 2016 Karim Mourra. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface JWAvailableCastingDevicesController : WKInterfaceController

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfacePicker *availableDevicesPicker;

@end
