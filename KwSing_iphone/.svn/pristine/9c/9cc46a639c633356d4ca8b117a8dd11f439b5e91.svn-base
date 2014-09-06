//
//  KSModalAlertView.m
//  KwSing
//
//  Created by Zhai HaiPIng on 12-12-14.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "KSModalAlertView.h"

@implementation KSModalAlertView

-(int)showModal
{
    self.delegate=self;
    self.tag=-1;
    [self show];
    CFRunLoopRun();
    return self.tag;
}
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    alertView.tag=buttonIndex;
    alertView.delegate=nil;
    CFRunLoopStop(CFRunLoopGetCurrent());
}

@end

