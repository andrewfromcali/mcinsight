
#import "data_AppDelegate.h"
#import "EchoServer.h";
#import "ValueInfo.h";

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
  NSString *key = [sortedArray objectAtIndex:rowIndex];
  ValueInfo *vi = [[EchoServer getDict] objectForKey:key];

  if ([col isEqualToString:@"key"])
    return key;
  if ([col isEqualToString:@"inserted ago"])
    return [ NSString stringWithFormat: @"%f", [[NSDate date] timeIntervalSince1970] - vi.insertedAt];
  if ([col isEqualToString:@"expires in"])
    return [ NSString stringWithFormat: @"%d", vi.expiry];
  if ([col isEqualToString:@"key size"])
    return [ NSString stringWithFormat: @"%d", [key length]];
  if ([col isEqualToString:@"value size"])
    return [ NSString stringWithFormat: @"%d", [vi.data length]];
  
  return @"";
}

- (void) dealloc {
  [table release];
  [super dealloc];
}


@end
