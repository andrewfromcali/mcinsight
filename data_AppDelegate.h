
#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>
#import "MemcacheSnapshot.h"

@interface data_AppDelegate : NSObject {
	IBOutlet NSTableView *table;    
	IBOutlet NSTextView *text;
	IBOutlet NSPopUpButton *pop;
	IBOutlet NSTextField *totalKeysTextField;
	IBOutlet NSTextField *cacheHitsTextField;
	IBOutlet NSTextField *cacheMissesTextField;
	IBOutlet NSTextField *hitRatioTextField;
	IBOutlet NSTextField *totalKeySizeTextField;
	IBOutlet NSTextField *totalValueSizeTextField;
	IBOutlet NSSearchField *searchField;
	NSArray *descriptors;
	NSString *searchFilter;
	MemcacheSnapshot *memcacheSnapshot;
}

- (IBAction) flushAll: (id) sender;
- (IBAction) flushSelected: (id) sender;
- (IBAction) search: (id) sender;
@property (nonatomic, retain) NSTableView *table;
@property (nonatomic, retain) NSTextView *text;
@property (nonatomic, retain) NSPopUpButton *pop;
@property (nonatomic, retain) NSArray *descriptors;
@property (nonatomic, retain) NSString *searchFilter;
@property (retain) MemcacheSnapshot *memcacheSnapshot;
@end
