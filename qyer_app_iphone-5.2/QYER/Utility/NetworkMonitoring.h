//
//  NetworkMonitoring.h
//  QyGuide
//
//  Created by 回头蓦见 on 13-6-14.
//
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface NetworkMonitoring : NSObject
{
    Reachability *_hostReach;
}
+(NetworkMonitoring *)sharedNetworkMonitoring;
-(void)NetworkMonitor;
@end
