//
//  StartDateCell.m
//  LastMinute
//
//  Created by 蔡 小雨 on 14-6-19.
//
//

#import "StartDateCell.h"

@interface StartDateCell()
<
QYDateViewDelegate
>

@property (nonatomic, retain) UIImageView        *headerBgImageView;
@property (nonatomic, retain) UIImageView        *bottomBgImageView;

@property (nonatomic, retain) UILabel            *yearMonthLabel;

@end

@implementation StartDateCell

-(void)dealloc
{
    QY_SAFE_RELEASE(_sectionCategory);
    
    QY_VIEW_RELEASE(_headerBgImageView);
    QY_VIEW_RELEASE(_bottomBgImageView);
    
    QY_VIEW_RELEASE(_yearMonthLabel);
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        //header 背景图
        _headerBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 301, k_date_header_height)];
        _headerBgImageView.image = [[UIImage imageNamed:@"x_startDate_HeaderBg.png"] stretchableImageWithLeftCapWidth:6 topCapHeight:3];
        [self.contentView addSubview:_headerBgImageView];
        
        //bottom 背景图
        _bottomBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, _headerBgImageView.frame.size.height, _headerBgImageView.frame.size.width, 360+1)];
        _bottomBgImageView.image = [[UIImage imageNamed:@"x_startDate_BottonBg.png"] stretchableImageWithLeftCapWidth:6 topCapHeight:1];
        _bottomBgImageView.userInteractionEnabled = YES;
        [self.contentView addSubview:_bottomBgImageView];
        
        //2014年3月
        _yearMonthLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _headerBgImageView.frame.size.width, 44)];
        _yearMonthLabel.text = @"2014年3月";
        _yearMonthLabel.textColor = [UIColor whiteColor];
        _yearMonthLabel.font = [UIFont systemFontOfSize:18];
        _yearMonthLabel.textAlignment = NSTextAlignmentCenter;
        _yearMonthLabel.backgroundColor = [UIColor clearColor];
        [_headerBgImageView addSubview:_yearMonthLabel];
        
        //日
        UILabel *sundayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _headerBgImageView.frame.size.height-29, 43, 29)];
        sundayLabel.text = @"日";
        sundayLabel.textColor = [UIColor whiteColor];
        sundayLabel.font = [UIFont systemFontOfSize:12];
        sundayLabel.textAlignment = NSTextAlignmentCenter;
        sundayLabel.backgroundColor = [UIColor clearColor];
        [_headerBgImageView addSubview:sundayLabel];
        [sundayLabel release];
        
        
        //一
        UILabel *mondayLabel = [[UILabel alloc] initWithFrame:CGRectMake(43, _headerBgImageView.frame.size.height-29, 43, 29)];
        mondayLabel.text = @"一";
        mondayLabel.textColor = [UIColor whiteColor];
        mondayLabel.font = [UIFont systemFontOfSize:12];
        mondayLabel.textAlignment = NSTextAlignmentCenter;
        mondayLabel.backgroundColor = [UIColor clearColor];
        [_headerBgImageView addSubview:mondayLabel];
        [mondayLabel release];
        
        //二
        UILabel *tuesdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(43*2, _headerBgImageView.frame.size.height-29, 43, 29)];
        tuesdayLabel.text = @"二";
        tuesdayLabel.textColor = [UIColor whiteColor];
        tuesdayLabel.font = [UIFont systemFontOfSize:12];
        tuesdayLabel.textAlignment = NSTextAlignmentCenter;
        tuesdayLabel.backgroundColor = [UIColor clearColor];
        [_headerBgImageView addSubview:tuesdayLabel];
        [tuesdayLabel release];
        
        //三
        UILabel *wednesdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(43*3, _headerBgImageView.frame.size.height-29, 43, 29)];
        wednesdayLabel.text = @"三";
        wednesdayLabel.textColor = [UIColor whiteColor];
        wednesdayLabel.font = [UIFont systemFontOfSize:12];
        wednesdayLabel.textAlignment = NSTextAlignmentCenter;
        wednesdayLabel.backgroundColor = [UIColor clearColor];
        [_headerBgImageView addSubview:wednesdayLabel];
        [wednesdayLabel release];
        
        //四
        UILabel *thursdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(43*4, _headerBgImageView.frame.size.height-29, 43, 29)];
        thursdayLabel.text = @"四";
        thursdayLabel.textColor = [UIColor whiteColor];
        thursdayLabel.font = [UIFont systemFontOfSize:12];
        thursdayLabel.textAlignment = NSTextAlignmentCenter;
        thursdayLabel.backgroundColor = [UIColor clearColor];
        [_headerBgImageView addSubview:thursdayLabel];
        [thursdayLabel release];
        
        //五
        UILabel *fridayLabel = [[UILabel alloc] initWithFrame:CGRectMake(43*5, _headerBgImageView.frame.size.height-29, 43, 29)];
        fridayLabel.text = @"五";
        fridayLabel.textColor = [UIColor whiteColor];
        fridayLabel.font = [UIFont systemFontOfSize:12];
        fridayLabel.textAlignment = NSTextAlignmentCenter;
        fridayLabel.backgroundColor = [UIColor clearColor];
        [_headerBgImageView addSubview:fridayLabel];
        [fridayLabel release];
        
        //六
        UILabel *saturdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(43*6, _headerBgImageView.frame.size.height-29, 43, 29)];
        saturdayLabel.text = @"六";
        saturdayLabel.textColor = [UIColor whiteColor];
        saturdayLabel.font = [UIFont systemFontOfSize:12];
        saturdayLabel.textAlignment = NSTextAlignmentCenter;
        saturdayLabel.backgroundColor = [UIColor clearColor];
        [_headerBgImageView addSubview:saturdayLabel];
        [saturdayLabel release];
        
        
        
        
    }
    return self;
}

