//
//  QYDateView.m
//  LastMinute
//
//  Created by 蔡 小雨 on 14-6-19.
//
//

#import "QYDateView.h"



@interface QYDateView()

@property (nonatomic, retain) UIImageView          *horizontalLine;
@property (nonatomic, retain) UIImageView          *verticalLine;

@property (nonatomic, retain) UILabel              *dateLabel;
@property (nonatomic, retain) UIButton             *categoryButton;

@property (nonatomic, retain) UILabel              *priceLabel;
@property (nonatomic, retain) UILabel              *stockLabel;

@end

@implementation QYDateView

-(void)dealloc
{
    QY_SAFE_RELEASE(_dateCategory);
    QY_VIEW_RELEASE(_horizontalLine);
    QY_VIEW_RELEASE(_verticalLine);
    
    QY_VIEW_RELEASE(_dateLabel);
    QY_VIEW_RELEASE(_categoryButton);
    
    QY_VIEW_RELEASE(_priceLabel);
    QY_VIEW_RELEASE(_stockLabel);
    [super dealloc];
}

-(id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        
    }
    
    return self;

}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, k_date_width, k_date_height);
        self.userInteractionEnabled = YES;
        
        //横线
        _horizontalLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1)];
        _horizontalLine.image = [[UIImage imageNamed:@"x_lastminute_horizontalLine.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:0];
        [self addSubview:_horizontalLine];
        
        //竖线
        _verticalLine = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width-1, 0, 1, self.frame.size.height)];
        _verticalLine.image = [[UIImage imageNamed:@"x_lastminute_verticalLine.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:5];
        [self addSubview:_verticalLine];
        
        //category button
        _categoryButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 1, k_date_width-1, k_date_height-1)];
        [_categoryButton setBackgroundImage:[[UIImage imageNamed:@"x_dateCategory_yellow.png"] stretchableImageWithLeftCapWidth:7 topCapHeight:7] forState:UIControlStateNormal];
        [_categoryButton setBackgroundImage:[[UIImage imageNamed:@"x_dateCategory_red.png"] stretchableImageWithLeftCapWidth:7 topCapHeight:7] forState:UIControlStateHighlighted];
        [_categoryButton addTarget:self action:@selector(categoryButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_categoryButton];
        
        //priceLabel
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 27, _categoryButton.frame.size.width, 15)];
        _priceLabel.text = @"¥58306";
        _priceLabel.textAlignment = NSTextAlignmentCenter;
        _priceLabel.textColor = [UIColor colorWithRed:203.0/255.0f green:9.0/255.0f blue:0.0/255.0f alpha:1.0f];
        _priceLabel.font = [UIFont systemFontOfSize:9];
        _priceLabel.backgroundColor = [UIColor clearColor];
        [_categoryButton addSubview:_priceLabel];
        
        //stockLabel
        _stockLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, _categoryButton.frame.size.width, 16)];
        _stockLabel.text = @"余4570";
        _stockLabel.textAlignment = NSTextAlignmentCenter;
        _stockLabel.textColor = [UIColor colorWithRed:99.0/255.0f green:99.0/255.0f blue:99.0/255.0f alpha:1.0f];
        _stockLabel.font = [UIFont systemFontOfSize:9];
        _stockLabel.backgroundColor = [UIColor clearColor];
        [_categoryButton addSubview:_stockLabel];
        
        //日期 label
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, k_date_width, 22)];
        _dateLabel.text = @"1";
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        _dateLabel.textColor = [UIColor colorWithRed:255.0/255.0f green:247.0/255.0f blue:165.0/255.0f alpha:1.0f];
        _dateLabel.font = [UIFont systemFontOfSize:14.0f];
        _dateLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_dateLabel];
        
        _categoryButton.hidden = YES;
        
    }
    return self;
}

-(void)setDate:(NSInteger)date
{
    _date = date;
    
    _dateLabel.text = [NSString stringWithFormat:@"%d", date];

}

-(void)setIsOtherDate:(BOOL)isOtherDate
{
    _isOtherDate = isOtherDate;
    
    if (_isOtherDate) {
        _dateLabel.textColor = [UIColor colorWithRed:158.0/255.0f green:163.0/255.0 blue:171.0/255.0f alpha:1.0f];
    }else{
        _dateLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    }
}

-(void)setDateCategory:(QYDateCategory *)dateCategory
{
    if (_dateCategory) {
        QY_SAFE_RELEASE(_dateCategory);
    }
    _dateCategory = [dateCategory retain];
    
    _categoryButton.hidden = dateCategory?NO:YES;
    //¥58306
    _priceLabel.text = [NSString stringWithFormat:@"¥%@", _dateCategory.categoryPrice];
    //余4570
    _stockLabel.text = [NSString stringWithFormat:@"余%d", [_dateCategory.categoryStock intValue]];
    
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)categoryButtonClickAction:(id)sender
{
    NSLog(@"------------category");
    
    if ([_delegate respondsToSelector:@selector(QYDateViewCategoryButtonClickAction:view:)]) {
        [_delegate QYDateViewCategoryButtonClickAction:sender view:self];
    }
    
}

@end
