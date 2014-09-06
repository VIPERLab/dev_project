//
//  CheckNetStatus.m
//  NewPackingList
//
//  Created by an qing on 12-9-21.
//
//


#import "CheckNetStatus.h"
#import "Reachability.h"


@implementation CheckNetStatus


-(void)dealloc
{
    [super dealloc];
}


-(int)netStatus
{
    Reachability *r = [Reachability reachabilityWithHostname:@"www.apple.com"];
	switch ([r currentReachabilityStatus])
    {
		case NotReachable:       //(1)无网络连接
        {
			return 0;
			break;
		}
		case ReachableViaWWAN:    //(2)使用3G网络
			
			return 1;
			break;
		case ReachableViaWiFi:    //(3)使用WiFi网络
			
			return 2;
			break;
	}
	return -1;
}


-(void)gettestNumber:(NSInteger)num
{
    testNumber = num;
}
+(int)checkMyNetStatus
{
    Reachability *r = [Reachability reachabilityWithHostname:@"www.apple.com"];
	switch ([r currentReachabilityStatus])
    {
		case NotReachable:        //(1)无网络连接
        {
            return 0;
		}
			break;
		case ReachableViaWWAN:    //(2)使用3G网络
        {
            return 1;
        }
			break;
		case ReachableViaWiFi:    //(3)使用WiFi网络
        {
            return 2;
        }
			break;
            
        default:
        {
            return -1;
        }
            break;
	}
    return -2;
}




@end
