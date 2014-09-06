//
//  GetRemoteNotificationData.m
//  NewPackingList
//
//  Created by an qing on 13-1-5.
//
//


#import "GetRemoteNotificationData.h"
#import "ASIHTTPRequest.h"
#import "NSString+SBJSON.h"
#import "WebViewViewController.h"
#import "QYGuideData.h"
#import "QYGuide.h"
#import "GuideDetailViewController.h"
#import "specialGuideListViewController.h"
#import "MobClick.h"
#import "NoteAndChatViewController.h"
#import "RootViewController.h"
#import "CountryViewController.h"
#import "PoiDetailViewController.h"
#import "BBSDetailViewController.h"
//#import "LastMinuteDetailViewController.h"
#import "LastMinuteDetailViewControllerNew.h"
#import "UniqueIdentifier.h"
#import "DeviceInfo.h"
#import "RegexKitLite.h"




#define getdatamaxtime 10 //获取运营页面的请求超时时间



@implementation GetRemoteNotificationData
@synthesize openType;
@synthesize htmlString;

-(void)dealloc
{
    [pushMsg release];
    [title release];
    [htmlString release];
    [allGuideDataArray removeAllObjects];
    [allGuideDataArray release];
    [content release];
    [guideIdArray release];
    
    [pushGuide release];
//    [myRootVC release];
    
    [specialGuideListVC release];
    [guideDetailVC release];
    [_webVC release];
    [pushNavigationVC.view removeFromSuperview];
    [pushNavigationVC release];
    
    self.htmlString = nil;
    
//    [myWindow release];
    
    [super dealloc];
}


static GetRemoteNotificationData *sharedGetRemoteNotificationData = nil;
+(id)sharedGetRemoteNotificationData
{
    if(!sharedGetRemoteNotificationData)
    {
        sharedGetRemoteNotificationData = [[self alloc] init];
    }
    return sharedGetRemoteNotificationData;
}


-(id)init
{
    if(self = [super init])
    {
        if(!allGuideDataArray)
        {
            allGuideDataArray = [[NSMutableArray alloc] init];
        }
    }
    
    return self;
}
-(void)createPushNavigationVC
{
    if(!pushNavigationVC)
    {
        UIViewController *ccc = [[[UIViewController alloc] init] autorelease];
        pushNavigationVC = [[UINavigationController alloc] initWithRootViewController:ccc];
        ccc.view.backgroundColor = [UIColor clearColor];
    }
    pushNavigationVC.view.backgroundColor = [UIColor clearColor];
    pushNavigationVC.navigationBarHidden = YES;
    //[[[UIApplication sharedApplication] keyWindow] addSubview:pushNavigationVC.view];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:pushNavigationVC.view];
}
-(void)getAllGuideData
{
    [allGuideDataArray addObjectsFromArray:[QYGuideData getAllGuide]];
    //[allGuideDataArray addObjectsFromArray:[[DataManager sharedManager] unarchiveDataFromCache:@"GuideList"]];
}
-(void)getGuideWithId:(NSInteger)guideId
{
    for(int i = 0; i < [allGuideDataArray count]; i++)
    {
        if([[(QYGuide*)[allGuideDataArray objectAtIndex:i] guideId] intValue] == guideId)
        {
            if(![pushGuide isEqual:[allGuideDataArray objectAtIndex:i]])
            {
                [pushGuide release];
            }
            pushGuide = [[allGuideDataArray objectAtIndex:i] retain];
            
            break;
        }
    }
}



