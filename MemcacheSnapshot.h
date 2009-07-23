//
//  MemcacheSnapshot.h
//  mcinsight
//
//  Created by Gerard Gualberto on 6/28/09.
//  Copyright 2009 Tierra Innovation. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MemcacheSnapshot : NSObject {
	NSMutableArray *entries;
	NSInteger totalKeys;
	NSInteger cacheHits;
	NSInteger cacheMisses;
	NSString *hitRatio;
	NSInteger totalKeySize;
	NSInteger totalValueSize;
}

@property (nonatomic, readonly) NSInteger totalKeys;
@property (nonatomic, readonly) NSInteger totalKeySize;
@property (nonatomic, readonly) NSInteger totalValueSize;
@property (nonatomic, readonly) NSInteger cacheHits;
@property (nonatomic, readonly) NSInteger cacheMisses;
@property (nonatomic, readonly) NSString *hitRatio;
@property (assign) NSMutableArray *entries;

-(NSDictionary*)getEntryAt: (NSInteger)index;
-(NSString*)formatExpiresAt: (NSInteger)expiresAt insertedAt:(NSInteger)insertedAt;
-(void)filterBy: (NSString *)filter;
-(NSString *)stringFromFileSize: (NSInteger)theSize;
-(NSString *)stringFromSeconds: (NSInteger)totalSeconds;
@end
