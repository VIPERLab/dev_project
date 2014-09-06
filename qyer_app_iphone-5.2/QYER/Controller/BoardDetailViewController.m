//
//  BoardDetailViewController.m
//  QYER
//
//  Created by Leno on 14-5-5.
//  Copyright (c) 2014年 an qing. All rights reserved.
//

#import "BoardDetailViewController.h"

#import "MineViewController.h"

#import "QYAPIClient.h"
#import "Toast+UIView.h"

#import "BoadDetailTopCell.h"
#import "BoardDetailCommentCell.h"

#import "UIImageView+WebCache.h"

#define     height_headerview           (ios7 ? (44+20) : 44)

@interface BoardDetailViewController ()

@end

@implementation BoardDetailViewController

@synthesize wallID = _wallID;
@synthesize photoURL = _photoURL;
@synthesize boardPosterUserID = _boardPosterUserID;
@synthesize delegate = _delegate;

@synthesize enteredFromNotification = _enteredFromNotification;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        self.wallID = [NSString string];
        self.photoURL = [NSString string];
        
        self.enteredFromNotification = NO;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setMultipleTouchEnabled:NO];

    [self initRootView];
}

-(void)initRootView
{
    UIImageView *rootView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    rootView.backgroundColor = [UIColor clearColor];
    rootView.image = [UIImage imageNamed:@"qyer_background"];
    self.view = rootView;
    self.view.userInteractionEnabled = YES;
    [rootView release];
  
    float height_naviViewHeight = (ios7 ? 20+44 : 44);
    
    UIView * naviView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, height_naviViewHeight)];
    naviView.backgroundColor = RGB(43, 171, 121);
    [self.view addSubview:naviView];
    [naviView release];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 12, 240, 20)];
    if(ios7)
    {
        titleLabel.frame = CGRectMake(50, 12+20, 220, 20);
    }
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = @"详情";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:20];
    [naviView addSubview:titleLabel];
    [titleLabel release];
 
    UIButton * backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.backgroundColor = [UIColor clearColor];
    backButton.frame = CGRectMake(0, 2, 40, 40);
    if(ios7)
    {
        backButton.frame = CGRectMake(0, 2+20, 40, 40);
    }
    [backButton setBackgroundImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(clickBackButton) forControlEvents:UIControlEventTouchUpInside];
    [naviView addSubview:backButton];
    
    
    UIButton * deleteBoardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteBoardBtn.backgroundColor = [UIColor clearColor];
    deleteBoardBtn.frame = CGRectMake(276, 2, 40, 40);
    [deleteBoardBtn setTag:500001];
    if(ios7)
    {
        deleteBoardBtn.frame = CGRectMake(276, 2+20, 40, 40);
    }
    [deleteBoardBtn setBackgroundImage:[UIImage imageNamed:@"delete_self_Board@2x"] forState:UIControlStateNormal];
    [deleteBoardBtn setHidden:YES];
    [deleteBoardBtn addTarget:self action:@selector(deleteThisBoard) forControlEvents:UIControlEventTouchUpInside];
    [naviView addSubview:deleteBoardBtn];
    
    
    //初始化TableView
    _detailTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, height_headerview, 320, [[UIScreen mainScreen] bounds].size.height -height_headerview -44)];
    
    if (ios7) {
        [_detailTableView setFrame:CGRectMake(0, height_headerview, 320, [[UIScreen mainScreen] bounds].size.height -height_headerview -44)];
    }
    else{
        [_detailTableView setFrame:CGRectMake(0, height_headerview, 320, [[UIScreen mainScreen] bounds].size.height -height_headerview -64)];
    }
    [_detailTableView setDelegate:self];
    [_detailTableView setDataSource:self];
    [_detailTableView setBackgroundColor:[UIColor clearColor]];
    [_detailTableView setBackgroundView:nil];
    [_detailTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:_detailTableView];
    
    
    //Web底部的评论框背景
    _bottomImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0,self.view.frame.size.height -44, 320, 44)];
    if (ios7) {
        [_bottomImgView setFrame:CGRectMake(0,self.view.frame.size.height -44, 320, 44)];
    }
    else{
        [_bottomImgView setFrame:CGRectMake(0,self.view.frame.size.height -64, 320, 44)];
    }
    [_bottomImgView setBackgroundColor:RGB(69, 79, 97)];
    [_bottomImgView setUserInteractionEnabled:YES];
    [self.view addSubview:_bottomImgView];
    
    
    //评论TXV的背景
    _txvBackImgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 231, 34)];
    [_txvBackImgView setBackgroundColor:[UIColor clearColor]];
    _txvBackImgView.userInteractionEnabled = YES;
    [_txvBackImgView setImage:[UIImage imageNamed:@"bbs_comment_txv_Back"]];
    [_bottomImgView addSubview:_txvBackImgView];
    
    
    //评论的Txv
    _commentTextView = [[UIPlaceHolderTextView alloc]initWithFrame:CGRectMake(0, 2, 231, 30)];
    [_commentTextView setEditable:NO];
    [_commentTextView setReturnKeyType:UIReturnKeyDone];
    [_commentTextView setBackgroundColor:[UIColor clearColor]];
    [_commentTextView setPlaceholder:@"我要回复"];
    [_commentTextView setFont:[UIFont systemFontOfSize:13]];
    [_commentTextView setTextColor:[UIColor colorWithRed:(float)68/255 green:(float)68/255 blue:(float)68/255 alpha:1.0]];
    [_commentTextView setDelegate:self];
    [_commentTextView setReturnKeyType:UIReturnKeyDefault];
    _commentTextView.layer.cornerRadius = 1;
    _commentTextView.layer.masksToBounds = YES;
    [_txvBackImgView addSubview:_commentTextView];
    
    
    //发送按钮
    _sendButton = [[UIButton buttonWithType:UIButtonTypeCustom]retain];
    [_sendButton setFrame:CGRectMake(251, 5, 59, 34)];
    [_sendButton setBackgroundColor:[UIColor clearColor]];
    [_sendButton setTitle:@"回复" forState:UIControlStateNormal];
    [_sendButton setEnabled:NO];
    [_sendButton setTitleColor:[UIColor colorWithRed:(float)188/255 green:(float)188/255 blue:(float)188/255 alpha:1.0] forState:UIControlStateNormal];
    [_sendButton setTitleColor:[UIColor colorWithRed:(float)188/255 green:(float)188/255 blue:(float)188/255 alpha:1.0] forState:UIControlStateHighlighted];
    [_sendButton addTarget:self action:@selector(sendReplyMessage:) forControlEvents:UIControlEventTouchUpInside];
    _sendButton.enabled = NO;
    [_bottomImgView addSubview:_sendButton];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasChange:) name:UIKeyboardDidChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    _pageIndex = 1;
    _topInfoArray = [[NSMutableArray alloc]init];
    _commentsArray = [[NSMutableArray alloc]init];
    
    //默认直接显示
    _shouldShowNewComment = NO;
    
  
    [self  getDetailPhoto];
    
    _canLoadMoreComments = NO;
    _isLoadingMoreComments = NO;
  
    _refreshMoreView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    [_refreshMoreView setHidden:YES];
    _refreshMoreView.backgroundColor = [UIColor clearColor];
    [_detailTableView addSubview:_refreshMoreView];
    
    _refreshMoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, 2, 160, 20)];
    _refreshMoreLabel.backgroundColor = [UIColor clearColor];
    _refreshMoreLabel.textColor = [UIColor colorWithRed:100.0 / 255.0 green:100.0 / 255.0 blue:100.0 / 255.0 alpha:1.0];
    _refreshMoreLabel.font = [UIFont systemFontOfSize:17.0f];
    _refreshMoreLabel.text = @"加载列表中...";
    _refreshMoreLabel.textAlignment = NSTextAlignmentCenter;
    [_refreshMoreView addSubview:_refreshMoreLabel];
    
    _activityIndicatior = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityIndicatior.frame = CGRectMake(195, (24 - _activityIndicatior.frame.size.height) / 2, _activityIndicatior.frame.size.width, _activityIndicatior.frame.size.height);
    [_refreshMoreView addSubview:_activityIndicatior];
    
    _noCommentsVIew = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 35)];
    [_noCommentsVIew setBackgroundColor:[UIColor clearColor]];
    [_noCommentsVIew setHidden:YES];
    [_detailTableView addSubview:_noCommentsVIew];
    
    UIImage * imageee = [UIImage imageNamed:@"Board_Line"];
    imageee = [imageee stretchableImageWithLeftCapWidth:10 topCapHeight:0];
    
    UIImageView * noCommentGap = [[UIImageView alloc]initWithFrame:CGRectMake(10, 0, 310, 1)];
    [noCommentGap setImage:imageee];
    [_noCommentsVIew addSubview:noCommentGap];
    [noCommentGap release];
    
    
    UILabel * noCommentLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 7, 280, 20)];
    [noCommentLabel setBackgroundColor:[UIColor clearColor]];
    [noCommentLabel setText:@"还没有人评论"];
    [noCommentLabel setTextColor:RGB(158, 163, 171)];
    [noCommentLabel setFont:[UIFont systemFontOfSize:14]];
    [noCommentLabel setTextAlignment:NSTextAlignmentCenter];
    [_noCommentsVIew addSubview:noCommentLabel];
    [noCommentLabel release];
    
    
