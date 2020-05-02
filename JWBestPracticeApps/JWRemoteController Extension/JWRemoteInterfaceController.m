//
//  JWRemoteInterfaceController.m
//  JWBestPracticeApps
//
//  Created by Karim Mourra on 3/17/16.
//  Copyright © 2016 Karim Mourra. All rights reserved.
//

#import "JWRemoteInterfaceController.h"

#define playIconName @"play-button.png"
#define pauseIconName @"pause-button.png"

@interface JWRemoteInterfaceController ()

@end

@implementation JWRemoteInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    [self handleVideoPause];
    [self setUpSession];
    [self setUpHiddenPicker];
}

- (void)setUpSession
{
    if ([WCSession isSupported]) {
        self.session = [WCSession defaultSession];
        self.session.delegate = self;
        [self.session activateSession];
    }
}

- (void)setUpHiddenPicker
{
    NSMutableArray *hiddenPickerItems = [NSMutableArray new];
    for (NSInteger percentage = 1; percentage <= 100; percentage++) {
        [hiddenPickerItems addObject:[WKPickerItem new]];
    }
    [self.hiddenSeeker setItems:hiddenPickerItems];
    [self.hiddenSeeker focus];
}

- (void)willActivate {
    [super willActivate];
}

- (void)didDeactivate {
    [super didDeactivate];
}

#pragma Mark - Handle user activity on phone

-(void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message replyHandler:(void (^)(NSDictionary<NSString *,id> * _Nonnull))replyHandler
{
    __weak JWRemoteInterfaceController* weakSelf = self;
    if (message[JWRCallbackMessage]) {
        NSString *callback = message[JWRCallbackMessage];
        if ([callback isEqualToString:JWROnTimeCallback]) {
            NSNumber *position = message[JWROnTimePosition];
            NSNumber *duration = message[JWROnTimeDuration];
            self.currentTimePercentage = (position.floatValue/duration.floatValue)*100;
            if (!self.seeking) {
                [self.hiddenSeeker setSelectedItemIndex:self.currentTimePercentage];
            }
        } else if ([callback isEqualToString:JWROnPlayCallback]) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [weakSelf handleVideoPlay];
            });
        } else if ([callback isEqualToString:JWROnPauseCallback]) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [weakSelf handleVideoPause];
            });
        }
    }
}

#pragma Mark - Handle video status changes

- (void)handleVideoPause
{
    [self.controls setBackgroundImageNamed:playIconName];
    self.videoIsPaused = YES;
}

- (void)handleVideoPlay
{
    [self.controls setBackgroundImageNamed:pauseIconName];
    self.videoIsPaused = NO;
}

#pragma Mark - Handle user activity on watch

- (IBAction)controlTapped {
    if (self.session.isReachable) {
        NSString *instruction = @"";
        if (self.videoIsPaused) {
            instruction = NSStringFromSelector(@selector(play));
        } else {
            instruction = NSStringFromSelector(@selector(pause));
        }
        [self.session sendMessage:@{JWRControlMessage: instruction}
                     replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {}
                     errorHandler:^(NSError * _Nonnull error) {}];
    }
}

- (IBAction)crownTurned:(NSInteger)value {
    self.seeking = self.currentTimePercentage != value;
    if (self.seeking) {
        self.seekToPercentage = value;
    }
    [self.seekBar setValue:value];
}

-(void)pickerDidSettle:(WKInterfacePicker *)picker
{
    if ([picker isEqual:self.hiddenSeeker] && self.seeking) {
        [self.session sendMessage:@{JWRSeekMessage: @(self.seekToPercentage)}
                     replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {}
                     errorHandler:^(NSError * _Nonnull error) {}];
        self.seeking = NO;
    }
}

- (IBAction)sliderTouched:(float)value
{
    [self.hiddenSeeker focus];
}

@end
