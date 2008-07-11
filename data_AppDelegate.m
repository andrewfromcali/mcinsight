
#import "data_AppDelegate.h"
#import "EchoServer.h";

static BOOL threadStarted = NO;

@implementation data_AppDelegate

@synthesize table;

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
  
  if (!threadStarted) {
    [NSThread detachNewThreadSelector:@selector(run) toTarget:self withObject:nil];
    threadStarted = YES;
  }
  
  return [[EchoServer getDict] count];
  //return 1000;
}

- (void)run {
  while (TRUE) {
    [table reloadData];
    sleep(1);
  }
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
  NSString *col = [[aTableColumn headerCell] stringValue];
  
  NSArray *keys = [[EchoServer getDict] allKeys];
  
  NSArray *sortedArray = [keys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
  
  if ([col isEqualToString:@"key"])
    return [sortedArray objectAtIndex:rowIndex];
  if ([col isEqualToString:@"inserted ago"])
    return @"00:00:30";
  if ([col isEqualToString:@"expires in"])
    return @"00:30:00";
  if ([col isEqualToString:@"key size"])
    return @"19 bytes";
  if ([col isEqualToString:@"value size"])
    return @"3.2 KB";
  
  return @"";
}

- (void) dealloc {
  [table release];
  [super dealloc];
}


@end