//    UIControl *control = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
//    [_detailTableView addSubview:control];
//    control.backgroundColor = [UIColor clearColor];
//    [control addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
//    [control release];
    
    UITapGestureRecognizer * tappp = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    [_detailTableView addGestureRecognizer:tappp];
    [tappp release];
}

-(void)tap:(id *)sender
{
    [_commentTextView resignFirstResponder];
}


//获取详情的图片
-(void)getDetailPhoto
{
    if (![self.photoURL isEqualToString:@""] && self.photoURL.length > 0) {
        
        [self.view makeToastActivity];
        
        UIImageView * imgView = [[[UIImageView alloc]initWithFrame:CGRectZero]autorelease];
        [imgView setImageWithURL:[NSURL URLWithString:self.photoURL] success:^(UIImage *image) {
            _photoImage = [image retain];
            
            [self getWallDetail];
            
        } failure:^(NSError *error) {
            [self.view hideToastActivity];
            [self.view makeToast:@"网络连接错误" duration:1.2f position:@"center" isShadow:NO];
        }];
    }
    
    else{
        [self getWallDetail];
    }
}


-(void)deleteThisBoard
{
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"" message:@"删除此条小黑板？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认删除", nil];
    [alert setTag:10001];
    [alert show];
    [alert release];
}

