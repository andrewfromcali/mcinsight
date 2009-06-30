//
//  MemcacheSnapshot.h
//  mcinsight
//
//  Created by Gerard Gualberto on 6/28/09.
//  Copyright 2009 Tierra Innovation. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MemcacheSnapshot : NSObject {
	
}

-(NSInteger)totalKeys;
-(NSInteger)totalKeySize;
-(NSInteger)totalValueSize;
-(NSDictionary*)getEntryAt: (NSInteger)index;
-(NSString*)formatExpiresAt: (NSInteger)expiresAt insertedAt:(NSInteger)insertedAt;
@end
