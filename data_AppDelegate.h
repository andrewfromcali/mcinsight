
#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>

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
}

@property (nonatomic, retain) NSTableView *table;
@property (nonatomic, retain) NSTextView *text;
@property (nonatomic, retain) NSPopUpButton *pop;
@end