//添加一些必传的参数
-(NSString *)getRequestUrl:(NSString *)string_url
{
    NSString *track_user_id = @"";
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"qyerlogin"] boolValue] == YES)
    {
        track_user_id = [[NSUserDefaults standardUserDefaults] objectForKey:@"userid"];
    }
    NSString *track_deviceid = [UniqueIdentifier getIdfa];
    NSString *track_app_version = [DeviceInfo getAppVersion];
    NSString *track_device_info = [DeviceInfo getDeviceName_detail];
    track_device_info = [track_device_info stringByReplacingOccurrencesOfRegex:@" " withString:@"%20"];
    NSString *track_os = [DeviceInfo getDeviceSystemVersion];
    track_os = [NSString stringWithFormat:@"ios %@",track_os];
    track_os = [track_os stringByReplacingOccurrencesOfRegex:@" " withString:@"%20"];
    NSString *channel = [appChannel_UMeng stringByReplacingOccurrencesOfRegex:@" " withString:@"%20"];
    NSString *lat_user = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lat_user"]];
    NSString *lon_user = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"lon_user"]];
    
    
    
    NSString *str_url = [NSString stringWithString:[string_url stringByAppendingFormat:@"&"]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"client_id=%@",ClientId_QY]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&client_secret=%@",ClientSecret_QY]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&v=%@",API_version]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&track_user_id=%@",track_user_id]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&track_deviceid=%@",track_deviceid]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&track_app_version=%@",track_app_version]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&track_app_channel=%@",channel]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&track_device_info=%@",track_device_info]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&track_os=%@",track_os]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&lat=%@",lat_user]];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&lon=%@",lon_user]];
    
    
    NSString *access_token = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_access_token"];
    if(access_token)
    {
        str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&oauth_token=%@",access_token]];
    }
    
    
    NSString *appInstalltime = [[NSUserDefaults standardUserDefaults] objectForKey:@"appInstalltime_sec"];
    str_url = [NSString stringWithString:[str_url stringByAppendingFormat:@"&app_installtime=%@",appInstalltime]];
    
    return str_url;
}



-(void)getPushDataByClientid:(NSString *)client_id
            andClientSecrect:(NSString *)client_secrect
                andExtend_id:(NSInteger)extend_id
                    finished:(myFinishedBlock)finished
                      failed:(myFailedBlock)failed
                    withFlag:(BOOL)flag
                      andMsg:(NSString*)pushMseeage
{
    //NSLog(@"获取数据 ~~~~~~~~");
    
    NSString *url_str = [NSString stringWithFormat:@"%@/app/get_push_extend?id=%d",DomainName,extend_id];
    url_str = [self getRequestUrl:url_str];
    
    __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url_str]];
    request.timeOutSeconds = getdatamaxtime;
    NSLog(@"推送url = %@",[request.url absoluteString]);
    
    [request setCompletionBlock:^{
        
        NSString *result = [request responseString];
        
        if([[[result JSONValue] objectForKey:@"status"] intValue] == 1)
        {
            NSLog(@"  获取推送数据成功");
            NSDictionary *dic = [[result JSONValue] valueForKey:@"data"];
            
            //NSUserDefaults *myDefault = [NSUserDefaults standardUserDefaults];
            //[myDefault setObject:dic forKey:@"pushdata"];
            //[myDefault synchronize];
            
            [self produceData:dic finished:finished failed:failed
                     withFlag:flag  andMsg:pushMseeage];
        }
        else
        {
            NSLog(@"  获取推送数据失败 -- 1");
            //NSUserDefaults *myDefault = [NSUserDefaults standardUserDefaults];
            //NSDictionary *dic = [myDefault objectForKey:@"pushdata"];
            
            //[self produceData:dic finished:finished failed:failed withFlag:flag];
        }
    }];
    
    [request setFailedBlock:^{
        NSLog(@"  获取推送数据失败 -- 2");
        //NSUserDefaults *myDefault = [NSUserDefaults standardUserDefaults];
        //NSDictionary *dic = [myDefault objectForKey:@"pushdata"];
        
        //[self produceData:dic finished:finished failed:failed withFlag:flag];
    }];
    [request startAsynchronous];
}

