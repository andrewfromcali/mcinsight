//
//  Runner.m
//  mcinsight
//
//  Created by aa on 7/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Runner.h"
#import "EchoServer.h"

@implementation Runner

- (void)run {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	EchoServer *es = [[EchoServer alloc] init];
	NSString *portString = @"11211";

	[es performSelector:@selector(acceptOnPortString:) withObject:portString afterDelay:1.0];
	[[NSRunLoop currentRunLoop] run];
	[EchoServer release];
	[es release];
	[pool release];
}

@end
