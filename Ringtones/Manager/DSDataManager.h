//
//  DSDataManager.h
//  Ringtones
//
//  Created by Dima on 12/28/14.
//  Copyright (c) 2014 BestAppStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DSSong.h"
#import "DSPlaylist.h"
#import "DSPlaylistItem.h"

@interface DSDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void) addLikeForSong:(NSInteger)id_song;
- (bool) existsLikeForSong:(NSInteger) id_song;

- (DSPlaylist*) addPlaylistwithName:(NSString*) name ;
- (NSMutableArray*) allPlaylists;
- (DSPlaylist*) findPlaylistWithName:(NSString*) name;
- (DSPlaylist*) findPlaylistWithId:(double) listId;
- (BOOL) deletePlaylistWithId:(double) ItemId;

-(NSMutableArray*) getSongsFromPalylistName:(NSString*) playList;
- (void) addPlaylistItem:(NSString*) playList song:(DSSong*)  song version:(NSInteger) version fileLink:(NSString*) savefile_link  imagelink:(NSString*) imagelink;
- (BOOL) deletePlaylistItemWithId:(double) ItemId;
- (DSPlaylistItem*) findPlaylistItemWithId:(double) itemId;
+ (DSDataManager*) dataManager;

@end
