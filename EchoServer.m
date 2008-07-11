
#import "EchoServer.h"

static NSMutableDictionary *dict;

@implementation EchoServer

+(NSDictionary*)getDict {
  return dict;
}

-(id) init
{
	self = [super init];
  dataMode = NO;
  dict = [NSMutableDictionary dictionary];
	sockets = [[NSMutableArray alloc] initWithCapacity:2];

	AsyncSocket *acceptor = [[AsyncSocket alloc] initWithDelegate:self];
	[sockets addObject:acceptor];
	[acceptor release];
	return self;
}

-(void) dealloc
{
	[sockets release];
	[super dealloc];
}

- (void) acceptOnPortString:(NSString *)str
{
	NSAssert ([[NSRunLoop currentRunLoop] currentMode] != nil, @"Run loop is not running");
	
	UInt16 port = [str intValue];
	AsyncSocket *acceptor = (AsyncSocket *)[sockets objectAtIndex:0];

	NSError *err = nil;
	if ([acceptor acceptOnPort:port error:&err])
		NSLog (@"Waiting for connections on port %u.", port);
	else
	{		
		NSLog (@"Cannot accept connections on port %u. Error domain %@ code %d (%@). Exiting.", port, [err domain], [err code], [err localizedDescription]);
		exit(1);
	}
}
-(void) onSocket:(AsyncSocket *)sock didReadData:(NSData*)data withTag:(long)tag
{
  // set session:99e825b027f10f2688b0a67ec570acca 0 1800 61\r\n
  // wefwelfkwelfwelfkwelfkwelfwef\r\n
  
  // get session:99e825b027f10f2688b0a67ec570acca
  // VALUE session:99e825b027f10f2688b0a67ec570acca 0 61\r\n
  // ewfjwekfjwekfjwekfjwekfjkwefjk\r\n
  // END
  
  // [sockets indexOfObject:sock]
  
  if (dataMode) {    
    dataMode = NO;
    //    [sock writeData:[@"STORED\r\n" dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1 tag:0];    
  } else {
    NSString *str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSString *str2 = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSArray *listItems = [str2 componentsSeparatedByString:@" "];
    
    if ([listItems count] == 1) {
      NSData *newline = [@"\n" dataUsingEncoding:NSASCIIStringEncoding];
      [sock readDataToData:newline withTimeout:-1 tag:tag];
      return;
    }
    
    NSString *command = [listItems objectAtIndex:0];
    NSString *key = [listItems objectAtIndex:1];
    
    if ([command isEqualToString:@"set"] || [command isEqualToString:@"add"] || [command isEqualToString:@"replace"] ||
        [command isEqualToString:@"append"] || [command isEqualToString:@"prepend"] || [command isEqualToString:@"cas"]) {
      //int expiry = [[listItems objectAtIndex:3] intValue];
      size = [[listItems objectAtIndex:4] intValue];
      dataMode = YES;
      [dict setObject:@"test" forKey:key];
      NSLog([dict description]);
      
      [sock writeData:[@"STORED\r\n" dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1 tag:0];
    } else if ([command isEqualToString:@"get"] || [command isEqualToString:@"gets"]) {
      [sock writeData:[@"END\r\n" dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1 tag:0];      
    } else if ([command isEqualToString:@"incr"]) {
      [sock writeData:[@"NOT_FOUND\r\n" dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1 tag:0];      
    } else if ([command isEqualToString:@"decr"]) {
      [sock writeData:[@"NOT_FOUND\r\n" dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1 tag:0];      
    } else if ([command isEqualToString:@"delete"]) {
      [sock writeData:[@"DELETED\r\n" dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1 tag:0];      
    }
  }
  
  NSData *newline = [@"\n" dataUsingEncoding:NSASCIIStringEncoding];
	[sock readDataToData:newline withTimeout:-1 tag:tag];
}

-(void) onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
	if (err != nil)
		NSLog (@"Socket will disconnect. Error domain %@, code %d (%@).",
           [err domain], [err code], [err localizedDescription]);
	else
		NSLog (@"Socket will disconnect. No error.");
}


-(void) onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
	NSLog (@"Socket %d accepting connection.", [sockets count]);
	[sockets addObject:newSocket];
}

-(void) onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	NSLog (@"Socket %d successfully accepted connection from %@ %u.", [sockets indexOfObject:sock], host, port);
	NSData *newline = [@"\n" dataUsingEncoding:NSASCIIStringEncoding];
	
	[sock readDataToData:newline withTimeout:-1 tag:[sockets indexOfObject:sock]];
}


-(void) onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
	NSLog (@"Wrote to socket %d.", tag);
}




@end
