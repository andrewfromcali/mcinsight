
#import "data_AppDelegate.h";
#import "EchoServer.h";
#import "ValueInfo.h";
#import "MemcacheSnapshot.h";

static BOOL threadStarted = NO;
static MemcacheSnapshot *memcacheSnapshot;

@implementation data_AppDelegate

@synthesize table;
@synthesize text;
@synthesize pop;

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
  
  if (!threadStarted) {
    [NSThread detachNewThreadSelector:@selector(run) toTarget:self withObject:nil];
    threadStarted = YES;
  }
  
  return [memcacheSnapshot totalKeys];
}

- (void)run {
  while (TRUE) {
	NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
	
	memcacheSnapshot = [[MemcacheSnapshot alloc] init];
    [table reloadData];
	[totalKeysTextField setIntValue:[memcacheSnapshot totalKeys]];
	[totalKeySizeTextField setIntValue:[memcacheSnapshot totalKeySize]];
	[totalValueSizeTextField setIntValue:[memcacheSnapshot totalValueSize]];
  
	
	//[cacheHitsTextField setIntValue:[memcacheSnapshot cacheHits]];
//    [cacheMissesTextField setIntValue:[memcacheSnapshot cacheMisses]];
//	[hitRatioTextField setIntValue:[memcacheSnapshot hitRatio]];
		
    sleep(1);
	
	[autoreleasepool release];
  }
}

- (CGFloat)splitView:(NSSplitView *)sender constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)offset {
  return proposedMax-100;
}
- (CGFloat)splitView:(NSSplitView *)sender constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)offset {
  return proposedMin+100;
}
- (CGFloat)splitView:(NSSplitView *)sender constrainSplitPosition:(CGFloat)proposedPosition ofSubviewAt:(NSInteger)offset {
  return proposedPosition;
}

//- (void)tableViewSelectionIsChanging:(NSNotification *)aNotification {
- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(int)rowIndex {
  NSArray *keys = [[EchoServer getDict] allKeys];
  
  NSArray *sortedArray = [keys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
  NSString *key = [sortedArray objectAtIndex:rowIndex];
  ValueInfo *vi = [[EchoServer getDict] objectForKey:key];

  NSString *pops = [[pop selectedItem] title];
  if ([pops isEqualToString:@"Hex"])
    [text setString:[vi.data description]];
  else if ([pops isEqualToString:@"Plain Text"])
    [text setString:[[NSString alloc] initWithData:vi.data encoding:NSASCIIStringEncoding]];
  else if ([pops isEqualToString:@"Ruby Objects"]) {    
    NSString *tempFile = @"/tmp/mc_results";
    [[NSFileManager defaultManager] createFileAtPath: tempFile contents: [NSData data] attributes: nil];
    [[NSFileManager defaultManager] createFileAtPath:@"/tmp/mc_data" contents:vi.data attributes: nil];
    
    NSTask *myTask = [[NSTask alloc] init];
    [myTask setLaunchPath: @"/usr/local/bin/ruby"];
    [myTask setArguments: [NSArray arrayWithObjects:@"-e", @"f = File.open(\"/tmp/mc_data\"); puts Marshal.load(f.read).inspect; f.close"]];
    [myTask setStandardOutput: [NSFileHandle  
                                 fileHandleForWritingAtPath: tempFile]];
    [myTask launch];
    [myTask waitUntilExit];
    
    [text setString:[[NSString alloc] initWithData:[[NSFileManager defaultManager] contentsAtPath:tempFile]
                                          encoding:NSASCIIStringEncoding]];
  }
  
  [text setFont:[NSFont fontWithName:@"Courier" size:14.0]];

  [table selectRow:rowIndex byExtendingSelection:false];
  return true;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	NSString *col = [[aTableColumn headerCell] stringValue];
	NSDictionary *entry = [memcacheSnapshot getEntryAt:rowIndex];
	return [entry objectForKey:col];
}

- (void) dealloc {
  [table release];
  [super dealloc];
}


@end
