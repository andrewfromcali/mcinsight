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
  int expiry;
  int hits;
  int flag;
  NSTimeInterval insertedAt;
}

@property (nonatomic, retain) NSMutableData *data;
@property (nonatomic, retain) NSString *key;
@property int expiry;
@property int hits;
@property int flag;
@property NSTimeInterval insertedAt;
@end
