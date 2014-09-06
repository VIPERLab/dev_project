//
//  DownloadViewController.m
//  kwbook
//
//  Created by 熊 改 on 13-11-28.
//  Copyright (c) 2013年 单 永杰. All rights reserved.
//

#import "DownloadViewController.h"
#import "globalm.h"
#import "ImageMgr.h"
#import "KBDownLoadDetailViewController.h"
#import "LocalBookRequest.h"
#import "KBAppDelegate.h"
#include "IObserverDownTaskStatus.h"
#include "MessageManager.h"
#include "CacheMgr.h"
#include "BookInfoList.h"
#include "BookManagement.h"
#import "LDProgressView.h"
#include "UIDevice+Hardware.h"

#define TAG_IMAGE           41
#define TAG_BOOK_NAME       42
#define TAG_DETAIL          43

@interface DownloadViewController ()<UITableViewDataSource,UITableViewDelegate, IObserverDownTaskStatus>{
    std::vector<CBookInfo*> m_mapDistinctBooks;
}
@property (nonatomic , strong) UIView                   *topBar;
@property (nonatomic , strong) UITableView              *tableView;
@property (nonatomic , strong) NSMutableArray *                data;
@property (nonatomic , strong) UIView                   *prompt_view;
@property (nonatomic , strong) LDProgressView*   progress_view;
@property (nonatomic , strong) UILabel*                 progress_label;
@end

@implementation DownloadViewController

- (NSNumber*) totalDiskSpace {
#if __IPHONE_4_0
    NSError* error = nil;
    NSDictionary* fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath: NSHomeDirectory() error: &error];
    if (error)
        return nil;
#else
    NSDictionary* fattributes = [[NSFileManager defaultManager] fileSystemAttributesAtPath: NSHomeDirectory()];
#endif
    
//    NSLog(@"%d", [[fattributes objectForKey: NSFileSystemSize] intValue]);
    return [fattributes objectForKey: NSFileSystemSize];
}

- (NSNumber*) freeDiskSpace {
#if __IPHONE_4_0
    NSError* error = nil;
    NSDictionary* fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath: NSHomeDirectory() error: &error];
    if (error)
        return nil;
#else
    NSDictionary* fattributes = [[NSFileManager defaultManager] fileSystemAttributesAtPath: NSHomeDirectory()];
#endif
    
    return [fattributes objectForKey: NSFileSystemFreeSize];
}

