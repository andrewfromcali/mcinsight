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

@synthesize totalKeys;
@synthesize totalKeySize;
@synthesize totalValueSize;
@synthesize entries;

- (id) init {
	if (self = [super init]) {
		entries = [NSMutableArray array];
		NSArray *keys = [[EchoServer getDict] allKeys];
		totalKeys = [keys count];
		totalKeySize = 0;
		totalValueSize = 0;
		for (NSString *key in keys) {
			//NSLog (@"key -- %@",  key);

			ValueInfo *vi = [[EchoServer getDict] objectForKey:key];
			NSDictionary *cacheData;
			cacheData = [NSDictionary dictionaryWithObjectsAndKeys:
			             key, @"key",
			             [ NSString stringWithFormat: @"%d", lround([[NSDate date] timeIntervalSince1970] - vi.insertedAt)], @"inserted ago",
			             [self formatExpiresAt: vi.expiry insertedAt:vi.insertedAt], @"expires in",
			             [ NSString stringWithFormat: @"%d", [key length]], @"key size",
			             [ NSString stringWithFormat: @"%d", vi.hits], @"hits",
			             [ NSString stringWithFormat: @"%d", [vi.data length]], @"value size",
			             vi.data, @"value",
			             nil
			            ];
			[entries addObject: cacheData];
			totalKeySize += [key length];
			totalValueSize += [vi.data length];
		}
	}
	//NSLog (@"totalKeys = %d",  totalKeys);

	return self;
}

-(void)filterBy: (NSString *)filter {
	if ((filter != nil) && (![filter isEqualToString:@""])){
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(key CONTAINS %@)", filter];
		[entries filterUsingPredicate:predicate];
	}
}

-(NSDictionary*)getEntryAt: (NSInteger)index {
	//now that we're filtering, we should check that requested index still exists
	if (index >= 0 && index < [entries count]) {
		return [entries objectAtIndex:index];
	}
	else {
		return nil;
	}
}

-(NSString*)formatExpiresAt: (NSInteger)expiresAt insertedAt:(NSInteger)insertedAt {
	if (expiresAt == 0) {
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
