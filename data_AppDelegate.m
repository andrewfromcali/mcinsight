#import "data_AppDelegate.h";
#import "EchoServer.h";
#import "ValueInfo.h";

static BOOL threadStarted = NO;

@implementation data_AppDelegate

@synthesize table;
@synthesize text;
@synthesize pop;
@synthesize descriptors;
@synthesize searchFilter;
@synthesize memcacheSnapshot;

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
		
		if ([descriptors count] > 0) {
			[memcacheSnapshot.entries sortUsingDescriptors:descriptors];
		} else {
			NSSortDescriptor *keyDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"key"
																		   ascending:YES
																			selector:@selector(localizedCaseInsensitiveCompare:)] autorelease];
			
			NSArray *initDescriptors = [NSArray arrayWithObjects:keyDescriptor, nil];
			[memcacheSnapshot.entries sortUsingDescriptors:initDescriptors];
		}
		
		[memcacheSnapshot filterBy:searchFilter];
		[table reloadData];
		[totalKeysTextField setIntValue:[memcacheSnapshot totalKeys]];
		[totalKeySizeTextField setStringValue: [memcacheSnapshot stringFromFileSize: [memcacheSnapshot totalKeySize]]];
		[totalValueSizeTextField setStringValue: [memcacheSnapshot stringFromFileSize: [memcacheSnapshot totalValueSize]]];

		[cacheHitsTextField setIntValue:[memcacheSnapshot cacheHits]];	
		[cacheMissesTextField setIntValue:[memcacheSnapshot cacheMisses]];
		[hitRatioTextField setStringValue:[memcacheSnapshot hitRatio]];		
		sleep(1);
		[memcacheSnapshot release];
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

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(int)rowIndex {
	NSMutableData *value = [[memcacheSnapshot getEntryAt:rowIndex] objectForKey:@"value"];

	NSString *pops = [[pop selectedItem] title];
	if ([pops isEqualToString:@"Hex"])
		[text setString:[value description]];
	else if ([pops isEqualToString:@"Plain Text"]){
		NSString *tempString = [[NSString alloc] initWithData:value encoding:NSASCIIStringEncoding];
		[text setString:tempString];
		[tempString release];
	}
	else if ([pops isEqualToString:@"Ruby Objects"]) {
		NSString *tempFile = @"/tmp/mc_results";
		[[NSFileManager defaultManager] createFileAtPath: tempFile contents: [NSData data] attributes: nil];
		[[NSFileManager defaultManager] createFileAtPath:@"/tmp/mc_data" contents:value attributes: nil];

		NSTask *myTask = [[NSTask alloc] init];
		[myTask setLaunchPath: @"/usr/bin/ruby"];
		[myTask setArguments: [NSArray arrayWithObjects:@"-e", @"f = File.open(\"/tmp/mc_data\"); puts Marshal.load(f.read).inspect; f.close", nil]];
		[myTask setStandardOutput: [NSFileHandle
		                            fileHandleForWritingAtPath: tempFile]];
		[myTask launch];
		[myTask waitUntilExit];
		[myTask release];
		
		NSString *tempString = [[NSString alloc] initWithData:[[NSFileManager defaultManager] contentsAtPath:tempFile]
													 encoding:NSASCIIStringEncoding];
		[text setString:tempString];
		[tempString release];
	}

	[text setFont:[NSFont fontWithName:@"Courier" size:14.0]];
	
	[table selectRowIndexes: [NSIndexSet indexSetWithIndex:rowIndex] byExtendingSelection:false];
	return true;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	
	NSString *col = [[aTableColumn headerCell] stringValue];
	NSDictionary *entry = [memcacheSnapshot getEntryAt:rowIndex];
	return [entry objectForKey:col];
}

- (void)tableView:(NSTableView *)aTableView sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
	NSArray *newDescriptors = [aTableView sortDescriptors];
	descriptors = newDescriptors;
	[memcacheSnapshot.entries sortUsingDescriptors:newDescriptors];
	[aTableView reloadData];
}

- (IBAction) flushAll: (id) sender {
	[[EchoServer getDict] removeAllObjects];
	[table reloadData];
	[text setString:@""];
}

- (IBAction) flushSelected: (id) sender {
	if ([table selectedRow] > -1) {
		NSDictionary *entry = [memcacheSnapshot getEntryAt:[table selectedRow]];
		[[EchoServer getDict] removeObjectForKey: [entry objectForKey:@"key"]];
		[table reloadData];
		[text setString:@""];
	}
}

- (IBAction) search: (id) sender {
	searchFilter = [searchField stringValue];
	NSLog(@"%@", searchFilter);
	[memcacheSnapshot filterBy:searchFilter];
	[table reloadData];
}

- (void) dealloc {
	[table release];
	[memcacheSnapshot release]; 
	[super dealloc];
}


@end
