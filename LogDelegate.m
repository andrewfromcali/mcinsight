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

static BOOL logThreadStarted = NO;

@implementation LogDelegate

@synthesize table;

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {

	if (!logThreadStarted) {
		[NSThread detachNewThreadSelector:@selector(run) toTarget:self withObject:nil];
		logThreadStarted = YES;
	}

	return [[EchoServer getLog] count];
}

- (void)run {
	while (TRUE) {
		[table reloadData];
		sleep(1);
	}
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	NSString *col = [[aTableColumn headerCell] stringValue];

	LogInfo *info = [[EchoServer getLog] objectAtIndex:rowIndex];

	if ([col isEqualToString:@"#"])
		return [NSString stringWithFormat:@"%d", rowIndex];
	if ([col isEqualToString:@"id"])
		return [NSString stringWithFormat:@"%ld", info.sid];
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
