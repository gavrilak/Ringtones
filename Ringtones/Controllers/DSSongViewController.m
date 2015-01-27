//
//  DSSongViewController.m
//  Ringtones
//
//  Created by Дима on 23.12.14.
//  Copyright (c) 2014 BestAppStudio. All rights reserved.
//

#import "DSSongViewController.h"
#import "DSServerManager.h"
#import "DSDataManager.h"
#import "AFNetworking.h"

static void *kStatusKVOKey = &kStatusKVOKey;
static void *kDurationKVOKey = &kDurationKVOKey;
static void *kBufferingRatioKVOKey = &kBufferingRatioKVOKey;

@interface DSSongViewController ()

@end

@implementation DSSongViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
  
    self.downloadBtn.layer.cornerRadius=6.0;
    self.favoriteBtn.layer.cornerRadius=6.0;
    self.titleLabel.text=self.song.title;
    
    self.lblStartTime.text = @"00:00";
    self.lblEndTime.text = @"-00:00";
    [self.sldPlay setValue: 0.0f animated:YES];
    self.progDownload.hidden = YES;
    self.sldPlay.hidden = NO;

    self.rateView.editable = ![[DSDataManager dataManager]existsLikeForSong:self.song.id_sound];
    self.rateView.rating = self.song.rating;
    self.rateView.notSelectedImage = [UIImage imageNamed:@"star_empty.png"];
    self.rateView.halfSelectedImage = [UIImage imageNamed:@"star_half.png"];
    self.rateView.fullSelectedImage = [UIImage imageNamed:@"star_full.png"];
    self.rateView.maxRating = 5;
    self.rateView.delegate = self;

 
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self _resetStreamer];
    
    self.playTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updatePlayTime) userInfo:nil repeats:YES];
   // [_volumeSlider setValue:[DOUAudioStreamer volume]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.playTimer invalidate];
    [self.streamer stop];
    [self _cancelStreamer];
    
    [super viewWillDisappear:animated];
}

- (void)_actionPlayPause:(id)sender
{
    if ([self.streamer status] == DOUAudioStreamerPaused ||
        [self.streamer status] == DOUAudioStreamerIdle) {
        [self.streamer play];
    }
    else {
        [self.streamer pause];
    }
}

- (void)_actionNext:(id)sender
{

    
    [self _resetStreamer];
}

- (void)_actionStop:(id)sender
{
    [self.streamer stop];
}

- (void)_actionSliderProgress:(id)sender
{
    [self.streamer setCurrentTime:[self.streamer duration] * [self.sldPlay value]];
}

- (void)_actionSliderVolume:(id)sender
{
 //   [DOUAudioStreamer setVolume:[_volumeSlider value]];
}

- (void)_cancelStreamer
{
    if (_streamer != nil) {
        [_streamer pause];
        [_streamer removeObserver:self forKeyPath:@"status"];
        [_streamer removeObserver:self forKeyPath:@"duration"];
        [_streamer removeObserver:self forKeyPath:@"bufferingRatio"];
        _streamer = nil;
    }
}

