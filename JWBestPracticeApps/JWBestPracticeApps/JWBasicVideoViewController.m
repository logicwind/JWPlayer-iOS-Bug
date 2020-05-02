//
//  JWBasicVideoViewController.m
//  JWBestPracticeApps
//
//  Created by Karim Mourra on 3/16/16.
//  Copyright © 2016 Karim Mourra. All rights reserved.
//

#import "JWBasicVideoViewController.h"

#define videoFile @"http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
#define posterImage @"http://d3el35u4qe4frz.cloudfront.net/bkaovAYt-480.jpg"

@interface JWBasicVideoViewController ()

@end

@implementation JWBasicVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createPlayer];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.view addSubview:self.player.view];
}

- (void)createPlayer
{
    JWConfig *config = [self createConfig];
    self.player = [[JWPlayerController alloc]initWithConfig:config];
    self.player.forceLandscapeOnFullScreen = YES;
    self.player.forceFullScreenOnLandscape = YES;
    self.player.view.center = self.view.center;
    self.player.delegate = self;
}

- (JWConfig *)createConfig
{
     JWConfig *config = [[JWConfig alloc] init];
    JWPlaylistItem *item1 = [[JWPlaylistItem alloc] init];
    item1.file            = @"https://cdn.jwplayer.com/manifests/vM7nH0Kl.m3u8";
    item1.title           = @"Aerospace Demonstration";

    JWPlaylistItem *item2 = [[JWPlaylistItem alloc] init];
    item2.file            = @"https://cdn.jwplayer.com/manifests/hWF9vG66.m3u8";
    item2.title           = @"Bunny";
    
    JWPlaylistItem *item3 = [[JWPlaylistItem alloc] init];
    item3.file            = @"https://content.jwplatform.com/manifests/yp34SRmf.m3u8";
    item3.title           = @"Cycling";
    
    JWPlaylistItem *item4 = [[JWPlaylistItem alloc] init];
    item4.file            = @"https://cdn.jwplayer.com/manifests/tkM1zvBq.m3u8";
    item4.title           = @"Beach Side";

    config.playlist       = @[item1, item2, item3, item4];
    config.image = posterImage;
    config.size = CGSizeMake(self.view.frame.size.width, self.view.frame.size.width);
    config.autostart = YES;
    config.repeat = YES;
    return config;
}

-(void)onPlay:(JWEvent<JWStateChangeEvent> *)event {
    NSLog(@"~~~~onPlay~~~~~");
}

- (void)onComplete
{
    NSLog(@"~~~~~~~~~~~~~~~~onComplete~~~~~~~~~~~~~~~");
}

-(void)onPlaylistComplete
{
  NSLog(@"~~~~~~~~~~~~~~~~~~~~~~~onPlaylistComplete~~~~~~~~~~~~~~~");
}

-(void)onPlaylistItem:(JWEvent<JWPlaylistItemEvent> *)event
{
  NSLog(@"~~~~~~~~~~~~~~~onPlaylistItem~~~~~~~~~~~~~~~");
}

@end
