//
//  DSServerManager.m
//  Ringtones
//
//  Created by Дима on 22.12.14.
//  Copyright (c) 2014 BestAppStudio. All rights reserved.
//

#import "DSSong.h"
#import "DSServerManager.h"
#import "AFNetworking.h"


@interface  DSServerManager()

@property (strong,nonatomic) AFHTTPRequestOperationManager *requestOperationManager;

@end


@implementation DSServerManager


+ (DSServerManager *)sharedManager {
    
    static DSServerManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DSServerManager alloc]init];
    });
    
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.requestOperationManager = [[AFHTTPRequestOperationManager alloc]initWithBaseURL:[NSURL URLWithString:@"http://195.138.68.2:8085/"]];
        
    }
    
    return self;
}

- (void) getSongTopEngWithFilter:(NSString*) filter OnSuccess:(void(^)(NSArray* songs)) success
                    onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
     self.requestOperationManager.requestSerializer = [AFJSONRequestSerializer serializer];
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"GETSOUNDSLIST" , @"command",
                            [NSDictionary dictionaryWithObjectsAndKeys:filter, @"filter",nil],@"param", nil];
   
    [self.requestOperationManager
     POST:@""
     parameters:params
     success:^(AFHTTPRequestOperation *operation, NSDictionary* responseObject) {
         NSLog(@"JSON: %@", responseObject);
         
         NSMutableArray* objectsArray = [NSMutableArray array];
         
         for (NSDictionary* dict in responseObject) {
             DSSong* song = [[DSSong alloc] initWithDictionary:[dict objectForKey:@"param"]];
             [objectsArray addObject:song];
         }
         
         if (success) {
             success(objectsArray);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         
         if (failure) {
             failure(error, operation.response.statusCode);
         }
     }];
    
}

@end