-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 10001 && buttonIndex == 1) {
        
        UIButton * deleteBtn = (UIButton *)[self.view viewWithTag:500001];

        [self.view makeToastActivity];
        [_commentTextView setEditable:NO];
        
        [deleteBtn setUserInteractionEnabled:NO];
        
        [[QYAPIClient sharedAPIClient]deleteBoardDetailByWallID:_wallID
                                                        success:^(NSDictionary *dic) {
            
                                                            [_commentTextView setEditable:YES];

                                                            [self.view hideToastActivity];
                                                            
                                                            if ([[dic objectForKey:@"status"] integerValue] == 1) {
                                                                
                                                                [self.view makeToast:@"删除成功" duration:1.2f position:@"center" isShadow:NO];
                                                                [self performSelector:@selector(deleteSuccess) withObject:nil afterDelay:1.2f];
                                                            }

        
                                                        } failed:^{
                                                            
                                                            [deleteBtn setUserInteractionEnabled:YES];

                                                            [_commentTextView setEditable:YES];
                                                            
                                                            [self.view hideToastActivity];
                                                            [self.view makeToast:@"网络错误" duration:1.2f position:@"center" isShadow:NO];
        
                                                        }];
    }
}

-(void)deleteSuccess
{
    [_commentTextView resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
    
    if ([_delegate respondsToSelector:@selector(didDeleteMessageSuccess)]) {
        [_delegate didDeleteMessageSuccess];
    }
}


-(void)getWallDetail
{
    [self.view hideToast];
    [self.view hideToastActivity];
    
    [self.view makeToastActivity];
    
    [_commentTextView setEditable:NO];
    
    [[QYAPIClient sharedAPIClient]getBoardDetailByWallID:self.wallID
                                                 success:^(NSDictionary *dic) {
                                                     
                                                     NSInteger statusType = [[dic objectForKey:@"status"]integerValue];

                                                     if (statusType == 1) {

                                                         if ([dic objectForKey:@"data"] && [[dic objectForKey:@"data"] isKindOfClass:[NSDictionary class]]) {
                                                             
                                                             NSDictionary * diccccc = [dic objectForKey:@"data"];
                                                             
                                                             if (self.enteredFromNotification == YES && [[diccccc objectForKey:@"photo"] isKindOfClass:[NSString class]] && ![[diccccc objectForKey:@"photo"] isEqualToString:@""]) {
                                                                 
                                                                 self.enteredFromNotification = NO;
                                                                 self.photoURL = [diccccc objectForKey:@"photo"];
                                                                 [self getDetailPhoto];
                                                             }
                                                             
                                                             else{
                                                                 
                                                                 [_commentTextView setEditable:YES];
                                                                 
                                                                 [_topInfoArray removeAllObjects];
                                                                 
                                                                 NSDictionary * dict = [dic objectForKey:@"data"];
                                                                 [_topInfoArray addObject:dict];
                                                                 
                                                                 NSInteger userID = [[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"]integerValue];
                                                                 NSInteger posterID = [[dict objectForKey:@"user_id"]integerValue];
                                                                 
                                                                 if (userID == posterID) {
                                                                     UIButton * deleteBtn = (UIButton *)[self.view viewWithTag:500001];
                                                                     [deleteBtn setHidden:NO];
                                                                 }
                                                                 
                                                                 if ([[[dic objectForKey:@"data"]objectForKey:@"comments"] isKindOfClass:[NSArray class]] && [[dic objectForKey:@"data"]objectForKey:@"comments"] != nil) {
                                                                     
                                                                     NSArray * commentsArray = [[dic objectForKey:@"data"]objectForKey:@"comments"];
                                                                     //超过10条可加载更多
                                                                     if (commentsArray.count >= 10) {
                                                                         _canLoadMoreComments = YES;
                                                                     }
                                                                     
                                                                     [_commentsArray removeAllObjects];
                                                                     [_commentsArray addObjectsFromArray:commentsArray];
                                                                 }
                                                                 
                                                                 [self.view hideToastActivity];
                                                                 
                                                                 [_detailTableView reloadData];
                                                                 
                                                                 if (_commentsArray.count > 0) {
                                                                     [_refreshMoreView setFrame:CGRectMake(0, _detailTableView.contentSize.height -30, 320, 30)];
                                                                     [_refreshMoreView setHidden:YES];
                                                                     [_activityIndicatior stopAnimating];
                                                                     
                                                                     [_noCommentsVIew setHidden:YES];
                                                                 }
                                                                 else{
                                                                     [_noCommentsVIew setFrame:CGRectMake(0, _detailTableView.contentSize.height -35, 320, 35)];
                                                                     [_noCommentsVIew setHidden:NO];
                                                                 }
                                                             }
                                                         }
                                                     }

                                                     else{
                                                         NSString * infooo = [dic objectForKey:@"info"];
                                                         
                                                         _shouldShowNewComment = NO;
                                                         [_commentTextView setEditable:YES];
                                                         
                                                         [self.view hideToastActivity];
                                                         [self.view makeToast:infooo duration:1.2f position:@"center" isShadow:NO];
                                                         [self performSelector:@selector(clickBackButton) withObject:nil afterDelay:1.0f];
                                                     }
                                                     
//                                                     [_commentTextView setEditable:YES];
//
//                                                     [_topInfoArray removeAllObjects];
//                                                     
//                                                     NSDictionary * dict = [dic objectForKey:@"data"];
//                                                     [_topInfoArray addObject:dict];
//                                                     
//                                                     NSInteger userID = [[[NSUserDefaults standardUserDefaults]valueForKey:@"userid"]integerValue];
//                                                     NSInteger posterID = [[dict objectForKey:@"user_id"]integerValue];
//                                                     
//                                                     if (userID == posterID) {
//                                                         UIButton * deleteBtn = (UIButton *)[self.view viewWithTag:500001];
//                                                         [deleteBtn setHidden:NO];
//                                                     }
//                                                     
//                                                     if ([[[dic objectForKey:@"data"]objectForKey:@"comments"] isKindOfClass:[NSArray class]] && [[dic objectForKey:@"data"]objectForKey:@"comments"] != nil) {
//                                                         
//                                                         NSArray * commentsArray = [[dic objectForKey:@"data"]objectForKey:@"comments"];
//                                                         //超过10条可加载更多
//                                                         if (commentsArray.count >= 10) {
//                                                             _canLoadMoreComments = YES;
//                                                         }
//                                                         
//                                                         [_commentsArray removeAllObjects];
//                                                         [_commentsArray addObjectsFromArray:commentsArray];
//                                                     }
//                                                     
//                                                     [self.view hideToastActivity];
//                     
//                                                     [_detailTableView reloadData];
//                                                     [_refreshMoreView setFrame:CGRectMake(0, _detailTableView.contentSize.height -30, 320, 30)];
//                                                     [_refreshMoreView setHidden:YES];
//                                                     [_activityIndicatior stopAnimating];

                                                     
                                                 } failed:^{
                                                     
                                                     _shouldShowNewComment = NO;

                                                     [_commentTextView setEditable:YES];

                                                     [self.view hideToastActivity];
                                                     [self.view makeToast:@"连接错误" duration:1.2f position:@"center" isShadow:NO];
                                                     [self performSelector:@selector(clickBackButton) withObject:nil afterDelay:1.0f];
                                                 }];
}

//-(void)showNewCommentScroll
//{
//    float   totalHeight = 0;
//    
//    NSDictionary * dict = [_topInfoArray objectAtIndex:0];
//    
//    NSString * content = [dict objectForKey:@"content"];
//    
//    NSString * photoLink = [dict objectForKey:@"photo"];
//    
//    if ([photoLink isKindOfClass:[NSString class]] && photoLink.length >0 && ![photoLink isEqualToString:@""])
//    {
//        float photoWidth = 0;
//        float photoHeight = 0;
//        
//        NSString * photoURL = [dict objectForKey:@"photo"];
//        
//        if (photoURL != nil && photoURL.length >0) {
//            
//            UIImage * imageee = _photoImage;
//            
//            if (imageee.size.width >0 && imageee.size.height >0) {
//                
//                photoWidth = imageee.size.width;
//                photoHeight = imageee.size.height;
//                
//                float _acturalHeight =  (float)(photoHeight/photoWidth) * 300;
//                
//                //计算内容的高度
//                
//                if ([content isKindOfClass:[NSString class]] && ![content isEqualToString:@""] && content.length >0) {
//                    CGSize  contentSize = [content sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(300, 1000) lineBreakMode:NSLineBreakByWordWrapping];
//                    float contentHeight = contentSize.height;
//                    
//                    totalHeight = 130 + _acturalHeight + contentHeight + 20;
//                }
//                else{
//                    totalHeight = 130 + _acturalHeight + 20;
//                }
//                
//            }
//        }
//    }
//    
//    else{
//        //计算内容的高度
//        CGSize  contentSize = [content sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(300, 1000) lineBreakMode:NSLineBreakByWordWrapping];
//        float contentHeight = contentSize.height;
//        totalHeight = 120 + contentHeight + 20;
//    }
//    
//    [_detailTableView setContentOffset:CGPointMake(0, totalHeight - 20) animated:YES];
//}


-(void)getwallComments
{
    _isLoadingMoreComments = YES;
    
    [self.view hideToast];
    [self.view makeToastActivity];
    
    [_commentTextView setEditable:NO];
    
    [[QYAPIClient sharedAPIClient]getBoardCommentsListByWallID:self.wallID
                                                         Count:@"10"
                                                          Page:[NSString stringWithFormat:@"%d",_pageIndex]
                                                       success:^(NSDictionary *dic) {
                                                           
                                                           [self.view hideToastActivity];
                                                           
                                                           [_commentTextView setEditable:YES];

                                                           _isLoadingMoreComments = NO;
                                                           
                                                           NSArray * commentsArray = [dic objectForKey:@"data"];
                                                         
                                                           if (commentsArray.count > 0) {
                                                               _canLoadMoreComments = YES;
                                                           }
                                                           else{
                                                               _canLoadMoreComments = NO;
                                                           }
                                                           
                                                           [_commentsArray addObjectsFromArray:commentsArray];
                                                           [_detailTableView reloadData];
                                                           
                                                           [_refreshMoreView setFrame:CGRectMake(0, _detailTableView.contentSize.height -30, 320, 30)];
                                                           [_refreshMoreView setHidden:YES];
                                                           [_activityIndicatior stopAnimating];
                                                           
                                                       } failed:^{
                                                           [_commentTextView setEditable:YES];

                                                           _isLoadingMoreComments = NO;

                                                           [_refreshMoreView setFrame:CGRectMake(0, _detailTableView.contentSize.height -30, 320, 30)];
                                                           [_refreshMoreView setHidden:YES];
                                                           [_activityIndicatior stopAnimating];
                                                           
                                                           [self.view hideToastActivity];
                                                           [self.view makeToast:@"网络连接错误" duration:1.2f position:@"center" isShadow:NO];
                                                           
                                                           [self performSelector:@selector(setOption) withObject:nil afterDelay:2.0];
                                                       }];
}


-(void)setOption
{
    _canLoadMoreComments = YES;
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:_detailTableView] && _keyBoradOrigin < self.view.frame.size.height) {
        [_commentTextView resignFirstResponder];
    }
    
    if (_canLoadMoreComments == YES && _isLoadingMoreComments == NO && _topInfoArray.count + _commentsArray.count >=11) {
        
        if(_detailTableView.contentOffset.y + _detailTableView.frame.size.height > _detailTableView.contentSize.height - 60)
        {
            _canLoadMoreComments = NO;
            
            [_refreshMoreView setHidden:NO];
            [_activityIndicatior startAnimating];

            _pageIndex = _pageIndex + 1;

            [self getwallComments];
        }
    }
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        
        if ( _topInfoArray.count >0) {
            
            BoadDetailTopCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detail_top_cell"];
            
            if(cell == nil)
            {
                cell = [[[BoadDetailTopCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"detail_top_cell"] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            [cell setDelegate:self];
            [cell setBackgroundColor:[UIColor clearColor]];
            [cell setBackgroundView:nil];
            
            NSDictionary * dict = [_topInfoArray objectAtIndex:0];
            [cell setContentInfo:dict];
            
            return cell;
        }
    }
    
    
    if (indexPath.row > 0 && _commentsArray.count > 0) {
        
            BoardDetailCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detail_comment_cell"];
            if(cell == nil)
            {
                cell = [[[BoardDetailCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"detail_comment_cell"] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        
            NSDictionary * dict = [_commentsArray objectAtIndex:indexPath.row -1];
            [cell setBackgroundColor:[UIColor clearColor]];
            [cell setBackgroundView:nil];
            [cell setDelegate:self];
            [cell setTag:5000 + indexPath.row];
        
//        if (indexPath.row == 1 && _shouldShowNewComment == YES) {
//            [cell insertNewComment:dict];
//            _shouldShowNewComment = NO;
//        }
//        else{
            [cell setContenInfo:dict];
//        }
        
            return cell;
        }

   return nil;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        
        float   totalHeight = 0;

        if (_topInfoArray.count >0) {
            
            NSDictionary * dict = [_topInfoArray objectAtIndex:0];
            
            NSString * title = [dict objectForKey:@"title"];
            NSString * content = [dict objectForKey:@"content"];
            
            CGSize  titleSize = [title sizeWithFont:[UIFont boldSystemFontOfSize:17] constrainedToSize:CGSizeMake(300, 40) lineBreakMode:NSLineBreakByWordWrapping];
            float titleHeight = titleSize.height;
            //计算内容的高度
            CGSize  contentSize = [content sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(300, 1000) lineBreakMode:NSLineBreakByWordWrapping];
            float contentHeight = contentSize.height;
            
            
            float photoOriginY = 85 + titleHeight + 10 + contentHeight +10;
            
            NSString * photoLink = [dict objectForKey:@"photo"];
            
            if ([photoLink isKindOfClass:[NSString class]] && ![photoLink isEqualToString:@""])
            {
                float photoWidth = 0;
                float photoHeight = 0;
                
                UIImage * imageee = _photoImage;
                photoWidth = imageee.size.width;
                photoHeight = imageee.size.height;
                
                float _acturalHeight =  (float)(photoHeight/photoWidth) * 300;
                
                totalHeight = photoOriginY + _acturalHeight + 20;
            }
            
            else{
                totalHeight = photoOriginY + 20;
            }
            
//                if (imageee.size.width >0 && imageee.size.height >0) {
//                        
//
//                    //计算内容的高度
//                    if ([content isKindOfClass:[NSString class]] && ![content isEqualToString:@""] && content.length >0) {
//                        CGSize  contentSize = [content sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(300, 1000) lineBreakMode:NSLineBreakByWordWrapping];
//                        float contentHeight = contentSize.height;
//                            
//                        totalHeight = 130 + _acturalHeight + contentHeight + 20;
//                    }
//                    else{
//                        totalHeight = 130 + _acturalHeight + 20;
//                    }
//                }
//            }
//            
//            else{
//                //计算内容的高度
//                CGSize  contentSize = [content sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(300, 1000) lineBreakMode:NSLineBreakByWordWrapping];
//                float contentHeight = contentSize.height;
//                totalHeight = 120 + contentHeight + 20;
//            }
            
        }
        
        if (_commentsArray.count == 0) {
            return totalHeight + 35;
        }
        else{
            return totalHeight;
        }
        
    }
    
    
    if (indexPath.row > 0) {
        
        float height = 0;
        
            NSDictionary * dict = [_commentsArray objectAtIndex:indexPath.row -1];
        
            NSString * content = [dict objectForKey:@"content"];
            CGSize  contentSize = [content sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(252, 1000) lineBreakMode:NSLineBreakByWordWrapping];
            float contentHeight = contentSize.height;
            height = 32 + contentHeight + 10;
                
            if (_canLoadMoreComments == YES && indexPath.row == _commentsArray.count) {
                return height +30;
            }
            else{
                return height;
            }
    }
    
    return 0;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _topInfoArray.count + _commentsArray.count;
}

//点击顶部头像的事件
-(void)didClickTopUserAvatar
{
    NSDictionary * dict = [_topInfoArray objectAtIndex:0];
    int userID = [[dict objectForKey:@"user_id"]intValue];
    
    MineViewController *mineVC = [[MineViewController alloc] init];
    mineVC.user_id = userID;
    [self.navigationController pushViewController:mineVC animated:YES];
    [mineVC release];
}

//点击评论列表的事件
-(void)didClickCommentsUserAvatarByTag:(NSInteger)tag
{
    NSInteger xxx = tag - 5000;
    NSDictionary * dict = [_commentsArray objectAtIndex:xxx -1];
    int userID = [[dict objectForKey:@"user_id"]intValue];
    
    MineViewController *mineVC = [[MineViewController alloc] init];
    mineVC.user_id = userID;
    [self.navigationController pushViewController:mineVC animated:YES];
    [mineVC release];
}



-(void)keyboardWillShow:(NSNotification*)aNotification
{
    //计算内容的高度
    CGSize  contentSize = [_commentTextView.text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(231, 300) lineBreakMode:NSLineBreakByWordWrapping];
    float contentHeight = contentSize.height;
    
    NSDictionary *info = [aNotification userInfo];
    
    //高度
    _keyBoardHeight = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    float keyBoardHeight = kbSize.height;



    if (contentHeight >= 34 && contentHeight <= 70) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.35f];
        [_bottomImgView setFrame:CGRectMake(0,self.view.frame.size.height - keyBoardHeight -contentHeight -10, 320, contentHeight +10)];
        [_txvBackImgView setFrame:CGRectMake(10, 5, 231, contentHeight)];
        [_commentTextView setFrame:CGRectMake(0, 2, 231, contentHeight -4)];
        [UIView commitAnimations];
    }
    
    if (contentHeight < 34) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.35f];
        [_bottomImgView setFrame:CGRectMake(0,self.view.frame.size.height - keyBoardHeight -44, 320, 44)];
        [_txvBackImgView setFrame:CGRectMake(10, 5, 231, 34)];
        [_commentTextView setFrame:CGRectMake(0, 2, 231, 30)];
        [UIView commitAnimations];
    }
    
    if (contentHeight > 70) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.35f];
        [_bottomImgView setFrame:CGRectMake(0,self.view.frame.size.height - keyBoardHeight -70, 320, 70)];
        [_txvBackImgView setFrame:CGRectMake(10, 5, 231, 60)];
        [_commentTextView setFrame:CGRectMake(0, 2, 231, 56)];
        [UIView commitAnimations];
    }
    
}