- (void) refreshDiskInfo{
    _progress_view.progress = ([[self freeDiskSpace] unsignedLongLongValue] * 1.0) / [[self totalDiskSpace] unsignedLongLongValue];
    [_progress_label setText:[NSString stringWithFormat:@"可用空间%.2fG, 总空间%.2fG", [[self freeDiskSpace] unsignedLongLongValue] / (1024.0 * 1024 * 1024), [[self totalDiskSpace] unsignedLongLongValue] / (1024.0 * 1024 * 1024)]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        m_mapDistinctBooks = CBookManagement::GetInstance()->GetBookList();
        for (std::vector<CBookInfo*>::iterator iter_book = m_mapDistinctBooks.begin(); iter_book != m_mapDistinctBooks.end(); ++iter_book) {
            NSLog(@"%@", [NSString stringWithUTF8String:(*iter_book)->m_strBookTitle.c_str()]);
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    float gap = 0.0;
    if (isIOS7()) {
        gap = 20;
    }
    float width  = self.view.bounds.size.width;
    float height = self.view.bounds.size.height;
    self.topBar = ({
        UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 44+gap)];
        UIImageView *backView = [[UIImageView alloc] initWithFrame:topBar.bounds];
        if (isIOS7()) {
            [backView setImage:CImageMgr::GetImageEx("RecoTopBackFor7.png")];
        }
        else{
            [backView setImage:CImageMgr::GetImageEx("RecoTopBackFor6.png")];
        }
        [topBar addSubview:backView];
        
        UIButton *editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [editBtn setFrame:CGRectMake(270, gap, 44, 44)];
        [editBtn setBackgroundColor:[UIColor clearColor]];
        [editBtn setTitle:@"编辑" forState:(UIControlStateNormal)];
        [editBtn addTarget:self action:@selector(onEditBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [topBar addSubview:editBtn];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, gap, 180, 44)];
        [titleLabel setText:@"下载管理"];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setFont:[UIFont systemFontOfSize:20.0]];
        [topBar addSubview:titleLabel];
        topBar;
    });
    [[self view] addSubview:self.topBar];
    
    _progress_view = [[LDProgressView alloc] initWithFrame:CGRectMake(0, _topBar.bounds.size.height, width, 19)];
    _progress_label = [[UILabel alloc] initWithFrame:CGRectMake(0, _topBar.bounds.size.height, width, 19)];
    [_progress_label setBackgroundColor:[UIColor clearColor]];
    
    _progress_view.progress = ([[self freeDiskSpace] unsignedLongLongValue] * 1.0) / [[self totalDiskSpace] unsignedLongLongValue];
    _progress_view.borderRadius = @0;
    _progress_view.flat = [NSNumber numberWithBool:NO];
    _progress_view.type = LDProgressSolid;
    _progress_view.color = UIColorFromRGBValue(0x0690D3);
    _progress_view.showText = [NSNumber numberWithBool:NO];
    
    [_progress_label setText:[NSString stringWithFormat:@"可用空间%.2fG, 总空间%.2fG", [[self freeDiskSpace] unsignedLongLongValue] / (1024.0 * 1024 * 1024), [[self totalDiskSpace] unsignedLongLongValue] / (1024.0 * 1024 * 1024)]];
    [_progress_label setFont:[UIFont systemFontOfSize:12]];
    [_progress_label setTextAlignment:NSTextAlignmentCenter];
    [_progress_label setTextColor:[UIColor whiteColor]];
    
    [self.view addSubview:_progress_view];
    [self.view addSubview:_progress_label];
    
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.topBar.bounds.size.height + 19, width, height-self.topBar.bounds.size.height - 19)];
        //tableView.allowsMultipleSelectionDuringEditing = YES;
        [tableView setBackgroundColor:CImageMgr::GetBackGroundColor()];
        [tableView setDelegate:self];
        [tableView setDataSource:self];
        tableView;
    });
    [[self view] addSubview:self.tableView];
    
    _prompt_view = [[UIView alloc] initWithFrame:CGRectMake(0, 44 + gap, 320, self.view.frame.size.height - 44 - gap)];
    UILabel* label_prompt = [[UILabel alloc] initWithFrame:CGRectMake(0, self.tableView.frame.size.height/2-10, 320, 20)];
    [_prompt_view setBackgroundColor:[UIColor clearColor]];
    [label_prompt setTextAlignment:NSTextAlignmentCenter];
    [label_prompt setTextColor:defaultGrayColor()];
    [label_prompt setBackgroundColor:[UIColor clearColor]];
    [label_prompt setText:@"还没有下载的作品喔"];
    [_prompt_view addSubview:label_prompt];
    
    [self.view addSubview:_prompt_view];
    
    if (0 == m_mapDistinctBooks.size()) {
        [_prompt_view setHidden:NO];
    }else {
        [_prompt_view setHidden:YES];
    }
    
    GLOBAL_ATTACH_MESSAGE_OC(OBSERVER_ID_DOWN_STATE, IObserverDownTaskStatus);
}
-(void)onEditBtnClick:(id)sender
{
    if (0 == [_tableView numberOfRowsInSection:0]) {
        return;
    }
    [self.tableView setEditing:!self.tableView.isEditing animated:YES];
    UIButton* button = (UIButton*)sender;
    if (_tableView.isEditing) {
        [button setTitle:@"完成" forState:(UIControlStateNormal)];
    }else {
        [button setTitle:@"编辑" forState:(UIControlStateNormal)];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numOfRows =m_mapDistinctBooks.size();
    if (numOfRows > 0) {
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    }
    else{
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
    return m_mapDistinctBooks.size();
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *categoryCellIdentifier = @"categoryBookListIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:categoryCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:categoryCellIdentifier];
        [cell.contentView setBackgroundColor:CImageMgr::GetBackGroundColor()];
        cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        cell.backgroundView.backgroundColor = CImageMgr::GetBackGroundColor();
        if (isIOS7()) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        
        UIImageView *bookBack = [[UIImageView alloc] initWithFrame:CGRectMake(2.5, 2.5, 69, 69)];
        [bookBack setImage:CImageMgr::GetImageEx("BookPicBack.png")];
        [cell.contentView addSubview:bookBack];
        
        UIImageView *headPic = [[UIImageView alloc] initWithFrame:CGRectMake(7, 7, 60, 60)];
        [headPic setImage:CImageMgr::GetImageEx("DefaultBookImageSmall.png")];
        [headPic setTag:TAG_IMAGE];
        [cell.contentView addSubview:headPic];
        
        UILabel *bookNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(77, 18, 200, 17)];
        [bookNameLabel setTag:TAG_BOOK_NAME];
        [bookNameLabel setTextColor:defaultBlackColor()];
        [bookNameLabel setBackgroundColor:[UIColor clearColor]];
        [bookNameLabel setFont:[UIFont systemFontOfSize:16.0]];
        [cell.contentView addSubview:bookNameLabel];
        
        UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(77, 51, 80, 11)];
        [detailLabel setTag:TAG_DETAIL];
        [detailLabel setTextColor:defaultGrayColor()];
        [detailLabel setBackgroundColor:[UIColor clearColor]];
        [detailLabel setFont:[UIFont systemFontOfSize:10.0]];
        [cell.contentView addSubview:detailLabel];
        
        UIImageView *accessaryView = [[UIImageView alloc] initWithImage:CImageMgr::GetImageEx("cellIndicator.png")];
        [accessaryView setCenter:CGPointMake(300, 37.0)];
        [cell.contentView addSubview:accessaryView];
    }
    CBookInfo* cur_book = m_mapDistinctBooks[indexPath.row];
    UILabel *bookNameLabel = (UILabel *)[cell.contentView viewWithTag:TAG_BOOK_NAME];
    
    [bookNameLabel setText:[NSString stringWithUTF8String:cur_book->m_strBookTitle.c_str()]];
    
    UILabel *artistLabel = (UILabel *)[cell.contentView viewWithTag:TAG_DETAIL];
    
    [artistLabel setText:[NSString stringWithFormat:@"共%lu个下载", CBookManagement::GetInstance()->GetChapterList(cur_book->m_strBookId)->size()]];
    
    if (cur_book && cur_book->m_strImgUrl.size()) {
        [self startLoadImage:cell imageUrl:[NSString stringWithUTF8String:cur_book->m_strImgUrl.c_str()]];
    }
    else{
        UIImageView* image_view = (UIImageView*)[cell.contentView viewWithTag:TAG_IMAGE];
        [image_view setImage:CImageMgr::GetImageEx("DefaultBookImageSmall.png")];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    return cell;
}
#pragma mark
#pragma mark table view delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 74.0f;
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        CLocalBookRequest::GetInstance()->DeleteTasks(m_mapDistinctBooks[indexPath.row]->m_strBookId);
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    KBDownLoadDetailViewController* sub_view_controller = [[KBDownLoadDetailViewController alloc] initWithBookid:[NSString stringWithUTF8String:m_mapDistinctBooks[indexPath.row]->m_strBookId.c_str()]];
    [ROOT_NAVI_CONTROLLER pushAddButtonViewController:sub_view_controller animated:YES];
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}
-(void)IObDownStatus_AddTask:(unsigned)un_rid{
    m_mapDistinctBooks = CBookManagement::GetInstance()->GetBookList();
    [_tableView reloadData];
    
    if (0 == m_mapDistinctBooks.size()) {
        [_prompt_view setHidden:NO];
    }else {
        [_prompt_view setHidden:YES];
    }
}

