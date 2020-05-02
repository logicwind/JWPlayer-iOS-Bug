//
//  JWRemotePlayerViewController.m
//  JWBestPracticeApps
//
//  Created by Karim Mourra on 3/16/16.
//  Copyright © 2016 Karim Mourra. All rights reserved.
//

#import "JWRemotePlayerViewController.h"

@interface JWRemotePlayerViewController ()

@end

@implementation JWRemotePlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.player.config.autostart = NO;
    [self setUpSession];
}

- (void)setUpSession
{
    if ([WCSession isSupported]) {
        self.session = [WCSession defaultSession];
        self.session.delegate = self;
        [self.session activateSession];
    }
}

#pragma Mark - Session delegate methods

-(void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message replyHandler:(void (^)(NSDictionary<NSString *,id> * _Nonnull))replyHandler
{
    __weak JWRemotePlayerViewController *weakSelf = self;
    if (message[JWRControlMessage]) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [weakSelf.player performSelector:NSSelectorFromString(message[JWRControlMessage])];
        });
    } else if (message[JWRSeekMessage]) {
        NSNumber *seekPercentage = message[JWRSeekMessage];
        CGFloat seekTime = (seekPercentage.floatValue / 100) * self.player.duration;
        dispatch_sync(dispatch_get_main_queue(), ^{
            [weakSelf.player seek:seekTime];
        });
    }
}

#pragma Mark - Player delegate methods

-(void)onPlay
{
    if (self.session.isReachable) {
        [self.session sendMessage:@{JWRCallbackMessage: JWROnPlayCallback}
                     replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {}
                     errorHandler:^(NSError * _Nonnull error) {}];
    }
}

-(void)onPause
{
    if (self.session.isReachable) {
        [self.session sendMessage:@{JWRCallbackMessage: JWROnPauseCallback}
                     replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {}
                     errorHandler:^(NSError * _Nonnull error) {}];
    }
}

-(void)onTime:(double)position ofDuration:(double)duration
{
    if (self.session.isReachable) {
        NSDictionary *onTimeMessage = @{JWRCallbackMessage: JWROnTimeCallback,
                                        JWROnTimePosition: @(position),
                                        JWROnTimeDuration: @(duration)};
        
        [self.session sendMessage: onTimeMessage
                     replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {}
                     errorHandler:^(NSError * _Nonnull error) {}];
    }
}

@end
