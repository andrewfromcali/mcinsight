
#import "EchoServer.h"
#import "ValueInfo.h"

static NSMutableDictionary *dict;

@implementation EchoServer

+(NSMutableDictionary*)getDict {
  return dict;
}

-(id) init
{
	self = [super init];
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

-(ValueInfo *)getVI:(NSString *)key {
  ValueInfo *temp = [dict objectForKey:key];
  
  if (temp == nil)
    return nil;
  
  if (temp.expiry == 0)
    return temp;
  int left = temp.expiry - lround([[NSDate date] timeIntervalSince1970] - temp.insertedAt);
  if (left < 1) {
    [dict removeObjectForKey:key];
    return nil;
  }
  return temp;
}

-(void) onSocket:(AsyncSocket *)sock didReadData:(NSData*)data withTag:(long)tag
{
  // set session:99e825b027f10f2688b0a67ec570acca 0 1800 61\r\n
  // wefwelfkwelfwelfkwelfkwelfwef\r\n
  
  NSLog(@"tag: %d", tag);
    
  if (sock.mc_dataMode) {    
    [sock.mc_vi.data appendData:data];
    
    if ([sock.mc_vi.data length] - 2 == sock.mc_size) {
      sock.mc_dataMode = NO;      
      [sock.mc_vi.data setLength:[sock.mc_vi.data length] - 2];
      sock.mc_vi.insertedAt = [[NSDate date] timeIntervalSince1970];
      
      ValueInfo *temp = [self getVI:sock.mc_vi.key];
      
      if ([sock.mc_vi.command isEqualToString:@"add"]) {
        if (temp == nil) {
          [dict setObject:sock.mc_vi forKey:sock.mc_vi.key];
          [sock writeData:[@"STORED\r\n" dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1 tag:tag];    
        }
        else
          [sock writeData:[@"NOT STORED\r\n" dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1 tag:tag];
      } else if ([sock.mc_vi.command isEqualToString:@"set"]) {
        [dict setObject:sock.mc_vi forKey:sock.mc_vi.key];
        [sock writeData:[@"STORED\r\n" dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1 tag:tag];
      } else if ([sock.mc_vi.command isEqualToString:@"append"]) {
        if (temp != nil) {
          [temp.data appendData:sock.mc_vi.data];
          [dict setObject:temp forKey:sock.mc_vi.key];
          [sock writeData:[@"STORED\r\n" dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1 tag:tag];
        } else
          [sock writeData:[@"NOT STORED\r\n" dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1 tag:tag];        
      } else if ([sock.mc_vi.command isEqualToString:@"prepend"]) {
        if (temp != nil) {
          [sock.mc_vi.data appendData:temp.data];
          temp.data = sock.mc_vi.data;
          [dict setObject:temp forKey:sock.mc_vi.key];
          [sock writeData:[@"STORED\r\n" dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1 tag:tag];
        } else
          [sock writeData:[@"NOT STORED\r\n" dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1 tag:tag];        
      } else if ([sock.mc_vi.command isEqualToString:@"cas"]) {
        [dict setObject:sock.mc_vi forKey:sock.mc_vi.key];
        [sock writeData:[@"STORED\r\n" dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1 tag:tag];
      } else if ([sock.mc_vi.command isEqualToString:@"replace"]) {
        if (temp != nil) {
          [dict setObject:sock.mc_vi forKey:sock.mc_vi.key];
          [sock writeData:[@"STORED\r\n" dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1 tag:tag];
        } else
          [sock writeData:[@"NOT STORED\r\n" dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1 tag:tag];
      }
    }
    
  } else {
    NSString *str = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSString *str2 = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    NSArray *listItems = [str2 componentsSeparatedByString:@" "];
    
    NSString *command = [listItems objectAtIndex:0];
    NSString *key = [listItems objectAtIndex:1];
    
    if ([command isEqualToString:@"set"] || [command isEqualToString:@"add"] || [command isEqualToString:@"replace"] ||
        [command isEqualToString:@"append"] || [command isEqualToString:@"prepend"] || [command isEqualToString:@"cas"]) {
      sock.mc_vi = [[ValueInfo alloc] init];
      sock.mc_vi.key = [listItems objectAtIndex:1];
      sock.mc_vi.flag = [listItems objectAtIndex:2];
      sock.mc_vi.expiry = [[listItems objectAtIndex:3] intValue];
      sock.mc_size = [[listItems objectAtIndex:4] intValue];
      sock.mc_dataMode = YES;
      sock.mc_vi.data = [NSMutableData alloc];
      sock.mc_vi.command = command;
    } else if ([command isEqualToString:@"get"] || [command isEqualToString:@"gets"]) {
      // get session:99e825b027f10f2688b0a67ec570acca
      // VALUE session:99e825b027f10f2688b0a67ec570acca 0 61\r\n
      // ewfjwekfjwekfjwekfjwekfjkwefjk\r\n
      // END
      int i = 1;
      while (true) {
        ValueInfo *temp = [self getVI:[listItems objectAtIndex:i]];
        if (temp) {
          temp.hits++;
          NSString *res = [NSString stringWithFormat:@"VALUE %@ %@ %d\r\n", temp.key, temp.flag, [temp.data length]];
          [sock writeData:[res dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1 tag:tag];
          [sock writeData:temp.data withTimeout:-1 tag:tag];
          [sock writeData:[@"\r\n" dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1 tag:tag];
        }
        i++;
        if (i >= [listItems count])
          break;
      }
      
      [sock writeData:[@"END\r\n" dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1 tag:tag];
    } else if ([command isEqualToString:@"incr"]) {
      ValueInfo *temp = [self getVI:key];

      if (temp) {
        // TODO: real incr
        [sock writeData:[@"1\r\n" dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1 tag:tag];
      } else       
        [sock writeData:[@"NOT_FOUND\r\n" dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1 tag:tag];      
    } else if ([command isEqualToString:@"decr"]) {
      ValueInfo *temp = [self getVI:key];
       if (temp) {
         // TODO: real decr
         [sock writeData:[@"0\r\n" dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1 tag:tag];
       } else       
         [sock writeData:[@"NOT_FOUND\r\n" dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1 tag:tag];
    } else if ([command isEqualToString:@"delete"]) {
      ValueInfo *temp = [dict objectForKey:key];
      if (temp) {
        [[EchoServer getDict] removeObjectForKey:key];
      }
      [sock writeData:[@"DELETED\r\n" dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1 tag:tag];
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
