//
//  SearchTipView.m
//  KwSing
//
//  Created by Hu Qian on 12-11-26.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#import "SearchTipView.h"
#include "MessageManager.h"
#include "SearchRequest.h"
#include "globalm.h"
#include "ImageMgr.h"

const int TagTableView = 100;
const int Tag_ClearHistory = 101;
const int Tag_DeleteHisory = 102;
const int Tag_ListText = 103;
const int Tag_ListDownBk = 104;

enum ShowType
{
    eShowNone,
    eShowTip,
    eShowHistory
};
@interface SearchTipView() <UITableViewDataSource,UITableViewDelegate>
{
    ShowType showType;
    NSMutableArray *arrHistory;
    std::vector<std::string> m_vecTip;
}
@end


@implementation SearchTipView
@synthesize searchdelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        UITableView * resultView = [[[UITableView alloc]init]autorelease];
        resultView.tag = TagTableView;
        resultView.frame = self.bounds;
        resultView.delegate = self;
        resultView.dataSource = self;
        resultView.backgroundColor = UIColorFromRGBValue(0xededed);
        resultView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:resultView];
    }
    return self;
}

-(void)setInputWord:(NSString *)Word
{
    if(inputWord)
       [inputWord release];
    inputWord = [Word retain];
    if([inputWord isEqualToString:@""])
    {
        showType = eShowHistory;
        arrHistory = [searchdelegate GetSearchHistory];
        UITableView * tableview = (UITableView*)[self viewWithTag:TagTableView];
        [tableview reloadData];
    }
    else
    {
        showType = eShowTip;
        //NSString * strTemp = [NSString stringWithString:Word];
        std::string strtemp = [Word UTF8String];
        KS_BLOCK_DECLARE
        {
            CSearchTipRequest *pRequest = new CSearchTipRequest(strtemp);
            if(pRequest->RequestTip())
            {
                KS_BLOCK_DECLARE
                {
                    //NSLog(@"request over,%s",strtemp.c_str());
                    if([inputWord isEqualToString:[NSString stringWithUTF8String:strtemp.c_str()]])
                    {
                        //NSLog(@"tip over,%s",strtemp.c_str());
                        m_vecTip.clear();
                        m_vecTip = pRequest->GetTips();
                        UITableView * tableview = (UITableView*)[self viewWithTag:TagTableView];
                        [tableview reloadData];
                    }
                    
                }
                KS_BLOCK_SYNRUN();
            }
            else
            {
                KS_BLOCK_DECLARE
                {
                    //NSLog(@"request fail,%s",strtemp.c_str());
                    if([inputWord isEqualToString:[NSString stringWithUTF8String:strtemp.c_str()]])
                    {
                        m_vecTip.clear();
                        UITableView * tableview = (UITableView*)[self viewWithTag:TagTableView];
                        [tableview reloadData];
                    }
                    
                }
                KS_BLOCK_SYNRUN();
            }
            delete pRequest;
        }
        KS_BLOCK_RUN_THREAD();
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)dealloc
{
    [super dealloc];
    if(inputWord)
       [inputWord release];
}

-(void)onClearHistory:(id)sender
{
    [searchdelegate ClearSearchHistroy];
    UITableView * tableview = (UITableView*)[self viewWithTag:TagTableView];
    [tableview reloadData];
}

-(void)onDeleteHistory:(id)sender
{
    UITableViewCell* cell = (UITableViewCell*)[[(UIButton*)sender superview]superview];
    UITableView * tableview = (UITableView*)[self viewWithTag:TagTableView];
    NSIndexPath *indexPath = [tableview indexPathForCell:cell];
    if(indexPath == nil)
        return;
    int row = indexPath.row;
    if(row < arrHistory.count)
        [searchdelegate DeleteSearchHistroy:[arrHistory objectAtIndex:row]];
    
    [tableview reloadData];
}

#pragma mark - TableView DataSource and Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(showType == eShowNone)
        return 0;
    else if(showType == eShowHistory)
    {
        if(arrHistory.count == 0)
            return 0;
        else
            return arrHistory.count+1;
    }
    else
        return m_vecTip.size();
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 43;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(showType == eShowNone)
        return nil;
    static NSString *s_commontableIdentifier = @"commonIdentifier";
    static NSString *s_historytableIdentifier = @"histroyIdentifier";
    UITableViewCell* cell = nil;
    NSInteger row = [indexPath row];  
    if(showType == eShowHistory && row > arrHistory.count-1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:s_historytableIdentifier];
        if(cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:s_historytableIdentifier] autorelease];
            
            int cellheight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
            UIImageView * bkimage = [[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, cellheight)]autorelease];
            bkimage.image = CImageMgr::GetImageEx("listbk_5_1.png");
            cell.backgroundView = bkimage;
            
            UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
            [button setTag:Tag_ClearHistory];
            [button setFrame:CGRectMake(100, 5, 100, 30)];
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button titleLabel].font = [UIFont systemFontOfSize:13];
            [button setTitle:@"清空搜索历史" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(onClearHistory:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:button];
            
            cell.selectionStyle = UITableViewCellSelectionStyleGray;

        }
        
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:s_commontableIdentifier];
        if(cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:s_commontableIdentifier] autorelease];
            
            int cellheight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
            UIImageView * bkimage = [[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, cellheight)]autorelease];
            bkimage.image = CImageMgr::GetImageEx("listbk_5_1.png");
            cell.backgroundView = bkimage;
            
            UILabel *textLabel = [[[UILabel alloc]initWithFrame:CGRectMake(12, 12, 250, 20)]autorelease];
            textLabel.font= [UIFont systemFontOfSize:17];
            textLabel.textColor = [UIColor blackColor];
            [textLabel setShadowColor:UIColorFromRGBValue(0xffffff)];
            [textLabel setShadowOffset:CGSizeMake(0, 1)];
            textLabel.lineBreakMode = UILineBreakModeTailTruncation;
            textLabel.backgroundColor = [UIColor clearColor];
            [textLabel setTag:Tag_ListText];
            [cell.contentView addSubview:textLabel];
        
            
            UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
            [button setTag:Tag_DeleteHisory];
            [button setFrame:CGRectMake(276, 0, 44, 43)];
            [button setBackgroundImage:CImageMgr::GetImageEx("deletehistory.png") forState:UIControlStateNormal];
            [button addTarget:self action:@selector(onDeleteHistory:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:button];
            
            cell.selectionStyle = UITableViewCellSelectionStyleGray;

        }
        
        UILabel * textLabel = (UILabel*)[cell.contentView viewWithTag:Tag_ListText];
        if(showType == eShowHistory && row < [arrHistory count])
        {
            textLabel.text = [arrHistory objectAtIndex:row];
            UIButton * btndelete = (UIButton*)[cell.contentView viewWithTag:Tag_DeleteHisory];
            btndelete.hidden = false;
            
        }
        else if(showType == eShowTip && row < m_vecTip.size())
        {
            textLabel.text = [NSString stringWithUTF8String:m_vecTip[row].c_str()];
            UIButton * btndelete = (UIButton*)[cell.contentView viewWithTag:Tag_DeleteHisory];
            btndelete.hidden = true;
        }
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
     NSInteger row = [indexPath row];  
    if(showType == eShowHistory)
    {
        if(row < arrHistory.count)
            [searchdelegate SelectTip:[arrHistory objectAtIndex:row]];
        else if(row == arrHistory.count)
        {
            [searchdelegate ClearSearchHistroy];
            [tableView reloadData];
        }
    }
    else if(showType == eShowTip)
    {
        if(row <  m_vecTip.size())
            [searchdelegate SelectTip:[NSString stringWithUTF8String:m_vecTip[row].c_str()]];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [searchdelegate ScrollTip];
}

@end