- (void)configDateViewWithSectionCategory:(QYSectionCategory*)aSectionCategory
{
    //清除所有的View
    for (UIView *v in _bottomBgImageView.subviews) {
        [v removeFromSuperview];
    }
    
    
    NSInteger preMonth = [_sectionCategory.cateMonth intValue]-1==0?12:[_sectionCategory.cateMonth intValue]-1;
    NSInteger preYear = [_sectionCategory.cateMonth intValue]-1==0?[_sectionCategory.cateYear intValue]-1:[_sectionCategory.cateYear intValue];
    //计算上一个月有多少天
    NSInteger preDays = [QYSectionCategory daysFromMonth:preMonth  year:preYear];
    //计算本月有多少天
    NSInteger days = [QYSectionCategory daysFromMonth:[_sectionCategory.cateMonth intValue] year:[_sectionCategory.cateYear intValue]];
    
    //计算1号是星期几
    NSInteger dayOfWeek = [QYSectionCategory dayOfWeekFromMonth:[_sectionCategory.cateMonth intValue] year:[_sectionCategory.cateYear intValue]];
    //计算有多少行
    NSInteger dateRow = [QYSectionCategory dateRowsFromDays:days dayOfWeek:dayOfWeek];
    NSInteger dateCount = dateRow*7;
    
    NSInteger date = 0;
    for (int i=0; i<dateCount; i++) {
        NSInteger row = i/7;
        NSInteger column = i%7;
        
        QYDateView *dateView = [[QYDateView alloc] initWithFrame:CGRectMake(k_date_width*column, k_date_height*row, 0, 0)];
        dateView.delegate = self;
        if (i<dayOfWeek&&dayOfWeek!=7) {
            date = preDays-(dayOfWeek-i)+1;
            dateView.isOtherDate = YES;
        }else{
            date = (i-dayOfWeek)%days+1;//日期
            dateView.isOtherDate = i>=dayOfWeek%7+days;
            
            if (i<dayOfWeek%7+days) {
                for (int j=0; j<[_sectionCategory.cateDateCategoryArray count]; j++) {
                    QYDateCategory *dateCategory = [_sectionCategory.cateDateCategoryArray objectAtIndex:j];
                    if ([dateCategory.categoryDate intValue]==date) {
                        dateView.dateCategory = dateCategory;
                        break;
                    }
                }
            }
            
        }        
        
        dateView.date = date;
        [_bottomBgImageView addSubview:dateView];
        [dateView release];
        
    }
    
    CGRect frame = _bottomBgImageView.frame;
    frame.size.height = dateRow*k_date_height+3;
    _bottomBgImageView.frame = frame;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setSectionCategory:(QYSectionCategory *)sectionCategory
{
    if (_sectionCategory) {
        QY_SAFE_RELEASE(_sectionCategory);
    }
    
    _sectionCategory = [sectionCategory retain];
    
    //2014年3月
    _yearMonthLabel.text = [NSString stringWithFormat:@"%@年%@月", _sectionCategory.cateYear, _sectionCategory.cateMonth];
    
    //构造DateView
    [self configDateViewWithSectionCategory:_sectionCategory];
    
    
}

#pragma mark - QYDateViewDelegate
- (void)QYDateViewCategoryButtonClickAction:(id)sender view:(QYDateView*)aDateView
{
    if ([_delegate respondsToSelector:@selector(StartDateCellCategoryButtonClickAction:cell:dateCategory:)]) {
        [_delegate StartDateCellCategoryButtonClickAction:sender cell:self dateCategory:aDateView.dateCategory];
    }

}

@end