-(void)pushGuideDetailViewWithFlag:(BOOL)flag
{
    if(flag == 1)
    {
        if(!guideDetailVC)
        {
            guideDetailVC = [[GuideDetailViewController alloc] init];
        }
        guideDetailVC.flag_new = YES;
        guideDetailVC.guideId = [pushGuide guideId];
        [guideDetailVC setGuide:pushGuide];
        
        guideDetailVC.fromPushFlag = 1;
        [guideDetailVC getRemoteNotificationClass:self];
        
        //[(UINavigationController*)myRootVC pushViewController:guideDetailVC animated:YES];
        [self createPushNavigationVC];
        [self performSelector:@selector(pushVC:) withObject:guideDetailVC afterDelay:0.1];
        
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:nil
                                  message:pushMsg
                                  delegate:self
                                  cancelButtonTitle:@"忽略"
                                  otherButtonTitles:@"查看",nil];
        alertView.delegate = self;
        [alertView show];
        alertView.tag = 10001;
    }
}
-(void)pushSpecialViewWithFlag:(BOOL)flag
{
    if(flag == 1)
    {
        if(!specialGuideListVC)
        {
            specialGuideListVC = [[specialGuideListViewController alloc] init];
        }
        specialGuideListVC.navigationTitle = title;
        specialGuideListVC.content = content;
        
        //specialGuideListVC.guideIdArray = guideIdArray;
        NSMutableArray *array_guide = [self getGuideByGuideId:guideIdArray];
        specialGuideListVC.array_specialGuide = array_guide;
        
        specialGuideListVC.fromPushFlag = 1;
        [specialGuideListVC getRemoteNotificationClass:self];
        
        
        //[(UINavigationController*)myRootVC pushViewController:specialGuideListVC animated:YES];
        [self createPushNavigationVC];
        [self performSelector:@selector(pushVC:) withObject:specialGuideListVC afterDelay:0.1];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:nil
                                  message:pushMsg
                                  delegate:self
                                  cancelButtonTitle:@"忽略"
                                  otherButtonTitles:@"查看",nil];
        alertView.delegate = self;
        [alertView show];
        alertView.tag = 10003;
    }
}
-(void)pushVC:(UIViewController*)VC
{
    [pushNavigationVC pushViewController:VC animated:YES];
}
-(void)setPushMsg:(NSString*)pushMesage
{
    if(![pushMsg isEqualToString:pushMesage])
    {
        [pushMsg release];
    }
    pushMsg = [pushMesage retain];
}
-(void)setPushMsg2:(NSDictionary*)dic
{
//    if(![myWindow isEqual:[[UIApplication sharedApplication] keyWindow]])
//    {
//        [myWindow release];
//    }
//    myWindow = [[[UIApplication sharedApplication] keyWindow] retain];
//    
//    if(![myRootVC isEqual:[[[UIApplication sharedApplication] keyWindow] rootViewController]])
//    {
//        [myRootVC release];
//    }
//    myRootVC = [[[[UIApplication sharedApplication] keyWindow] rootViewController] retain];
    
    if(![content isEqualToString:[dic objectForKey:@"content"]])
    {
        [content release];
    }
    content = [[dic objectForKey:@"content"] retain];
    
    if(![title isEqualToString:[dic objectForKey:@"title"]])
    {
        [title release];
    }
    title = [[dic objectForKey:@"title"] retain];
    
    if(![guideIdArray isEqualToArray:[[dic objectForKey:@"ids"] componentsSeparatedByString:@","]])
    {
        [guideIdArray release];
    }
    guideIdArray = [[[dic objectForKey:@"ids"] componentsSeparatedByString:@","] retain];
}

