//
//  JWRemotePlayerViewController.h
//  JWBestPracticeApps
//
//  Created by Karim Mourra on 3/16/16.
//  Copyright © 2016 Karim Mourra. All rights reserved.
//

#import "JWCastingViewController.h"
#import <WatchConnectivity/WatchConnectivity.h>
#import "JWRemoteTerminologyHelper.h"


@interface JWRemotePlayerViewController : JWCastingViewController <WCSessionDelegate>

@property (nonatomic) WCSession *session;

- (void)onPlay;
-(void)onPause;
-(void)onTime:(double)position ofDuration:(double)duration;

@end
