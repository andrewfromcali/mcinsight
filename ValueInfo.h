//
//  ValueInfo.h
//  mcinsight
//
//  Created by aa on 7/11/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ValueInfo : NSObject {
  NSMutableData *data;
  NSString *key;
  NSString *command;
  int expiry;
  int hits;
  NSString *flag;
  NSTimeInterval insertedAt;
  long incr_decr;
}

@property (nonatomic, retain) NSMutableData *data;
@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *command;
@property (nonatomic, retain) NSString *flag;
@property int expiry;
@property int hits;
@property long incr_decr;
@property NSTimeInterval insertedAt;
@end