-(void)produceData:(NSDictionary*)dic
          finished:(myFinishedBlock)finished
            failed:(myFailedBlock)failed
          withFlag:(BOOL)flag  //flag=0表示:应用还未从后台退出 ; flag=1表示:应用已从后台退出
            andMsg:(NSString*)pushMesage
{
    [self setPushMsg:pushMesage];
    
    if(dic)
    {
        [self setPushMsg2:dic];
        
        if([[dic objectForKey:@"open_type"] intValue] == 3 || [[dic objectForKey:@"open_type"] intValue] == 4)
        {
            [self openHtmlOrSafariWithHtml:[dic objectForKey:@"url"] withOpentype:[[dic objectForKey:@"open_type"] intValue] byFlag:flag andMsg:pushMesage];
        }
        else if([[dic objectForKey:@"open_type"] intValue] == 1) //打开详情页
        {
            if(guideIdArray && [guideIdArray count] > 0)
            {
                [self getAllGuideData];
                [self getGuideWithId:[[guideIdArray objectAtIndex:0] intValue]];
                
                if(pushGuide)
                {
                    [self pushGuideDetailViewWithFlag:flag];
                }
            }
        }
        else if([[dic objectForKey:@"open_type"] intValue] == 2) //打开列表页
        {
            [self pushSpecialViewWithFlag:flag];
        }
        else if(flag == 0 && [[dic objectForKey:@"open_type"] intValue] == 5)
        {
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:nil
                                      message:pushMesage
                                      delegate:self
                                      cancelButtonTitle:@"我知道了"
                                      otherButtonTitles:nil];
            alertView.delegate = self;
            [alertView show];
        }
        else if([[dic objectForKey:@"open_type"] intValue] == 6)
        {
            NSLog(@" dic : %@",dic);
            [self pustNoteAndChatVC];
        }
        
        if(finished)
        {
            finished();
        }
    }
    else
    {
        if(failed)
        {
            failed();
        }
    }
}

