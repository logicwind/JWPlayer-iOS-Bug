//
//  JWRemoteCastingDevicesController.m
//  JWBestPracticeApps
//
//  Created by Karim Mourra on 6/28/16.
//  Copyright © 2016 Karim Mourra. All rights reserved.
//

#import "JWAvailableCastingDevicesController.h"
#import <WatchConnectivity/WatchConnectivity.h>
#import "JWRemoteTerminologyHelper.h"

@interface JWAvailableCastingDevicesController () <WCSessionDelegate>

@property (nonatomic) WCSession *session;
@property (nonatomic) NSArray *availableDevices;
@property (nonatomic) NSInteger currentSelection;

- (IBAction)castTapped;
- (IBAction)devicePicked:(NSInteger)value;

@end

@implementation JWAvailableCastingDevicesController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    [self setUpSession];
    NSArray *availableDevices = context;
    [self populateListOfCastingDevices:availableDevices];
}

- (void)willActivate {
    [super willActivate];
}

- (void)didDeactivate {
    [super didDeactivate];
}

- (void)setUpSession
{
    if ([WCSession isSupported]) {
        self.session = [WCSession defaultSession];
        [self.session activateSession];
    }
}

- (void)populateListOfCastingDevices:(NSArray *)availableDevices
{
    NSMutableArray *deviceItems = [NSMutableArray new];
    [availableDevices enumerateObjectsUsingBlock:^(NSString *deviceName, NSUInteger idx, BOOL * _Nonnull stop) {
        WKPickerItem *deviceItem = [WKPickerItem new];
        deviceItem.title = deviceName;
        [deviceItems addObject:deviceItem];
    }];
    [self.availableDevicesPicker setItems:deviceItems];
}

- (IBAction)devicePicked:(NSInteger)value
{
    self.currentSelection = value;
}

- (IBAction)castTapped
{
    [self.session sendMessage:@{JWRCastDeviceSelected: @(self.currentSelection)}
                 replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {}
                 errorHandler:^(NSError * _Nonnull error) {}];
    [self popController];
}

@end



