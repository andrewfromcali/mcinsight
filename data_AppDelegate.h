
#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>

@interface data_AppDelegate : NSObject {
  IBOutlet NSTableView *table;    
  IBOutlet NSTextField *text;
}

@property (nonatomic, retain) NSTableView *table;
@property (nonatomic, retain) NSTextField *text;

@end
