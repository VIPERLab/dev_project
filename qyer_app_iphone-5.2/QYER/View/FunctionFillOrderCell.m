//
//  FunctionFillOrderCell.m
//  LastMinute
//
//  Created by 蔡 小雨 on 14-2-18.
//
//

#import "FunctionFillOrderCell.h"
#import "QYCommonToast.h"

#define Word_Color_Normal       [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f]
//#define Word_Color_Selected     [UIColor colorWithRed:242.0/255.0f green:100.0/255.0f blue:38.0/255.0f alpha:1.0f]
#define Word_Color_Disabled     [UIColor colorWithRed:174.0/255.0f green:174.0/255.0f blue:174.0/255.0f alpha:1.0f]

@interface FunctionFillOrderCell()

@property (nonatomic, retain) UILabel  *nameLabel;
@property (nonatomic, retain) UILabel  *priceLabel;

@end

@implementation FunctionFillOrderCell

-(void)dealloc
{
    QY_VIEW_RELEASE(_contentBgButton);
    QY_VIEW_RELEASE(_nameLabel);
    QY_VIEW_RELEASE(_priceLabel);
    
    QY_SAFE_RELEASE(_product);
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor clearColor];
        
        //背景 button
        _contentBgButton = [[QYCheckBox alloc] initWithFrame:CGRectMake(24, 0, 272, 34)];
        _contentBgButton.checkedBgImage = [[UIImage imageNamed:@"x_fillOrder_taocan_select.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:17];
        _contentBgButton.unCheckedBgImage = [[UIImage imageNamed:@"x_fillOrder_taocan_normal.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:17];
        _contentBgButton.disabledBgImage = [[UIImage imageNamed:@"x_fillOrder_taocan_disabled.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:17];
        [_contentBgButton addTarget:self action:@selector(contentBgButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//        [_contentBgButton setBackgroundImage:[UIImage imageNamed:@"fillOrder_taocan_normal.png"] forState:UIControlStateNormal];
//        [_contentBgButton setBackgroundImage:[UIImage imageNamed:@"fillOrder_taocan_select.png"] forState:UIControlStateSelected];
//        [_contentBgButton setBackgroundImage:[UIImage imageNamed:@"fillOrder_taocan_disabled.png"] forState:UIControlStateDisabled];
        [self.contentView addSubview:_contentBgButton];
        
        //套餐1（库存：2）
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(9, 0, k_ProductName_Width, 34)];
        _nameLabel.text = @"套餐1（库存：2）";
        _nameLabel.numberOfLines = 0;
//        _nameLabel.textColor = Word_Color_Normal;
        _nameLabel.font = k_ProductName_Font;
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.lineBreakMode = NSLineBreakByClipping;
        [_contentBgButton addSubview:_nameLabel];
        
        //200元
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(205-15, 0, 77, 34)];
        _priceLabel.text = @"100000.00元";
//        _priceLabel.textColor = Word_Color_Normal;
        _priceLabel.font = k_ProductName_Font;
        _priceLabel.textAlignment = NSTextAlignmentRight;
        _priceLabel.backgroundColor = [UIColor clearColor];
        [_contentBgButton addSubview:_priceLabel];
        
        
        
        
    }
    return self;
}

//设置文字颜色
- (void)setColorOfContentWithSelected:(BOOL)isSelected
{
    _contentBgButton.selected = isSelected;//如果该产品有效，则判断产品是否选中
    _nameLabel.textColor = isSelected?Color_Orange:Word_Color_Normal;
    _priceLabel.textColor = _nameLabel.textColor;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setProduct:(LastMinuteProduct *)aProduct
{
    if (_product) {
        QY_SAFE_RELEASE(_product);
    }
    
    _product = [aProduct retain];
    
    //套餐1（库存：2）
    _nameLabel.text = [NSString stringWithFormat:k_ProductTitle_Format, _product.productTitle];// [_product.productStock intValue]
    
    //200元
    _priceLabel.text = [_product.productPrice floatValue]==0?@"":[NSString stringWithFormat:@"%@元", [self correctPrice:[_product.productPrice floatValue]]];//如果价格为0，则不显示
    
    if ([_product.productStock intValue]<=0) {
        _contentBgButton.enabled = NO;
    }else{
        
        _contentBgButton.enabled = YES;
//        [_contentBgButton setSelected:aProduct.isSelected];
        [self setColorOfContentWithSelected:aProduct.isSelected];//设置文字颜色
        
    
    }
    
    //调整布局
    [self adjustCellLayout];
}

//调整布局
- (void)adjustCellLayout
{
    
    CGFloat height = [FunctionFillOrderCell heightForCellWithProduct:_product]-k_Cell_Padding;
    
    //背景 button
    CGRect frame = _contentBgButton.frame;
    frame.size.height = height;
    _contentBgButton.frame = frame;
    
    //套餐1（库存：2）
    frame = _nameLabel.frame;
    frame.size.width = [_product.productCid intValue]==0?k_ProductName_Width_Long:k_ProductName_Width;
    frame.size.height = height;
    _nameLabel.frame = frame;
    
    //200元
    frame = _priceLabel.frame;
    frame.size.height = height;
    _priceLabel.frame = frame;
    
    

}

//过滤价格显示格式
- (NSString*)correctPrice:(CGFloat)aPrice
{
    NSString *priceA = [NSString stringWithFormat:@"%.2f", aPrice];
    NSString *priceB = [NSString stringWithFormat:@"%.f", aPrice];
    CGFloat decimal = [priceA floatValue]-[priceB floatValue];
    
    return decimal>0?priceA:priceB;
    
}

#pragma mark - click
- (void)contentBgButtonClick:(id)sender
{
    [_delegate FunctionFillOrderCellContentBgButtonClick:sender cell:self];
    
    
}

//获取Cell高度
+ (CGFloat)heightForCellWithProduct:(LastMinuteProduct*)aProduct 
{
    
    CGFloat nameWidth = [aProduct.productCid intValue]==0?k_ProductName_Width_Long:k_ProductName_Width;
    
    NSString *productTitle = [NSString stringWithFormat:k_ProductTitle_Format, aProduct.productTitle];//, [aProduct.productStock intValue]
    CGSize size = [productTitle sizeWithFont:k_ProductName_Font constrainedToSize:CGSizeMake(nameWidth, MAXFLOAT) lineBreakMode:NSLineBreakByClipping];
    CGFloat realHeight = size.height+19+k_Cell_Padding;
    
    return MAX(realHeight, 45);//45;

}

@end
