//
//  CheckNetStatus.h
//  NewPackingList
//
//  Created by an qing on 12-9-21.
//
//

#import <Foundation/Foundation.h>
//#import "QYERSNS.h"

@interface CheckNetStatus : NSObject
{
    //QYERSNS *myQyersns;
    float countNumber;
    
    NSInteger testNumber;
}

-(void)gettestNumber:(NSInteger)num;
+(int)checkMyNetStatus;
//-(void)getQyersns:(QYERSNS*)sns;
-(int)netStatus;

@end
