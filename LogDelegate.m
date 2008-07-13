//
//  LogDelegate.m
//  mcinsight
//
//  Created by aa on 7/13/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "LogDelegate.h"
#import "EchoServer.h"
#import "LogInfo.h"

@implementation LogDelegate

@synthesize table;

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
  
  return [[EchoServer getLog] count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
  NSString *col = [[aTableColumn headerCell] stringValue];
    
  LogInfo *info = [[EchoServer getLog] objectAtIndex:rowIndex];
  
  if ([col isEqualToString:@"#"])
    return [NSString stringWithFormat:@"%d", rowIndex];
  if ([col isEqualToString:@"id"])
    return [NSString stringWithFormat:@"%d", info.sid];
  if ([col isEqualToString:@"data"])
    return info.data;
  if ([col isEqualToString:@"direction"]) {
    if (info.direction)
      return @"OUT";
    return @"IN";
  }
  
  return @"";
}

- (void) dealloc {
  [table release];
  [super dealloc];
}

@end
