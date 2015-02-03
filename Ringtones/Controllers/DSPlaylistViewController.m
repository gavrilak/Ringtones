//
//  DSPlaylistViewController.m
//  Ringtones
//
//  Created by Dima on 15.01.15.
//  Copyright (c) 2015 BestAppStudio. All rights reserved.
//

#import "DSSoundManager.h"
#import "DSPlaylistViewController.h"
#import "ActionSheetStringPicker.h"
#import "NFXIntroViewController.h"
#import "DaiVolume.h"


@implementation DSPlaylistViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImage *btnImg = [UIImage imageNamed:@"button_set_up.png"];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0.f, 0.f, btnImg.size.width, btnImg.size.height);
    [btn setImage:btnImg forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(showInstruction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = item;
    
    [self updateElements];
    
    self.shareBtn.highlighted = NO;
    self.recomendBtn.highlighted = NO;
    
   
    self.volumeProgress.progress = [DaiVolume volume];
    self.playTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.playTimer invalidate];
    [super viewWillDisappear:animated];
}

#pragma mark - DSSoundManagerDelegate

- (void) activeSongDidChange:(DSSong*)song{
    
    self.song = song;
    [self updateElements];
    
}

- (void) statusChanged:(BOOL)playStatus{
    
    if (playStatus == NO) {
        self.playBtn.selected = YES;
        self.pauseBtn.selected = NO;

    }
}
#pragma mark - Self Methods

- (void) updateElements {
    
    self.titleLbl.text = self.song.title;
    self.artistLbl.text = self.song.artist;
    self.imageSong.image = self.pictureSong;
    self.startLbl.text = @"00:00";
    self.endLbl.text = @"00:00";
    
    
    if([DSSoundManager sharedManager].isPlaying == YES){
        self.playBtn.selected = YES;
        self.pauseBtn.selected = NO;
    }
    else{
        self.pauseBtn.selected = YES;
        self.playBtn.selected = NO;
    }
    [self setTitleVersion];
    
}

- (void) showInstruction {
    
    UIImage*i1 = [UIImage imageNamed:@"1.png"];
    UIImage*i2 = [UIImage imageNamed:@"2.png"];
    UIImage*i3 = [UIImage imageNamed:@"3.png"];
    UIImage*i4 = [UIImage imageNamed:@"4.png"];
    UIImage*i5 = [UIImage imageNamed:@"5.png"];
    UIImage*i6 = [UIImage imageNamed:@"6.png"];
    UIImage*i7 = [UIImage imageNamed:@"7.png"];
    UIImage*i8 = [UIImage imageNamed:@"8.png"];
    UIImage*i9 = [UIImage imageNamed:@"9.png"];
    
    NFXIntroViewController*vc = [[NFXIntroViewController alloc] initWithViews:@[i1,i2,i3,i4,i5,i2,i6,i7,i8,i9]];
    [self presentViewController:vc animated:true completion:nil];
    
}


- (void) play{
    
    if (self.playBtn.selected){
        [self.playProgress setProgress: 0 animated:NO];
        [[DSSoundManager sharedManager] play];
        self.pauseBtn.selected = YES;
        self.playBtn.selected = NO;

    }
}

- (NSString*) timeToString:(double )timeInterval {
    float min = floor(timeInterval/60);
    float sec = round(timeInterval - min * 60);
    NSString *time = [NSString stringWithFormat:@"%02d:%02d", (int)min, (int)sec];
    return time;
}

- (void) setTitleVersion {
    switch (self.song.versionAudio){
        case sFull:
            [self.versionBtn setTitle: @"Полная версия     " forState:UIControlStateNormal];
             break;
        case sCut:
            [self.versionBtn setTitle: @"Нарезка 1     " forState:UIControlStateNormal];
            break;
        case sRignton:
            [self.versionBtn setTitle: @"Нарезка 2     " forState:UIControlStateNormal];
            break;
    }
 
}

#pragma mark - Timer
- (void) timerAction:(id)timer{
    [self updatePlayTime];
}

- (void) updatePlayTime
{
    self.volumeProgress.progress = [DaiVolume volume];
    self.endLbl.text = [self timeToString:[DSSoundManager sharedManager].streamer.duration];
    self.startLbl.text = [self timeToString:[DSSoundManager sharedManager].streamer.currentTime];
   // NSLog(@"%f   %f" ,self.streamer.currentTime, self.streamer.duration);
    if ([DSSoundManager sharedManager].streamer.duration > 0)
    {
        [self.playProgress setProgress: (float)([DSSoundManager sharedManager].streamer.currentTime/[DSSoundManager sharedManager].streamer.duration)  animated:YES];
    }
}

#pragma mark - Implementation
- (void)versionWasSelected:(NSNumber *)selectedIndex element:(id)element {
    
    self.song.versionAudio = [selectedIndex intValue];
    switch(self.song.versionAudio){
        case sFull:{
            self.song.audioFileURL = [NSURL URLWithString:self.song.fileLink];
        break;}

        case sCut:{
            self.song.audioFileURL = [NSURL URLWithString:self.song.cutLink];
        break;}
        case sRignton:{
            self.song.audioFileURL = [NSURL URLWithString:self.song.ringtonLink];
        break;}
    }
    [[DSSoundManager sharedManager] playSong:self.song];
    [self setTitleVersion];
}
- (void)actionPickerCancelled:(id)sender {
   // NSLog(@"Delegate has been informed that ActionSheetPicker was cancelled");
}

#pragma mark - Actions
- (IBAction)versionAction:(id)sender{
    
    [ActionSheetStringPicker showPickerWithTitle:@"Выберите версию" rows:[NSArray arrayWithObjects: @"Полная версия", @"Нарезка1",@"Нарезка2" , nil] initialSelection:self.song.versionAudio target:self successAction:@selector(versionWasSelected:element:) cancelAction:@selector(actionPickerCancelled:) origin:sender];
}

- (IBAction)playAction:(id)sender{
   
    [self play];
}


- (IBAction)pauseAction:(id)sender{
    
    [[DSSoundManager sharedManager] pause];
    if (self.pauseBtn.selected){
        self.playBtn.selected = YES;
        self.pauseBtn.selected = NO;
    }
}
- (IBAction)forwardAction:(id)sender{
    [[DSSoundManager sharedManager] forward];
}
- (IBAction)backAction:(id)sender{
    
    [[DSSoundManager sharedManager] backward];
}
- (IBAction)recoendedAction:(id)sender{
    
}


- (IBAction)shareAction:(id)sender{
    UIImage *sendImage = self.pictureSong;
    self.shareBtn.highlighted = YES;
    dispatch_queue_t queue = dispatch_queue_create("openActivityIndicatorQueue", NULL);
    // send initialization of UIActivityViewController in background
    dispatch_async(queue, ^{
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc]
                                                        initWithActivityItems:@[[NSString stringWithFormat:@"Лучшие рингтоны! Скачай %@ - %@ на свой телефон! itunes.apple.com/ru/artist/bestapp-studio-ltd./id739061892?l=ru",self.song.artist,self.song.title], sendImage] applicationActivities:nil];
    activityViewController.excludedActivityTypes=@[UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypePostToWeibo,UIActivityTypePrint,UIActivityTypeSaveToCameraRoll];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:activityViewController animated:YES completion:nil];
        
    });
    });
}










@end