//
//  DSMainViewController.m
//  Ringtones
//
//  Created by Дима on 22.12.14.
//  Copyright (c) 2014 BestAppStudio. All rights reserved.
//

#import "DSMainViewController.h"
#import "DSSongViewController.h"
#import "DSSongTableViewCell.h"
#import "DSRateView.h"
#import "DSServerManager.h"
#import "DSSong.h"
#import "UIImageView+AFNetworking.h"

@interface DSMainViewController ()

    @property (strong, nonatomic) NSArray* songsArray;
    @property (assign, nonatomic) NSInteger selectedItem;
    @property (assign, nonatomic) NSInteger selectedPeriod;
@end

@implementation DSMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self getSongsFromServerWithFilter:@"rus"];
    [self.tabBar setSelectedItem:[self.tabBar.items objectAtIndex:0]];
    self.selectedPeriod = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - API

- (void) getSongsFromServerWithFilter:(NSString*) filter {
    
    [[DSServerManager sharedManager]getSongWithFilter:filter OnSuccess:^(NSArray *songs)
    {
        self.songsArray = [NSArray arrayWithArray:songs];
        [self.tableView reloadData];
        
    } onFailure:^(NSError *error, NSInteger statusCode) {
        NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);
    }];
    
}

- (void) getSongsFromServerWithDays:(NSString*) days {
    
    [[DSServerManager sharedManager]getSongWithDays:days OnSuccess:^(NSArray *songs)
     {
         self.songsArray = [NSArray arrayWithArray:songs];
         [self.tableView reloadData];
         
     } onFailure:^(NSError *error, NSInteger statusCode) {
         NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);
     }];
    
}
#pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.songsArray count] ;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* identifier = @"song";
    
    DSSongTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[DSSongTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];}
    
    DSSong* song = [self.songsArray objectAtIndex:indexPath.row ];
    cell.titleLabel.text = song.title;
    cell.artistLabel.text = song.artist;
    
    cell.rateView.editable = false;
    cell.rateView.rating =  song.rating ;
    cell.rateView.notSelectedImage = [UIImage imageNamed:@"star_empty.png"];
    cell.rateView.halfSelectedImage = [UIImage imageNamed:@"star_half.png"];
    cell.rateView.fullSelectedImage = [UIImage imageNamed:@"star_full.png"];
    cell.rateView.maxRating = 5;

    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:song.albumLink]];
    
    __weak DSSongTableViewCell* weakCell = cell;
    
    cell.image.image = nil;
    
    [cell.image
     setImageWithURLRequest:request
     placeholderImage:nil
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
         weakCell.image.image = image;
         [weakCell layoutSubviews];
     }
     failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
         NSLog(@"error = %@", [error localizedDescription]);
     }];
    
    
    return cell;
}
#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    self.selectedItem = indexPath.row;
    return indexPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.tabBar.selectedItem.tag == 3){
        return 40;
    }
    else{
        return 0;
    }
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0 && self.tabBar.selectedItem.tag == 3) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0, 320, 44)]; // x,y,width,height
        headerView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.f];
        NSArray *itemArray = [NSArray arrayWithObjects: @"Week", @"Two weeks", @"Month", nil];
        UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:itemArray];
        
        [control setFrame:CGRectMake(20.0, 5.0, 280.0, 30.0)];
        [control setSelectedSegmentIndex:self.selectedPeriod];
        [control setEnabled:YES];
        [control addTarget:self action:@selector(touchPeriod:) forControlEvents: UIControlEventValueChanged ];
        
        [headerView addSubview:control];
        [headerView bringSubviewToFront:control];
        return headerView;
        
    }
    else
      return  nil;
}


- (void) touchPeriod:(UIControl *)sender {
   
    UISegmentedControl* segment = (UISegmentedControl*)sender;
    self.selectedPeriod = segment.selectedSegmentIndex;
    switch(segment.selectedSegmentIndex) {
        case 0:
             [self getSongsFromServerWithDays: @"7"];
        case 1:
             [self getSongsFromServerWithDays: @"14"];
        case 2:
             [self getSongsFromServerWithDays: @"30"];
    }
    
}
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    DSSongViewController *dc = [segue destinationViewController];
    dc.song = [self.songsArray objectAtIndex:self.selectedItem];
    
}
#pragma mark -  UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    
    
    switch (item.tag)
    {
        case 1:
            
            [self getSongsFromServerWithFilter:@"rus"];
            
            break;
        case 2:
            
            [self getSongsFromServerWithFilter:@"eng"];
       
            break;
        case 3:
            
            [self getSongsFromServerWithDays: @"7"];
            
            break;
        case 4:
            break;
        case 5:
            
            break;
            
    }
  
}


@end
