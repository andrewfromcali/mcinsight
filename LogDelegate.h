
#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>

@interface LogDelegate : NSObject {
  IBOutlet NSTableView *table;    
}

@property (nonatomic, retain) NSTableView *table;

@end
