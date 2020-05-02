//
//  JWRemoteCastInterfaceController.m
//  JWBestPracticeApps
//
//  Created by Karim Mourra on 6/24/16.
//  Copyright © 2016 Karim Mourra. All rights reserved.
//

#import "JWRemoteCastInterfaceController.h"

@interface JWRemoteCastInterfaceController ()

@property (nonatomic) NSArray *availableDevices;
@property (nonatomic) BOOL casting;
@property (nonatomic) BOOL castButtonDisplayed;

@end

@implementation JWRemoteCastInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
}

- (void)willActivate {
    [super willActivate];
}

- (void)didDeactivate {
    [super didDeactivate];
}

#pragma Mark - Handle Cast Status From Phone

-(void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message replyHandler:(void (^)(NSDictionary<NSString *,id> * _Nonnull))replyHandler
{
    if (message[JWRCastDeviceCastingCallback]) {
        self.casting = ((NSNumber *)message[JWRCastDeviceCastingCallback]).boolValue;
        [self handleCastingCallback];
    } else if (message[JWRCastDevicesAvailableCallback]) {
        self.availableDevices = message[JWRCastDevicesAvailableCallback];
        [self handleCastDevicesAvailableCallback];
    }
    [super session:session didReceiveMessage:message replyHandler:replyHandler];
}

- (void)handleCastingCallback
{
    [self removeCastMenuItem];
    if (self.casting) {
        [self addMenuItemWithImageNamed:@"stopCasting" title:@"Stop Casting" action:@selector(stopCasting)];
    } else if (!self.castButtonDisplayed) {
        [self addCastMenuItem];
    }
}

- (void)handleCastDevicesAvailableCallback
{
    if (!self.castButtonDisplayed) {
        [self addCastMenuItem];
    } else if (self.availableDevices.count == 0) {
        [self removeCastMenuItem];
    }
}

#pragma Mark - Manage Menu Items

- (void)addCastMenuItem
{
    if (self.availableDevices.count > 0) {
        [self addMenuItemWithImageNamed:@"miniCastIcon" title:@"Cast" action:@selector(presentAvailableDevices)];
        self.castButtonDisplayed = YES;
    }
}

- (void)removeCastMenuItem
{
    [self clearAllMenuItems];
    self.castButtonDisplayed = NO;
}

#pragma Mark - Menu Item Actions

- (void)presentAvailableDevices
{
    [self pushControllerWithName:@"JWRemoteCastingDevices" context:self.availableDevices];
}

- (void)stopCasting
{
    [self.session sendMessage:@{JWRCastDeviceDisconnect: @0}
                 replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {}
                 errorHandler:^(NSError * _Nonnull error) {}];
}

@end