-(void)openHtmlOrSafariWithHtml:(NSString*)html withOpentype:(NSInteger)opentype byFlag:(BOOL)flag andMsg:(NSString*)pushMesage
{
    if(flag == 1)
    {
        if(opentype == 3)
        {
            if([html rangeOfString:@"place.qyer.com/country/"].location != NSNotFound ||
               [html rangeOfString:@"/place/country/"].location != NSNotFound) //国家首页
            {
                NSLog(@"    推送  ---  国家首页");
                NSString *mark_string = @"/country/";
                NSRange range = [html rangeOfString:mark_string];
                NSInteger position = range.location + mark_string.length;
                NSString *str_id = [html substringFromIndex:position];
                
                
                CountryViewController *counVc = [[CountryViewController alloc]init];
                counVc.type = 1;
                counVc.key = str_id;
                UINavigationController *rootVC = (UINavigationController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
                [rootVC pushViewController:counVc animated:YES];
                [counVc release];
            }
            else if([html rangeOfString:@"place.qyer.com/city/"].location != NSNotFound ||
                    [html rangeOfString:@"/place/city/"].location != NSNotFound) //城市首页
            {
                NSLog(@"    推送  ---  城市首页");
                NSString *mark_string = @"/city/";
                NSRange range = [html rangeOfString:mark_string];
                NSInteger position = range.location + mark_string.length;
                NSString *str_id = [html substringFromIndex:position];
                
                NSLog(@"__________ %@ _________",str_id);
                
                
                CountryViewController *counVc = [[CountryViewController alloc]init];
                counVc.type = 2;
                counVc.key = str_id;
                UINavigationController *rootVC = (UINavigationController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
                [rootVC pushViewController:counVc animated:YES];
                [counVc release];
                
            }
            else if([html rangeOfString:@"guide.qyer.com/"].location != NSNotFound ||
                    [html rangeOfString:@"/guide/"].location != NSNotFound) //锦囊详情页
            {
                NSLog(@"    推送  ---  锦囊详情页");
                NSString *mark_string = @"/guide/";
                NSRange range = [html rangeOfString:mark_string];
                if(range.location != NSNotFound)
                {
                    NSInteger position = range.location + mark_string.length;
                    NSString *str_id = [html substringFromIndex:position];
                    
                    
                    GuideDetailViewController *guideDetailVC_ = [[GuideDetailViewController alloc] init];
                    guideDetailVC_.flag_new = YES;
                    guideDetailVC_.guideId = str_id;
                    UINavigationController *rootVC = (UINavigationController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
                    [rootVC pushViewController:guideDetailVC_ animated:YES];
                    [guideDetailVC_ release];
                }
                else
                {
                    NSString *mark_string = @"guide.qyer.com/";
                    NSRange range = [html rangeOfString:mark_string];
                    NSInteger position = range.location + mark_string.length;
                    NSString *str_id = [html substringFromIndex:position];
                    
                    
                    GuideDetailViewController *guideDetailVC_ = [[GuideDetailViewController alloc] init];
                    guideDetailVC_.flag_new = YES;
                    guideDetailVC_.guideId = str_id;
                    UINavigationController *rootVC = (UINavigationController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
                    [rootVC pushViewController:guideDetailVC_ animated:YES];
                    [guideDetailVC_ release];
                }
                
            }
            else if([html rangeOfString:@"place.qyer.com/poi/"].location != NSNotFound ||
                    [html rangeOfString:@"/place/poi/"].location != NSNotFound) //poi详情页
            {
                NSLog(@"    推送  ---  poi详情页");
                NSString *mark_string = @"/poi/";
                NSRange range = [html rangeOfString:mark_string];
                NSInteger position = range.location + mark_string.length;
                NSString *str_id = [html substringFromIndex:position];
                
                PoiDetailViewController *poiDetailVC = [[PoiDetailViewController alloc] init];
                poiDetailVC.poiId = [str_id intValue];
                UINavigationController *rootVC = (UINavigationController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
                [rootVC pushViewController:poiDetailVC animated:YES];
                [poiDetailVC release];
            }
            else if([html rangeOfString:@"bbs.qyer.com/thread-"].location != NSNotFound ||
                    [html rangeOfString:@"/bbs/thread"].location != NSNotFound) //帖子详情页
            {
                NSLog(@"    推送  ---  帖子详情页");
                
                BBSDetailViewController * bbsDetailVC = [[BBSDetailViewController alloc]init];
                bbsDetailVC.bbsAllUserLink = html;
//                bbsDetailVC.bbsAuthorLink = nil;
                UINavigationController *rootVC = (UINavigationController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
                [rootVC pushViewController:bbsDetailVC animated:YES];
                [bbsDetailVC release];
                
            }
            else if([html rangeOfString:@"plan.qyer.com/trip/"].location != NSNotFound ||
                    [html rangeOfString:@"/plan/trip/"].location != NSNotFound) //行程详情页
            {
                NSLog(@"    推送  ---  行程详情页");
                
                NSString *mark_string = @"/trip/";
                NSRange range = [html rangeOfString:mark_string];
                NSInteger position = range.location + mark_string.length;
                NSString *str_id = [html substringFromIndex:position];
                
                WebViewViewController *webVC = [[WebViewViewController alloc] init];
                webVC.flag_natavie = YES;
                webVC.flag_remote = YES;
                webVC.plan_id = str_id;
                webVC.startURL = html;
                UINavigationController *rootVC = (UINavigationController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
                [rootVC pushViewController:webVC animated:YES];
                [webVC release];
                
            }
            else if([html rangeOfString:@"ask.qyer.com/question/"].location != NSNotFound ||
                    [html rangeOfString:@"/ask/question/"].location != NSNotFound) //问答详情页
            {
                NSLog(@"    推送  ---  问答详情页");
                
                NSString *mark_string = @"/question/";
                NSRange range = [html rangeOfString:mark_string];
                NSInteger position = range.location + mark_string.length;
                NSString *str_id = [html substringFromIndex:position];
                
                WebViewViewController *webVC = [[WebViewViewController alloc] init];
                webVC.flag_natavie = YES;
                webVC.flag_remote = YES;
                webVC.plan_id = str_id;
                webVC.startURL = html;
                UINavigationController *rootVC = (UINavigationController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
                [rootVC pushViewController:webVC animated:YES];
                [webVC release];
            }
            else if([html rangeOfString:@"/deal/"].location != NSNotFound) //折扣详情页
            {
                NSLog(@"    推送  ---  折扣详情页");
                
                NSString *mark_string = @"/deal/";
                NSRange range = [html rangeOfString:mark_string];
                NSInteger position = range.location + mark_string.length;
                NSString *str_id = [html substringFromIndex:position];
                
//                LastMinuteDetailViewController * lastDetailVC = [[LastMinuteDetailViewController alloc]init];
//                lastDetailVC.dealID = [str_id intValue];
//                UINavigationController *rootVC = (UINavigationController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
//                [rootVC pushViewController:lastDetailVC animated:YES];
//                [lastDetailVC release];
                
                //by jessica
                LastMinuteDetailViewControllerNew * lastDetailVC = [[LastMinuteDetailViewControllerNew alloc]init];
                lastDetailVC.lastMinuteId = [str_id intValue];
                lastDetailVC.source = NSStringFromClass([self class]);
                UINavigationController *rootVC = (UINavigationController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
                [rootVC pushViewController:lastDetailVC animated:YES];
                [lastDetailVC release];
            }
            
            else
            {
                NSLog(@"应用内打开");
                if(!_webVC)
                {
                    _webVC = [[WebViewViewController alloc] init];
                }
                _webVC.flag_plan = 0;
                _webVC.startURL = html;
                
                _webVC.fromPushFlag = 1;
                [_webVC getRemoteNotificationClass:self];
                
                [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:[QYToolObject getControllerWithBaseController:_webVC] animated:YES completion:nil];
                //[myRootVC presentModalViewController:_webVC animated:YES];
            }
        }
        else
        {
            NSLog(@"跳转到safari");
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:html]];
        }
    }
    else
    {
        
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:nil
                                  message:pushMesage
                                  delegate:self
                                  cancelButtonTitle:@"忽略"
                                  otherButtonTitles:@"查看",nil];
        alertView.delegate = [GetRemoteNotificationData sharedGetRemoteNotificationData];
        sharedGetRemoteNotificationData.openType = opentype;
        sharedGetRemoteNotificationData.htmlString = html;
        [alertView show];
        alertView.tag = 10002;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if(alertView.tag < 10000 && buttonIndex == [alertView cancelButtonIndex])
    {
        return;
    }
    else if(alertView.tag > 10000 && buttonIndex == [alertView cancelButtonIndex])
    {
        [MobClick event:@"pushClickCancel"];
        return;
    }
    else if(alertView.tag == 10001)
    {
        [MobClick event:@"pushClickRead"];
        [self pushGuideDetailViewWithFlag:1];
    }
    else if(alertView.tag == 10002)
    {
        [MobClick event:@"pushClickRead"];
        [self openHtmlOrSafariWithHtml:htmlString withOpentype:openType byFlag:1 andMsg:pushMsg];
    }
    else if(alertView.tag == 10003)
    {
        [MobClick event:@"pushClickRead"];
        [self pushSpecialViewWithFlag:1];
    }
}


-(void)pustNoteAndChatVC
{
//    NSUserDefaults *myUserDefault = [NSUserDefaults standardUserDefaults];
//    NSInteger notificationUnreadCount=[myUserDefault integerForKey:NotificationUnreadCount];
//    if (notificationUnreadCount!=0) {
//        [[NSUserDefaults standardUserDefaults] setInteger:0  forKey:NotificationUnreadCount];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
    
    NoteAndChatViewController *noteVc = [[NoteAndChatViewController alloc] init];
    noteVc.push_flag = YES;
    [self createPushNavigationVC];
    [self performSelector:@selector(pushVC:) withObject:noteVc afterDelay:0.1];
    [noteVc release];
}



#pragma mark -
#pragma mark --- getGuideByGuideId
-(NSMutableArray *)getGuideByGuideId:(NSArray *)array
{
    NSMutableArray *arr_ = [[NSMutableArray alloc] init];
    for(int i = 0; i < [array count]; i++)
    {
        NSString *idString = [NSString stringWithFormat:@"%@",[array objectAtIndex:i]];
        QYGuide *guide = [QYGuideData getGuideById:idString];
        if(guide)
        {
            [arr_ addObject:guide];
        }
    }
    
    return [arr_ autorelease];
}

@end