- (void)keyboardWillHide:(NSNotification*)aNotification
{
    NSDictionary *info = [aNotification userInfo];
   
    //高度
    _keyBoardHeight = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    
    //计算内容的高度
    CGSize  contentSize = [_commentTextView.text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(231, 300) lineBreakMode:NSLineBreakByWordWrapping];
    float contentHeight = contentSize.height;

    
    if (contentHeight >= 34 && contentHeight <= 70) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.35f];
        [_bottomImgView setFrame:CGRectMake(0,self.view.frame.size.height -contentHeight -10, 320, contentHeight +10)];
        [_txvBackImgView setFrame:CGRectMake(10, 5, 231, contentHeight)];
        [_commentTextView setFrame:CGRectMake(0, 2, 231, contentHeight -4)];
        [UIView commitAnimations];
    }
    
    if (contentHeight < 34) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.35f];
        [_bottomImgView setFrame:CGRectMake(0,self.view.frame.size.height -44, 320, 44)];
        [_txvBackImgView setFrame:CGRectMake(10, 5, 231, 34)];
        [_commentTextView setFrame:CGRectMake(0, 2, 231, 30)];
        [UIView commitAnimations];
    }
    
    if (contentHeight > 70) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.35f];
        [_bottomImgView setFrame:CGRectMake(0,self.view.frame.size.height -70, 320, 70)];
        [_txvBackImgView setFrame:CGRectMake(10, 5, 231, 60)];
        [_commentTextView setFrame:CGRectMake(0, 2, 231, 56)];
        [UIView commitAnimations];
    }
}


