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
  [NSThread detachNewThreadSelector:@selector(run) toTarget:[Runner alloc] withObject:nil];
  [autoreleasepool release];
  return NSApplicationMain(argc,  (const char **) argv);
}
