//
//  MemcacheSnapshot.m
//  mcinsight
//
//  Created by Gerard Gualberto on 6/28/09.
//  Copyright 2009 Tierra Innovation. All rights reserved.
//

#import "MemcacheSnapshot.h"
#import "EchoServer.h"
#import "ValueInfo.h"

@implementation MemcacheSnapshot

@synthesize totalKeys;
@synthesize totalKeySize;
@synthesize totalValueSize;
@synthesize entries;
@synthesize cacheHits;
@synthesize cacheMisses;
@synthesize hitRatio;


- (id) init {
	if (self = [super init]) {
		entries = [NSMutableArray array];
		NSArray *keys = [[EchoServer getDict] allKeys];
		
		cacheHits = [EchoServer getTotalHits];
		cacheMisses = [EchoServer getTotalMisses];
		float ratio = ((float)cacheHits/(cacheHits + cacheMisses)) * 100;
		
		if (cacheMisses > 0) {
			hitRatio = [ NSString stringWithFormat: @"%.2f %%", ratio];
		} else {
			hitRatio = @"0.00 %";
		}
		
		
		totalKeys = [keys count];
		totalKeySize = 0;
		totalValueSize = 0;
		for (NSString *key in keys) {
			//NSLog (@"key -- %@",  key);

			ValueInfo *vi = [[EchoServer getDict] objectForKey:key];
			NSDictionary *cacheData;
			cacheData = [NSDictionary dictionaryWithObjectsAndKeys:
			             key, @"key",
			             [ self stringFromSeconds: lround([[NSDate date] timeIntervalSince1970] - vi.insertedAt)], @"inserted ago",
			             [self formatExpiresAt: vi.expiry insertedAt:vi.insertedAt], @"expires in",
			             [self stringFromFileSize: [key length]], @"key size",
			             [ NSString stringWithFormat: @"%d", vi.hits], @"hits",
			             [ self stringFromFileSize: [vi.data length]], @"value size",
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

-(NSString *)stringFromFileSize: (NSInteger)theSize{
	float floatSize = theSize;
    //if (theSize<1023)
//        return([NSString stringWithFormat:@"%i b",theSize]);
    floatSize = floatSize / 1024;
    if (floatSize<1023)
        return([NSString stringWithFormat:@"%1.2f KB",floatSize]);
    floatSize = floatSize / 1024;
    if (floatSize<1023)
        return([NSString stringWithFormat:@"%1.1f MB",floatSize]);
    floatSize = floatSize / 1024;
	
    return([NSString stringWithFormat:@"%1.1f GB",floatSize]);	
}

-(NSString *)stringFromSeconds: (NSInteger)totalSeconds{
	int hours = totalSeconds / (60*60);
	int seconds_remaing = totalSeconds % (60*60);
	int minutes = seconds_remaing / 60;
	int seconds = seconds_remaing % 60;
	
	return [NSString stringWithFormat: @"%d:%02d:%02d",hours, minutes, seconds];
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
			return [ self stringFromSeconds: left ];
		}
	}
}


@end