-(void)IObDownStatus_AddTasksFinish{
    m_mapDistinctBooks = CBookManagement::GetInstance()->GetBookList();
    [_tableView reloadData];
    
    if (0 == m_mapDistinctBooks.size()) {
        [_prompt_view setHidden:NO];
    }else {
        [_prompt_view setHidden:YES];
    }
}

-(void)IObDownStatus_DownTaskFinish:(unsigned)un_rid{
    m_mapDistinctBooks = CBookManagement::GetInstance()->GetBookList();
    [_tableView reloadData];
    
    if (0 == m_mapDistinctBooks.size()) {
        [_prompt_view setHidden:NO];
    }else {
        [_prompt_view setHidden:YES];
    }
    
    [self refreshDiskInfo];
}

-(void)IObDownStatus_DeleteTask{
    m_mapDistinctBooks = CBookManagement::GetInstance()->GetBookList();
    [_tableView reloadData];
    
    if (0 == m_mapDistinctBooks.size()) {
        [_prompt_view setHidden:NO];
    }else {
        [_prompt_view setHidden:YES];
    }
    
    [self refreshDiskInfo];
}

-(void)IObDownStatus_DeleteTasks{
    m_mapDistinctBooks = CBookManagement::GetInstance()->GetBookList();
    
    [_tableView reloadData];
    
    if (0 == m_mapDistinctBooks.size()) {
        [_prompt_view setHidden:NO];
    }else {
        [_prompt_view setHidden:YES];
    }
    
    [self refreshDiskInfo];
}

-(void)detachObservers{
    GLOBAL_DETACH_MESSAGE_OC(OBSERVER_ID_DOWN_STATE, IObserverDownTaskStatus);
}

-(void)startLoadImage : (UITableViewCell*)cell imageUrl : (NSString*)str_image_url
{
    __block void* imageData = NULL;
    __block unsigned length = 0;;
    __block BOOL outOfDate;
    if (CCacheMgr::GetInstance()->Read([str_image_url UTF8String], imageData, length, outOfDate)) {
        NSData *cacheImageData=[[NSData alloc] initWithBytesNoCopy:imageData length:length freeWhenDone:YES];
        UIImage *image = [[UIImage alloc] initWithData:cacheImageData];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImageView* image_view = (UIImageView*)[cell.contentView viewWithTag:TAG_IMAGE];
            [image_view setImage:image];
        });
    }
    else{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:str_image_url]];
            if (imageData) {
                UIImage *image = [[UIImage alloc] initWithData:imageData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    UIImageView* image_view = (UIImageView*)[cell.contentView viewWithTag:TAG_IMAGE];
                    [image_view setImage:image];
                    
                    CCacheMgr::GetInstance()->Cache(T_DAY, 3, [str_image_url UTF8String], [imageData bytes], [imageData length]);
                });
            }
            else{
                UIImageView* image_view = (UIImageView*)[cell.contentView viewWithTag:TAG_IMAGE];
                [image_view setImage:CImageMgr::GetImageEx("DefaultBookImageSmall.png")];
                NSLog(@"load image fail");
            }
        });
    }
}

-(void)IObDownStatus_LoadDBFinish{
    m_mapDistinctBooks = CBookManagement::GetInstance()->GetBookList();
    if (0 != m_mapDistinctBooks.size()) {
        [_prompt_view setHidden:YES];
    }
    [_tableView reloadData];
}

@end