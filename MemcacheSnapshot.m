//
//  MemcacheSnapshot.m
//  mcinsight
//
//  Created by Gerard Gualberto on 6/28/09.
//  Copyright 2009 Tierra Innovation. All rights reserved.
//

#import "MemcacheSnapshot.h";
#import "EchoServer.h";
#import "ValueInfo.h";

@implementation MemcacheSnapshot

NSMutableArray *entries;
NSInteger totalKeys;
NSInteger cacheHits = 0;
NSInteger cacheMisses = 0;
NSNumber *hitRatio = 0;
NSInteger totalKeySize;
NSInteger totalValueSize = 0;

- (id) init {
	if (self = [super init]) {
		entries = [NSMutableArray array];
		NSArray *keys = [[EchoServer getDict] allKeys];
		totalKeys = [keys count];
		totalKeySize = 0;
		totalValueSize = 0;
		for (NSString *key in keys) {
			NSLog (@"key -- %@",  key);
			
			ValueInfo *vi = [[EchoServer getDict] objectForKey:key];
			NSDictionary *cacheData;
			cacheData = [NSDictionary dictionaryWithObjectsAndKeys:
				key, @"key",
				[ NSString stringWithFormat: @"%d", lround([[NSDate date] timeIntervalSince1970] - vi.insertedAt)], @"inserted ago",
				[self formatExpiresAt: vi.expiry insertedAt:vi.insertedAt], @"expires in",
				[ NSString stringWithFormat: @"%d", [key length]], @"key size",
				[ NSString stringWithFormat: @"%d", vi.hits], @"hits",
				[ NSString stringWithFormat: @"%d", [vi.data length]], @"value size",
				[vi.data description], @"value",
				nil
			];
			[entries addObject: cacheData];
			totalKeySize += [key length];
			totalValueSize += [vi.data length];
		}
	}
	NSLog (@"totalKeys = %d",  totalKeys);
	
	return self;
}

-(NSInteger)totalKeys{
	return totalKeys;
}

-(NSInteger)totalKeySize{
	return totalKeySize;
}

-(NSInteger)totalValueSize{
	return totalValueSize;
}

-(NSDictionary*)getEntryAt: (NSInteger)index{
	return [entries objectAtIndex:index];
}

-(NSString*)formatExpiresAt: (NSInteger)expiresAt insertedAt:(NSInteger)insertedAt {
	if (expiresAt == 0){
		return @"never";
	} else {
		int left = expiresAt - lround([[NSDate date] timeIntervalSince1970] - insertedAt);
		if (left < 1) {
			return @"---";
		} else {
			return [ NSString stringWithFormat: @"%d", left ];
		}
	}
}


@end
