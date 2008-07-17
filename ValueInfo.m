//
//  ValueInfo.m
//  mcinsight
//
//  Created by aa on 7/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ValueInfo.h"


@implementation ValueInfo

@synthesize data;
@synthesize expiry;
@synthesize key;
@synthesize insertedAt;
@synthesize hits;
@synthesize flag;
@synthesize command;
@synthesize incr_decr;

-(void) init {
  hits=0;
}

@end
