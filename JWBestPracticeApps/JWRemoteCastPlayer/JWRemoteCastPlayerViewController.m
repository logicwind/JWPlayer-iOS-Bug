//
//  JWRemoteCastPlayerViewController.m
//  JWBestPracticeApps
//
//  Created by Karim Mourra on 6/24/16.
//  Copyright © 2016 Karim Mourra. All rights reserved.
//

#import "JWRemoteCastPlayerViewController.h"

@interface JWRemoteCastPlayerViewController ()

@end

@implementation JWRemoteCastPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma Mark - Session delegate methods

- (void)sessionReachabilityDidChange:(WCSession *)session
{
    if (self.availableDevices.count && session.reachable) {
        [self updateDeviceListOnWatch:self.availableDevices];
    }
}

-(void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message replyHandler:(void (^)(NSDictionary<NSString *,id> * _Nonnull))replyHandler
{
    if (message[JWRCastDeviceDisconnect]) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.castController disconnect];
        });
    } else if (message[JWRCastDeviceSelected]) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSInteger deviceIndex = ((NSNumber *)message[JWRCastDeviceSelected]).integerValue;
            [self.castController connectToDevice:self.availableDevices[deviceIndex]];
        });
    } else {
        [super session:session didReceiveMessage:message replyHandler:replyHandler];
    }
}

#pragma Mark - Casting delegate methods

-(void)onCastingDevicesAvailable:(NSArray *)devices
{
    [self updateDeviceListOnWatch:devices];
    [super onCastingDevicesAvailable:devices];
}

- (void)updateDeviceListOnWatch:(NSArray *)devices
{
    NSMutableArray *deviceNames = [NSMutableArray new];
    [devices enumerateObjectsUsingBlock:^(JWCastingDevice *device, NSUInteger idx, BOOL * _Nonnull stop) {
        [deviceNames addObject:device.name];
    }];
    [self.session sendMessage:@{JWRCastDevicesAvailableCallback: deviceNames}
                 replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {}
                 errorHandler:^(NSError * _Nonnull error) {}];
}

-(void)onConnectedToCastingDevice:(JWCastingDevice *)device
{
    [super onConnectedToCastingDevice:device];
    [self.castController cast];
}

-(void)onCasting
{
    [super onCasting];
    [self notifyWatchOfCastingStatus:YES];
    [self.player play];
}

-(void)onCastingEnded:(NSError *)error
{
    [super onCastingEnded:error];
    [self.castController disconnect];
}

-(void)onCastingFailed:(NSError *)error
{
    [super onCastingFailed:error];
    [self.castController disconnect];
}

-(void)onDisconnectedFromCastingDevice:(NSError *)error
{
    [super onDisconnectedFromCastingDevice:error];
    [self notifyWatchOfCastingStatus:NO];
}

- (void)notifyWatchOfCastingStatus:(BOOL)status
{
    [self.session sendMessage:@{JWRCastDeviceCastingCallback: @(status)}
                 replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {}
                 errorHandler:^(NSError * _Nonnull error) {}];
}

@end