- (void)_resetStreamer
{
    [self _cancelStreamer];
    
        self.song.audioFileURL = [NSURL fileURLWithPath:self.song.fileLink];
        _streamer = [DOUAudioStreamer streamerWithAudioFile:self.song];
        [_streamer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:kStatusKVOKey];
        [_streamer addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:kDurationKVOKey];
        [_streamer addObserver:self forKeyPath:@"bufferingRatio" options:NSKeyValueObservingOptionNew context:kBufferingRatioKVOKey];
        
        [_streamer play];
        
   
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kStatusKVOKey) {
        [self performSelector:@selector(updatePlayTime)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else if (context == kDurationKVOKey) {
        [self performSelector:@selector(updatePlayTime)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else if (context == kBufferingRatioKVOKey) {
        [self performSelector:@selector(updatePlayTime)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - DSRateViewDelegate
- (void)rateView:(DSRateView *)rateView ratingDidChange:(float)rating{
    NSLog(@"%f",rating);
    [[DSServerManager sharedManager] setSongRating:[NSString stringWithFormat:@"%.0f",rating] forSong:[NSString stringWithFormat:@"%ld", (long)self.song.id_sound ] OnSuccess:^(NSObject *result) {
        NSLog(@"Set Rating");
        [[DSDataManager dataManager] addLikeForSong:self.song.id_sound withRating:rating];
        self.rateView.editable = NO;
    } onFailure:^(NSError *error, NSInteger statusCode) {
        NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)playAction:(id)sender {
    
    if ([self.streamer status] == DOUAudioStreamerPaused ||
        [self.streamer status] == DOUAudioStreamerIdle) {
        [self.streamer play];
    }
    else {
        [self.streamer pause];
    }

    
   
}

- (void) updatePlayTime
{
    
    //    NSLog(@"current time = %f", audioPlayer.currentTime);
    NSString* strPlayedTime = [self changeTimetoFloat: self.audioPlayer.progress];
    
    float fRemainTime = self.audioPlayer.duration -self.audioPlayer.progress;
    NSString* strRemainTime = [NSString stringWithFormat: @"-%@", [self changeTimetoFloat: fRemainTime]];
    
    [self.sldPlay setValue: self.audioPlayer.progress animated:YES];
    [self.lblStartTime setText: strPlayedTime];
    [self.lblEndTime setText: strRemainTime];
}

- (NSString*) changeTimetoFloat: (float) length
{
    int minutes = (int) floor(length / 60);
    int seconds = (int) length - (minutes * 60);
    
    NSString* strMinutes = [NSString stringWithFormat: @"%d", minutes];
    if (minutes < 10) {
        strMinutes = [NSString stringWithFormat: @"0%@", strMinutes];
    }
    
    NSString* strSeconds = [NSString stringWithFormat: @"%d", seconds];
    if (seconds < 10) {
        strSeconds = [NSString stringWithFormat: @"0%@", strSeconds];
    }
    
    NSString *strTime = [NSString stringWithFormat: @"%@:%@", strMinutes, strSeconds];
    
    return strTime;
}
- (IBAction) onPlaySlider: (id) sender
{
    [self.audioPlayer seekToTime: self.sldPlay.value];
}

- (IBAction)favoriteAction:(id)sender {
    
    [[DSDataManager dataManager] addPlaylistItemForNameList:@"Избранное" song:self.song version:sFull fileLink:[self download] imagelink:@""];
    
}
- (IBAction)downloadAction:(id)sender {
   
     [[DSDataManager dataManager] addPlaylistItemForNameList:@"Загрузки" song:self.song version:sFull fileLink:[self download] imagelink:@""];
 
    

}

-(NSString*) download {
   // NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.song.fileLink]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:self.song.fileLink]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fullPath = [ documentsDirectory stringByAppendingPathComponent:[self.song.fileLink lastPathComponent]];
    
    //NSString *fullPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[self.song.fileLink lastPathComponent]];
    
    [operation setOutputStream:[NSOutputStream outputStreamToFileAtPath:fullPath append:NO]];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        NSLog(@"bytesRead: %u, totalBytesRead: %lld, totalBytesExpectedToRead: %lld", bytesRead, totalBytesRead, totalBytesExpectedToRead);
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
      //  NSLog(@"RES: %@", [[[operation response] allHeaderFields] description]);
        
        NSError *error;
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fullPath error:&error];
        
        if (error) {
            NSLog(@"ERR: %@", [error description]);
        } else {
            NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
            long long fileSize = [fileSizeNumber longLongValue];
            
            //  [[_downloadFile titleLabel] setText:[NSString stringWithFormat:@"%lld", fileSize]];
            //return fullPath;
            NSLog(@"%@, %@",fullPath,[NSString stringWithFormat:@"%lld", fileSize]);
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"ERR: %@", [error description]);
    }];
    
    [operation start];
    return fullPath;
}


/// Raised when an item has started playing
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId{};
/// Raised when an item has finished buffering (may or may not be the currently playing item)
/// This event may be raised multiple times for the same item if seek is invoked on the player
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId{};
/// Raised when the state of the player has changed
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState{};
/// Raised when an item has finished playing
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishPlayingQueueItemId:(NSObject*)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration{

    [self.playTimer invalidate];
    self.playTimer = nil;
    self.lblStartTime.text = @"00:00";
    self.lblEndTime.text = [NSString stringWithFormat:@"-%@", [self changeTimetoFloat:self.audioPlayer.duration]];
    
    [self.sldPlay setValue:0 animated:YES];
    self.isPlaying = NO;
    [self.playBtn setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];



};
/// Raised when an unexpected and possibly unrecoverable error has occured (usually best to recreate the STKAudioPlauyer)
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer unexpectedError:(STKAudioPlayerErrorCode)errorCode{};

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    
}

@end
