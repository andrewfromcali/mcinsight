
#import <Foundation/Foundation.h>
#import "AsyncSocket.h"
#import "ValueInfo.h"

@interface EchoServer : NSObject
{
	NSMutableArray *sockets;
}
+(NSMutableDictionary*)getDict;
+(NSMutableArray*)getLog;
-(id) init;
-(void) dealloc;
-(void) acceptOnPortString:(NSString *)str;
-(void) onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err;
-(void) onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket;
-(void) onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port;
-(void) onSocket:(AsyncSocket *)sock didReadData:(NSData*)data withTag:(long)tag;
-(void) onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag;
@end