-(void)keyboardWasChange:(NSNotification *)aNotification
{
    NSDictionary *info = [aNotification userInfo];
    //起点
    _keyBoradOrigin = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    //高度
    _keyBoardHeight = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
}


-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length == 0) {
        [_sendButton setTitleColor:[UIColor colorWithRed:(float)188/255 green:(float)188/255 blue:(float)188/255 alpha:1.0] forState:UIControlStateNormal];
        [_sendButton setEnabled:NO];
    }
    
    if ([self isEmpty:textView.text] == YES) {
        [_sendButton setTitleColor:[UIColor colorWithRed:(float)188/255 green:(float)188/255 blue:(float)188/255 alpha:1.0] forState:UIControlStateNormal];
        [_sendButton setEnabled:NO];
    }
    else{
        [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sendButton setEnabled:YES];
    }
    
    [self countTextLength];
}

-(BOOL) isEmpty:(NSString *) str {
    
    if (!str) {
        return true;
    } else {
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        
        NSString *trimedString = [str stringByTrimmingCharactersInSet:set];
        
        if ([trimedString length] == 0) {
            return true;
        } else {
            return false;
        }
    }
}

-(void)countTextLength
{
    //计算内容的高度
    CGSize  contentSize = [_commentTextView.text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(231, 300) lineBreakMode:NSLineBreakByWordWrapping];
    float contentHeight = contentSize.height;
 
    if (contentHeight >= 34 && contentHeight <= 70) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.35f];
        [_bottomImgView setFrame:CGRectMake(0,self.view.frame.size.height - _keyBoardHeight -contentHeight -10, 320, contentHeight +10)];
        [_txvBackImgView setFrame:CGRectMake(10, 5, 231, contentHeight)];
        [_commentTextView setFrame:CGRectMake(0, 2, 231, contentHeight -4)];
        [UIView commitAnimations];
    }
    
    if (contentHeight < 34) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.35f];
        [_bottomImgView setFrame:CGRectMake(0,self.view.frame.size.height - _keyBoardHeight -44, 320, 44)];
        [_txvBackImgView setFrame:CGRectMake(10, 5, 231, 34)];
        [_commentTextView setFrame:CGRectMake(0, 2, 231, 30)];
        [UIView commitAnimations];
    }
    
    if (contentHeight > 70) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.35f];
        [_bottomImgView setFrame:CGRectMake(0,self.view.frame.size.height - _keyBoardHeight -70, 320, 70)];
        [_txvBackImgView setFrame:CGRectMake(10, 5, 231, 60)];
        [_commentTextView setFrame:CGRectMake(0, 2, 231, 56)];
        [UIView commitAnimations];
    }
}



