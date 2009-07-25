//
//  main.m
//  mcinsight
//
//  Created by aa on 7/9/08.
//  Copyright __MyCompanyName__ 2008. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Runner.h"


int main(int argc, char *argv[])
{
	NSAutoreleasePool	 *autoreleasepool = [[NSAutoreleasePool alloc] init];
	Runner *runner	= [Runner alloc];
	[NSThread detachNewThreadSelector:@selector(run) toTarget:runner withObject:nil];
	[runner release];
	[autoreleasepool release];
	return NSApplicationMain(argc,  (const char **) argv);
}
