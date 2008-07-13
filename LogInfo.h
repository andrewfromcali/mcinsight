//
//  LogInfo.h
//  mcinsight
//
//  Created by aa on 7/13/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LogInfo : NSObject {
  long sid;
  NSString *data;
  BOOL direction;
}

@property (nonatomic, retain) NSString *data;
@property long sid;
@property BOOL direction;

@end