-(void)sendReplyMessage:(id)sender
{
    [_commentTextView resignFirstResponder];
    
    [self.view makeToastActivity];
    
    [self performSelector:@selector(sendddd) withObject:nil afterDelay:2.0f];
}

-(void)sendddd
{
    //输入框内容
    NSString * commentText = _commentTextView.text;
    
    if (commentText.length > 200) {
        
       UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"内容不可超过200字，已输入%d字",commentText.length] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    if (commentText.length == 0 || [self isEmpty:commentText]) {
        
    }
    
    else{
        [_commentTextView setEditable:NO];
        [_sendButton setEnabled:NO];
        
        [[QYAPIClient sharedAPIClient]replyToBoardByWallID:self.wallID
                                                   Message:commentText
                                                   success:^(NSDictionary *dic) {
                                                       
                                                       if ([[dic objectForKey:@"status"]integerValue] == 1) {
                                                           //添加评论成功的代理
                                                           if ([_delegate respondsToSelector:@selector(didAddCommentSuccess)]) {
                                                               [_delegate didAddCommentSuccess];
                                                           }
                                                           
                                                           [self.view hideToastActivity];
                                                           [self.view makeToast:@"发表成功" duration:1.2f position:@"center" isShadow:NO];
//                                                           [MobClick ];
                                                           [_commentTextView setText:@""];
                                                           [_commentTextView setEditable:YES];
                                                           [_sendButton setEnabled:NO];
                                                           
                                                           [_bottomImgView setFrame:CGRectMake(0,self.view.frame.size.height -44, 320, 44)];
                                                           [_txvBackImgView setFrame:CGRectMake(10, 5, 231, 34)];
                                                           [_commentTextView setFrame:CGRectMake(0, 2, 231, 30)];
                                                           
                                                           //                                                       [_detailTableView setContentOffset:CGPointMake(0, _topPhotoHeight) animated:YES];
                                                           _shouldShowNewComment = YES;
                                                           
                                                           [self performSelector:@selector(getWallDetail) withObject:nil afterDelay:1.5f];
                                                       }
                                                       
                                                       else{
                                                           NSString * str = [dic objectForKey:@"info"];
                                                           [self.view makeToast:str duration:1.2f position:@"center" isShadow:NO];
                                                       }
                                                       
                                                    
                                                       
                                                   } failed:^{
                                                       [_commentTextView setEditable:YES];
                                                       [_sendButton setEnabled:YES];
                                                       
                                                       [self.view hideToastActivity];
                                                       [self.view makeToast:@"网络错误,请检查网络后重试" duration:1.2f position:@"center" isShadow:NO];
                                                       
                                                   }];
    }
    
}


