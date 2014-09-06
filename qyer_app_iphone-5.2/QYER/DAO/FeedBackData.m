//
//  FeedBackData.m
//  QyGuide
//
//  Created by 你猜你猜 on 13-10-14.
//
//

#import "FeedBackData.h"
#import "QYAPIClient.h"
#import "DeviceInfo.h"


@implementation FeedBackData


//用户反馈信息上传给服务器:
+(void)postUserFeedBackWithContent:(NSString *)content_feedback
                    andMailAddress:(NSString *)mail_address
                          finished:(FeedBackDataSuccessBlock)finished
                            failed:(FeedBackDataFailedBlock)failed
{
    //用户名称:
    BOOL isLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"qyerlogin"];
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    if (isLogin == NO)
    {
        userName = @"游客";
    }
    
    //用户的邮件地址:
    NSString *mailInfo = mail_address;
    if(mail_address.length > 0)
    {
        [[NSUserDefaults standardUserDefaults] setObject:mail_address forKey:@"userfeedback_mail"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"userfeedback_mail"])
        {
            mailInfo = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"userfeedback_mail"]];
        }
        else
        {
            mailInfo = @"无";
        }
    }
    
    
    //用户的反馈内容:
    NSString *content = @"";
    content = [NSString stringWithFormat:@"设备名称：%@|系统版本：%@|应用版本：%@|用户：%@|内容：%@|邮箱:%@",[DeviceInfo getDeviceName_detail],[DeviceInfo getDeviceSystemVersion],[DeviceInfo getAppVersion],userName,content_feedback,mailInfo];
    
    
    //发送消息:
    [[QYAPIClient sharedAPIClient] postUserFeedBackWithContent:content
                                                 finished:^(NSDictionary *dic){
                                                     
                                                     NSLog(@"  ------- dic : %@",dic);
                                                     
                                                     if(dic && [dic objectForKey:@"status"])
                                                     {
                                                         if([[dic objectForKey:@"status"] intValue] - 1 == 0)
                                                         {
                                                             NSLog(@" push - feedbackData 成功");
                                                         }
                                                         else
                                                         {
                                                             NSLog(@" push - feedbackData 失败(1)");
                                                         }
                                                     }
                                                     else
                                                     {
                                                         NSLog(@" push - feedbackData 失败(2)");
                                                     }
                                                 }
                                                   failed:^{
                                                       NSLog(@" push - feedbackData 失败(3)");
                                                   }];
    
}

@end