//-(void)insertUserCommentWithDictionary:(NSDictionary *)dic
//{
//    NSDictionary * infoDic = [dic objectForKey:@"data"];
//    
//    NSString * commentID = [infoDic objectForKey:@"comment_id"];
//    NSString * content   = _commentTextView.text;
//    
//    
//    NSTimeInterval time=[[NSDate date] timeIntervalSince1970]*1000;
//    
//    NSLog(@"---%f---",time);
//
//
//    NSString * avatar = [[NSUserDefaults standardUserDefaults]valueForKey:@"usericon"];
//    NSString * namee  = [[NSUserDefaults standardUserDefaults]valueForKey:@"username"];
//    NSString * userID = [[NSUserDefaults standardUserDefaults]valueForKey:@"userid"];
//    
//    NSDictionary * dict = [NSDictionary dictionary];
//    [dict setValue:commentID forKey:@"comment_id"];
//    [dict setValue:userID forKey:@"user_id"];
//    [dict setValue:namee forKey:@"username"];
//    [dict setValue:avatar forKey:@"avatar"];
//    [dict setValue:content forKey:@"content"];
//    [dict setValue:[NSString stringWithFormat:@"%f",time] forKey:@"publish_time"];
//    
//    
//    [_topInfoArray addObject:dict];
////    [_detailTableView reloadData];
////    [_detailTableView setContentOffset:CGPointMake(0, _detailTableView.contentSize.height) animated:YES];
//    
////    "comment_id": "36",
////    "user_id": "275710",
////    "username": "julyutopia",
////    "avatar": "http://static.qyer.com/images/user2/avatar/middle5.png",
////    "content": "哈哈哈哈哈哈哈",
////    "publish_time": "1400583932"
//
//}







-(void)clickBackButton
{
    [_commentTextView resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)dealloc
{
    QY_VIEW_RELEASE(_refreshMoreView);
    QY_VIEW_RELEASE(_refreshMoreLabel);
    QY_VIEW_RELEASE(_activityIndicatior);
    QY_VIEW_RELEASE(_detailTableView);
    QY_VIEW_RELEASE(_bottomImgView);
    QY_VIEW_RELEASE(_txvBackImgView);
    QY_VIEW_RELEASE(_commentTextView);
    QY_VIEW_RELEASE(_sendButton);

    QY_SAFE_RELEASE(_photoImage);
    QY_SAFE_RELEASE(_topInfoArray);
    QY_SAFE_RELEASE(_commentsArray);
    QY_SAFE_RELEASE(_wallID);
    QY_SAFE_RELEASE(_photoURL);
    
    [super dealloc];
}

@end
