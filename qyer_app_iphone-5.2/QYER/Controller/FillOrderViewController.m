//
//  FillOrderViewController.m
//  LastMinute
//
//  Created by 蔡 小雨 on 14-6-16.
//
//

#import "FillOrderViewController.h"
#import "QYCheckBox.h"
//#import "WebViewViewController.h"
#import "WebViewController.h"
#import "FunctionFillOrderCell.h"
#import "LastMinuteOrderInfo.h"
#import "StartDateViewController.h"
#import "ConfirmOrderSecondViewController.h"
#import "Reachability.h"
#import "NSString+MD5.h"
#import "QYCommonUtil.h"
#import "QYAPIClient.h"
#import "MBProgressHUD.h"

@interface FillOrderViewController ()
<
UITableViewDataSource,
UITableViewDelegate,
FunctionFillOrderCellDelegate,
StartDateViewControllerDelegate
>

@property (nonatomic, retain) LastMinuteOrderInfo                      *orderInfo;
@property (nonatomic, retain) LastMinuteProduct                        *selectedProduct;

@property (nonatomic, retain) UIScrollView                             *mainScrollView;
@property (nonatomic, retain) UIView                                   *mainContentView;

@property (nonatomic, retain) UIImageView                              *zhekouImageView;
@property (nonatomic, retain) UILabel                                  *zhekouTitleLabel;

@property (nonatomic, retain) UILabel                                  *zhekouPrefixLabel;
@property (nonatomic, retain) UILabel                                  *zhekouPriceLabel;
@property (nonatomic, retain) UILabel                                  *zhekouPriceUnitLabel;

@property (nonatomic, retain) UILabel                                  *zongeLabel;
@property (nonatomic, retain) UILabel                                  *zongeUnitLabel;

@property (nonatomic, retain) UIView                                   *productCategoryContentView;
@property (nonatomic, retain) UIView                                   *buyerInfoContentView;

@property (nonatomic, assign) BOOL                                     isDirectionChecked;

@property (nonatomic, retain) UIButton                                 *minusNumButton;
@property (nonatomic, retain) UIButton                                 *addNumButton;
@property (nonatomic, retain) UILabel                                  *buyCountLabel;

@property (nonatomic, retain) UILabel                                  *stockLabel;

@property (nonatomic, retain) UITableView                              *productsTableView;

@property (nonatomic, retain) FunctionFillOrderCell                    *selectedCell;

@property (nonatomic, retain) UITextField                              *startDateTextField;

@property (nonatomic, retain) UITextField                              *nameTextField;
@property (nonatomic, retain) UITextField                              *phoneTextField;
@property (nonatomic, retain) UITextField                              *emailTextField;

@property (nonatomic, retain) QYDateCategory                           *selectedDateCategory;
@property (nonatomic, assign) NSInteger                                currStock;//当前库存
@property (nonatomic, assign) CGFloat                                  currPrice;//当前价格

@property (nonatomic, retain) UIView                                   *startDateContentView;


@end

@implementation FillOrderViewController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    QY_VIEW_RELEASE(_mainScrollView);
    QY_VIEW_RELEASE(_mainContentView);
    
    QY_SAFE_RELEASE(_homeDetailViewController);
    
    QY_VIEW_RELEASE(_zhekouImageView);
    QY_VIEW_RELEASE(_zhekouTitleLabel);
    
    QY_VIEW_RELEASE(_zhekouPrefixLabel);
    QY_VIEW_RELEASE(_zhekouPriceLabel);
    QY_VIEW_RELEASE(_zhekouPriceUnitLabel);
    
    QY_VIEW_RELEASE(_zongeLabel);
    QY_VIEW_RELEASE(_zongeUnitLabel);
    
    QY_VIEW_RELEASE(_productCategoryContentView);
    QY_VIEW_RELEASE(_buyerInfoContentView);
    
    QY_VIEW_RELEASE(_minusNumButton);
    QY_VIEW_RELEASE(_addNumButton);
    QY_VIEW_RELEASE(_buyCountLabel);
    
    QY_SAFE_RELEASE(_selectedProduct);
    QY_VIEW_RELEASE(_stockLabel);
    
    QY_VIEW_RELEASE(_productsTableView);
    QY_SAFE_RELEASE(_orderInfo);
    
    QY_SAFE_RELEASE(_selectedCell);
    
    QY_VIEW_RELEASE(_startDateTextField);
    
    QY_VIEW_RELEASE(_nameTextField);
    QY_VIEW_RELEASE(_phoneTextField);
    QY_VIEW_RELEASE(_emailTextField);
    
    QY_SAFE_RELEASE(_selectedDateCategory);
    QY_VIEW_RELEASE(_startDateContentView);
    
    [super dealloc];
}

#pragma mark - super
- (id)init
{
    self = [super init];
    if(self != nil)
    {
        _isDirectionChecked = YES;
        
    }
    
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//-(void)loadView
//{
//    [super loadView];
//
//}

//产品类型
- (void)initProductCategoryViewWithPadding:(CGFloat)aPadding
{
    _productCategoryContentView = [[UIView alloc] initWithFrame:CGRectMake(0, aPadding, 320, 300)];
    _productCategoryContentView.autoresizesSubviews = YES;
    _buyerInfoContentView.backgroundColor = [UIColor redColor];
    [_mainContentView addSubview:_productCategoryContentView];
    
    //背景图
    UIImageView *productCategoryBgImgView = [[UIImageView alloc] initWithFrame:_productCategoryContentView.bounds];
    productCategoryBgImgView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    productCategoryBgImgView.image = [[UIImage imageNamed:@"x_order_businessInfo_bg.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:66];
    [_productCategoryContentView addSubview:productCategoryBgImgView];
    [productCategoryBgImgView release];
    
    //个人联系信息
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 14, 200, 19)];
    titleLabel.text = @"产品类型";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:17];
    [_productCategoryContentView addSubview:titleLabel];
    [titleLabel release];
    
    //选择套餐 tableView
    _productsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 320, 154)];
    _productsTableView.bounces = NO;
    _productsTableView.delegate = self;
    _productsTableView.dataSource = self;
    _productsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _productsTableView.backgroundColor = [UIColor clearColor];
    [_productCategoryContentView addSubview:_productsTableView];
    
    //顶部空留15px
    UIView *spaceHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _productsTableView.frame.size.width, 15)];
    spaceHeaderView.backgroundColor = [UIColor clearColor];
    _productsTableView.tableHeaderView = spaceHeaderView;
    [spaceHeaderView release];
    
    
    //横线--------------------------------------------------------------------------------------------------------------
    //出发日期 contentView
    _startDateContentView = [[UIView alloc] initWithFrame:CGRectMake(0, _productCategoryContentView.frame.size.height-194, 320, 50)];
    _startDateContentView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _startDateContentView.backgroundColor = [UIColor clearColor];
    [_productCategoryContentView addSubview:_startDateContentView];
    
    //出发日期
    UIImageView *lineImageView_1 = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 300, 1)];
//    lineImageView_1.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    lineImageView_1.image = [[UIImage imageNamed:@"x_lastminute_line.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:1];
    [_startDateContentView addSubview:lineImageView_1];
    [lineImageView_1 release];
    
    //出发日期：
    UILabel *startDateTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 0, 200, 50)];
//    startDateTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    startDateTitleLabel.text = @"出发日期:";
    startDateTitleLabel.backgroundColor = [UIColor clearColor];
    startDateTitleLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    startDateTitleLabel.font = [UIFont systemFontOfSize:15];
    [_startDateContentView addSubview:startDateTitleLabel];
    [startDateTitleLabel release];
    
    //请选择出发日期
    _startDateTextField = [[UITextField alloc] initWithFrame:CGRectMake(93, 0, 200, 50)];
//    _startDateTextField.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
//    _startDateTextField.text = @"2014/12/19出发";//test
    _startDateTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _startDateTextField.placeholder = @"请选择出发日期";
    _startDateTextField.font = [UIFont systemFontOfSize:15];
    _startDateTextField.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    _startDateTextField.textAlignment = NSTextAlignmentCenter;
    _startDateTextField.backgroundColor = [UIColor clearColor];
    _startDateTextField.userInteractionEnabled = NO;
    [_startDateContentView addSubview:_startDateTextField];
    
    //请选择出发日期 点击button
    UIButton *startDateButton = [[UIButton alloc] initWithFrame:_startDateTextField.frame];
//    startDateButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    startDateButton.backgroundColor = [UIColor clearColor];
    [startDateButton addTarget:self action:@selector(startDateButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [_startDateContentView addSubview:startDateButton];
    [startDateButton release];
    
    
    //横线--------------------------------------------------------------------------------------------------------------
    //购买数量
    UIImageView *lineImageView_2 = [[UIImageView alloc] initWithFrame:CGRectMake(10, _productCategoryContentView.frame.size.height-144, 300, 1)];
    lineImageView_2.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    lineImageView_2.image = [[UIImage imageNamed:@"x_lastminute_line.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:1];
    [_productCategoryContentView addSubview:lineImageView_2];
    [lineImageView_2 release];
    
    //购买数量：
    UILabel *buyCountTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, _productCategoryContentView.frame.size.height-144+30, 200, 17)];
    buyCountTitleLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    buyCountTitleLabel.text = @"购买数量:";
    buyCountTitleLabel.backgroundColor = [UIColor clearColor];
    buyCountTitleLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    buyCountTitleLabel.font = [UIFont systemFontOfSize:15];
    [_productCategoryContentView addSubview:buyCountTitleLabel];
    [buyCountTitleLabel release];
    
    //- button
    _minusNumButton = [[UIButton alloc] initWithFrame:CGRectMake(129, _productCategoryContentView.frame.size.height-144+20+2, 45, 33)];
    _minusNumButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [_minusNumButton setImage:[UIImage imageNamed:@"x_fillOrder_numberLeft.png"] forState:UIControlStateNormal];
    [_minusNumButton setImage:[UIImage imageNamed:@"x_fillOrder_numberLeft_highlighted.png"] forState:UIControlStateHighlighted];
    [_minusNumButton addTarget:self action:@selector(minusNumButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [_productCategoryContentView addSubview:_minusNumButton];
    _minusNumButton.enabled = NO;
    
    //2 bgImageView
    UIImageView *numBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(129+45, _productCategoryContentView.frame.size.height-144+20+2, 44, 33)];
    numBgImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    numBgImageView.image = [UIImage imageNamed:@"x_fillOrder_numberMiddle.png"];
    [_productCategoryContentView addSubview:numBgImageView];
    
    //2 label
    _buyCountLabel = [[UILabel alloc] initWithFrame:numBgImageView.bounds];
    _buyCountLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _buyCountLabel.text = [NSString stringWithFormat:@"%d", _selectedProduct.currentBuyCount];
    _buyCountLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    _buyCountLabel.font = [UIFont systemFontOfSize:15.0f];
    _buyCountLabel.textAlignment = NSTextAlignmentCenter;
    _buyCountLabel.backgroundColor = [UIColor clearColor];
    [numBgImageView addSubview:_buyCountLabel];
    [numBgImageView release];
    
    //+ button
    _addNumButton = [[UIButton alloc] initWithFrame:CGRectMake(129+45+44, _productCategoryContentView.frame.size.height-144+20+2, 45, 33)];
    _addNumButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [_addNumButton setImage:[UIImage imageNamed:@"x_fillOrder_numberRight.png"] forState:UIControlStateNormal];
    [_addNumButton setImage:[UIImage imageNamed:@"x_fillOrder_numberRight_highlighted.png"] forState:UIControlStateHighlighted];
    [_addNumButton addTarget:self action:@selector(addNumButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [_productCategoryContentView addSubview:_addNumButton];
    
    //剩余999999件
    _stockLabel = [[UILabel alloc] initWithFrame:CGRectMake(129, _productCategoryContentView.frame.size.height-144+20+2+33+13, 134, 17)];
    _stockLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
//    _stockLabel.text = @"剩余999999件";//test
    _stockLabel.textAlignment = NSTextAlignmentCenter;
    _stockLabel.textColor = [UIColor colorWithRed:242.0f/255.0f green:100.0/255.0f blue:38.0/255.0f alpha:1.0];
    _stockLabel.font = [UIFont systemFontOfSize:15.0f];
    _stockLabel.backgroundColor = [UIColor clearColor];
    [_productCategoryContentView addSubview:_stockLabel];
    
    //横线--------------------------------------------------------------------------------------------------------------
    //穷游条款
    UIImageView *lineImageView_3 = [[UIImageView alloc] initWithFrame:CGRectMake(10, _productCategoryContentView.frame.size.height-44, 300, 1)];
    lineImageView_3.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    lineImageView_3.image = [[UIImage imageNamed:@"x_lastminute_line.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:1];
    [_productCategoryContentView addSubview:lineImageView_3];
    [lineImageView_3 release];
    
    //checkbox
    QYCheckBox *directionCheckBox = [[QYCheckBox alloc] initWithFrame:CGRectMake(5-2+10, _productCategoryContentView.frame.size.height-5-34-1, 34, 34)];
    directionCheckBox.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    directionCheckBox.checkedImage = [UIImage imageNamed:@"x_direction_checked.png"];
    directionCheckBox.unCheckedImage = [UIImage imageNamed:@"x_direction_unchecked.png"];
    directionCheckBox.highlightedImage = [UIImage imageNamed:@"x_direction_unchecked_highlighted.png"];
    directionCheckBox.disabledImage = [UIImage imageNamed:@"x_direction_disabled.png"];
    directionCheckBox.backgroundColor = [UIColor clearColor];
    [directionCheckBox addTarget:self action:@selector(directionCheckBoxClickAction:) forControlEvents:UIControlEventTouchUpInside];
    directionCheckBox.selected = _isDirectionChecked;
    [self.productCategoryContentView addSubview:directionCheckBox];
    [directionCheckBox release];
    
    //接受穷游网穷游折扣产品
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(39-2+10, _productCategoryContentView.frame.size.height-5-35-1, 300, 35)];
    tipLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    tipLabel.text = @"我已阅读并同意";
    tipLabel.font = [UIFont systemFontOfSize:15];
    tipLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    tipLabel.backgroundColor = [UIColor clearColor];
    [self.productCategoryContentView addSubview:tipLabel];
    [tipLabel release];
    
    //预订说明
    UIButton *directionButton = [[UIButton alloc] initWithFrame:CGRectMake(141-2+10, _productCategoryContentView.frame.size.height-5-35-1, 120, 35)];
    directionButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [directionButton setTitle:@"《穷游预订条款》" forState:UIControlStateNormal];
    [directionButton setTitleColor:[UIColor colorWithRed:13.0/255.0f green:113.0/255.0f blue:190.0/255.0f alpha:1.0] forState:UIControlStateNormal];
    directionButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    directionButton.backgroundColor = [UIColor clearColor];
    [directionButton addTarget:self action:@selector(directionButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.productCategoryContentView addSubview:directionButton];
    [directionButton release];

    

}

//个人联系信息
- (void)initBuyerInfoViewWithPadding:(CGFloat)aPadding
{
    _buyerInfoContentView = [[UIView alloc] initWithFrame:CGRectMake(0, aPadding, 320, 177)];
    //    _buyerInfoContentView.backgroundColor = [UIColor redColor];
    [_mainContentView addSubview:_buyerInfoContentView];
    
    //背景图
    UIImageView *buyerInfoBgImgView = [[UIImageView alloc] initWithFrame:_buyerInfoContentView.bounds];
    buyerInfoBgImgView.image = [UIImage imageNamed:@"x_personInfo_Bg.png"];
    [_buyerInfoContentView addSubview:buyerInfoBgImgView];
    [buyerInfoBgImgView release];
    
    
    //个人联系信息
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 14, 200, 19)];
    titleLabel.text = @"个人联系信息";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:17];
    [_buyerInfoContentView addSubview:titleLabel];
    [titleLabel release];
    
    
    //姓名
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(39, 42+1+1, 57, 42)];
    nameLabel.text = @"姓名";
    nameLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    nameLabel.font = [UIFont systemFontOfSize:15.0f];
    [_buyerInfoContentView addSubview:nameLabel];
    [nameLabel release];
    
    //请填写您的真实姓名
    _nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(118, 42+1+1, 187, 42)];
    _nameTextField.placeholder = @"请填写您的真实姓名";
    _nameTextField.font = [UIFont systemFontOfSize:15];
    _nameTextField.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    _nameTextField.backgroundColor = [UIColor clearColor];
    _nameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _nameTextField.keyboardType = UIKeyboardTypeNamePhonePad;
    [_buyerInfoContentView addSubview:_nameTextField];
    
    
    //电话
    UILabel *phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(39, 42+1+42+1+2, 57, 42)];
    phoneLabel.text = @"电话";
    phoneLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    phoneLabel.font = [UIFont systemFontOfSize:15.0f];
    [_buyerInfoContentView addSubview:phoneLabel];
    [phoneLabel release];
    
    //请填写您的手机号码
    _phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(118, 42+1+42+1+2, 187, 42)];
    _phoneTextField.placeholder = @"请填写您的手机号码";
    _phoneTextField.font = [UIFont systemFontOfSize:15];
    _phoneTextField.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    _phoneTextField.backgroundColor = [UIColor clearColor];
    _phoneTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _phoneTextField.keyboardType = UIKeyboardTypePhonePad;
    [_buyerInfoContentView addSubview:_phoneTextField];

    
    //邮箱
    UILabel *emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(39, 42+1+42+1+42+1+2, 57, 42)];
    emailLabel.text = @"邮箱";
    emailLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    emailLabel.font = [UIFont systemFontOfSize:15.0f];
    [_buyerInfoContentView addSubview:emailLabel];
    [emailLabel release];
    
    //请填写您的电子邮箱
    _emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(118, 42+1+42+1+42+1+2, 187, 42)];
    _emailTextField.placeholder = @"请填写您的电子邮箱";
    _emailTextField.font = [UIFont systemFontOfSize:15];
    _emailTextField.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    _emailTextField.backgroundColor = [UIColor clearColor];
    _emailTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _emailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _emailTextField.keyboardType = UIKeyboardTypeEmailAddress;

    [_buyerInfoContentView addSubview:_emailTextField];
    
//    //填充默认联系人信息
//    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
//    _nameTextField.text = [settings objectForKey:Settings_Buyer_Name];
//    _phoneTextField.text = [settings objectForKey:Settings_Buyer_Phone];
//    _emailTextField.text = [settings objectForKey:Settings_Buyer_Email];
    
    
}

//config header view
- (void)drawHeaderView
{
    //header
    UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 74)];
    headerImageView.image = [UIImage imageNamed:@"x_fillOrderHeader_bg.png"];
    [_mainContentView addSubview:headerImageView];
    
    //折扣图片
    _zhekouImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 75, 50)];
    [_zhekouImageView setImage:[UIImage imageNamed:@"x_lastminute_default75x50.png"]];
    _zhekouImageView.backgroundColor = [UIColor blueColor];
    [headerImageView addSubview:_zhekouImageView];
    
    //折扣 title 上海往返沙巴+香港5天4晚自...
    _zhekouTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(93, 9, 227, 36)];//CGRectMake(93, 16, 227, 18)
//    _zhekouTitleLabel.text = @"上海往返沙巴+香港5天4晚自游行";
    _zhekouTitleLabel.numberOfLines = 0;
    _zhekouTitleLabel.font = [UIFont systemFontOfSize:14.0];
    _zhekouTitleLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    _zhekouTitleLabel.backgroundColor = [UIColor clearColor];
    [headerImageView addSubview:_zhekouTitleLabel];
    
    //折扣 PrefixLabel
    _zhekouPrefixLabel = [[UILabel alloc] initWithFrame:CGRectMake(93, 46+2, 33, 14)];
    _zhekouPrefixLabel.text = @"";
    _zhekouPrefixLabel.textColor = [UIColor colorWithRed:100.0/255.0f green:100.0/255.0f blue:100.0/255.0f alpha:1.0f];
    _zhekouPrefixLabel.font = [UIFont systemFontOfSize:12];
    _zhekouPrefixLabel.backgroundColor = [UIColor clearColor];
    [headerImageView addSubview:_zhekouPrefixLabel];
    
    //折扣 1818
    _zhekouPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(93, 39+2, 200, 23)];
    _zhekouPriceLabel.text = @"";
    _zhekouPriceLabel.textColor = Color_Orange;//[UIColor colorWithRed:242.0f/255.0f green:100.0/255.0f blue:38.0/255.0f alpha:1.0f];
    _zhekouPriceLabel.font = [UIFont boldSystemFontOfSize:21];
    _zhekouPriceLabel.backgroundColor = [UIColor clearColor];
    [headerImageView addSubview:_zhekouPriceLabel];
    
    //折扣 元起
    _zhekouPriceUnitLabel = [[UILabel alloc] initWithFrame:CGRectMake(_zhekouPriceLabel.frame.origin.x+_zhekouPriceLabel.frame.size.width, 46+2, 33, 14)];
    _zhekouPriceUnitLabel.text = @"";
    _zhekouPriceUnitLabel.textColor = [UIColor colorWithRed:100.0/255.0f green:100.0/255.0f blue:100.0/255.0f alpha:1.0f];
    _zhekouPriceUnitLabel.font = [UIFont systemFontOfSize:12];
    _zhekouPriceUnitLabel.backgroundColor = [UIColor clearColor];
    [headerImageView addSubview:_zhekouPriceUnitLabel];
    
    
    [headerImageView release];

}


//config bottom view
- (void)drawBottomView
{
    
    //bottom bg
    UIImageView *bottomBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-64, 320, 64)];
    bottomBgImageView.image = [UIImage imageNamed:@"x_bg_detail_bottom.png"];
    bottomBgImageView.userInteractionEnabled = YES;
    [self.view addSubview:bottomBgImageView];
    
    
    //bottom 总额
    UILabel *zongeWordLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 33, 28, 14)];
    zongeWordLabel.text = @"总额";
    zongeWordLabel.textColor = [UIColor colorWithRed:100.0/255.0f green:100.0/255.0f blue:100.0/255.0f alpha:1.0f];
    zongeWordLabel.backgroundColor = [UIColor clearColor];
    zongeWordLabel.font = [UIFont systemFontOfSize:12.0f];
    [bottomBgImageView addSubview:zongeWordLabel];
    [zongeWordLabel release];
    
    //bottom 1818
    _zongeLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 26, 16, 23)];
    _zongeLabel.text = @"0";
    _zongeLabel.textColor = Color_Orange;//[UIColor colorWithRed:242.0/255.0f green:100.0/255.0f blue:38.0/255.0f alpha:1.0];
    _zongeLabel.textAlignment = NSTextAlignmentCenter;
    _zongeLabel.backgroundColor = [UIColor clearColor];
    _zongeLabel.font = [UIFont boldSystemFontOfSize:21];
    [bottomBgImageView addSubview:_zongeLabel];
    
    //bottom 元
    _zongeUnitLabel = [[UILabel alloc] initWithFrame:CGRectMake(_zongeLabel.frame.origin.x+_zongeLabel.frame.size.width, 33, 28, 14)];
    _zongeUnitLabel.text = @"元";
    _zongeUnitLabel.textColor = [UIColor colorWithRed:100.0/255.0f green:100.0/255.0f blue:100.0/255.0f alpha:1.0f];
    _zongeUnitLabel.backgroundColor = [UIColor clearColor];
    _zongeUnitLabel.font = [UIFont systemFontOfSize:12.0f];
    [bottomBgImageView addSubview:_zongeUnitLabel];
    
    //提交订单 button
    UIButton *commitButton = [[UIButton alloc] initWithFrame:CGRectMake(176, 17, 134, 33)];
    [commitButton setTitle:@"提交订单" forState:UIControlStateNormal];
    commitButton.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    [commitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [commitButton setBackgroundImage:Image_MyOrder_Orange forState:UIControlStateNormal];
    [commitButton setBackgroundImage:Image_MyOrder_Orange_Highlighted forState:UIControlStateHighlighted];
    [commitButton addTarget:self action:@selector(commitButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [bottomBgImageView addSubview:commitButton];
    
    
    [bottomBgImageView release];
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    
}

//请求折扣预订信息
- (void)requestForOrderInfo{
    
    [self.view makeToastActivity];
    [LastMinuteOrderInfo getLastMinuteOrderInfoWithId:_lastMinuteId
                                              success:^(NSArray *data) {
                                                  
                                                  [self.view hideToastActivity];
                                                  
                                                  if([data isKindOfClass:[NSArray class]] && [data count] > 0)
                                                  {
                                                      
                                                      self.orderInfo = [data objectAtIndex:0];
                                                      //刷新数据
                                                      [self reloadData];
                                                      
                                                      //                                                      [self reloadData];
                                                      
//                                                      [_functionFillOrderView refreshDataWithOrderInfo:self.orderInfo];
                                                      
                                                  }
                                                  
                                              } failure:^(NSError *error){
                                                  
                                                 [self.view hideToastActivity];
                                                  
                                                  MBProgressHUD *hud;
                                                  hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                                                  hud.mode = MBProgressHUDModeText;
                                                  hud.labelText = [error localizedDescription];
                                                  hud.yOffset -= 35;
                                                  dispatch_time_t popTime;
                                                  popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (TOAST_DURATION_NEW * NSEC_PER_SEC));
                                                  dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                                      [MBProgressHUD hideHUDForView:self.view animated:YES];
                                                      [self clickBackButton:nil];
                                                      //                                                      [self dismissViewControllerAnimated:YES completion:NULL];
                                                  });
                                                  
//                                                  [self.view hideToast];
//                                                  [self.view makeToast:[error localizedDescription] duration:TOAST_DURATION_NEW position:@"center" isShadow:NO];//Toast_Post_Order_Fail
                                                  //                                                  NSLog(@"---------fill order:'%@'", [error localizedDescription]);

                                                  
                                              }];
    
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithRed:240.0 / 255.0 green:240.0 / 255.0 blue:240.0 / 255.0 alpha:1.0];
    
    _titleLabel.text = @"提交订单";
    
    //mainScrollView
    _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _headView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-_headView.frame.size.height)];
    _mainScrollView.backgroundColor = [UIColor  clearColor];
    [self.view addSubview:_mainScrollView];
    
    //mainContentView
    _mainContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _mainScrollView.frame.size.width, 700)];
    _mainContentView.backgroundColor = [UIColor clearColor];
    [_mainScrollView addSubview:_mainContentView];
    
    
    //点击空白处，隐藏TextView
    UITapGestureRecognizer *scrollViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTap:)];
    [_mainScrollView addGestureRecognizer:scrollViewTap];
    [scrollViewTap release];
    
    
    //config header view
    [self drawHeaderView];
    
    //产品类型
    [self initProductCategoryViewWithPadding:74+10];
    
    //个人联系信息
    [self initBuyerInfoViewWithPadding:_productCategoryContentView.frame.origin.y+_productCategoryContentView.frame.size.height+10];
    
    //调整全局view的尺寸
    _mainContentView.frame = CGRectMake(_mainContentView.frame.origin.x, _mainContentView.frame.origin.y, _mainContentView.frame.size.width, _buyerInfoContentView.frame.origin.y+_buyerInfoContentView.frame.size.height+74);
    _mainScrollView.contentSize = _mainContentView.frame.size;
    
    //config bottom view
    [self drawBottomView];
    
    //设置总价
    [self calculateTotalPrice];
    
    
   //--------------------------------------------------------------------------------------------
    
    
    
    
    
    
    
    
    //请求折扣预订信息
    [self requestForOrderInfo];
    
    //UIKeyboardWillShowNotification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //UIKeyboardWillHideNotification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //清除当前联系人信息
//    [QYCommonUtil clearCurrPersonInfo];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Keyboard notification
-(void)keyboardWillShow:(NSNotification *)aNotification
{
    [self setMainScrollViewFrameWithKeyboardNotification:aNotification];
    
}

-(void)keyboardWillHide:(NSNotification *)aNotification
{
    //调整mainScrollView的尺寸
    CGRect frame = _mainScrollView.frame;
    frame.size.height = self.view.frame.size.height-_headView.frame.size.height;
    _mainScrollView.frame = frame;
    
}

//根据键盘的高度重新设置TextView的高度
- (void)setMainScrollViewFrameWithKeyboardNotification:(NSNotification*)aNotification
{
    NSDictionary *info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    float keyboardHeight = kbSize.height;
    
    //调整mainScrollView的尺寸
    CGRect frame = _mainScrollView.frame;
    frame.size.height = self.view.frame.size.height - frame.origin.y - keyboardHeight + 60;
    _mainScrollView.frame = frame;
    
    //将scrollView滚动到底部
    [UIView animateWithDuration:0.2 animations:^{
        CGFloat pointY = _mainContentView.frame.size.height-_mainScrollView.frame.size.height;
        [_mainScrollView setContentOffset:CGPointMake(0, pointY)];
    } completion:^(BOOL finished) {
        
    }];
    
}

#pragma mark - tap gesture
- (void)scrollViewTap:(UITapGestureRecognizer*)aRecognizer
{
    NSLog(@"-----------tap");
    
    [_nameTextField resignFirstResponder];
    [_phoneTextField resignFirstResponder];
    [_emailTextField resignFirstResponder];

}

#pragma mark - button click
//点击“请选择出发日期”
- (void)startDateButtonClickAction:(id)sender
{
    NSLog(@"---------------click start date");
    
    StartDateViewController *startDateViewController = [[StartDateViewController alloc] init];
    startDateViewController.delegate = self;
    startDateViewController.produectId = [self.selectedProduct.productId intValue];
    [self.navigationController pushViewController:startDateViewController animated:YES];
    [startDateViewController release];

}

- (void)commitButtonClickAction:(id)sender
{
    NSLog(@"------------commit--------");
    
    //如果还未选择套餐，则提示选择
    if (!self.selectedProduct) {
        [self.view hideToast];
        [self.view makeToast:Toast_Select_Product_First duration:TOAST_DURATION_NEW position:@"center" isShadow:NO];
        return;
        
    }else if (_selectedProduct.currentBuyCount<=0){//如果还未选择你需要购买套餐的数量，则提示选择
        [self.view hideToast];
        [self.view makeToast:Toast_Select_Product_Num duration:TOAST_DURATION_NEW position:@"center" isShadow:NO];
        return;
        
    }

    //确认接受预定说明
    if (!_isDirectionChecked) {
        [self.view hideToast];
        [self.view makeToast:Toast_Direction_Confirm duration:TOAST_DURATION_NEW position:@"center" isShadow:NO];
        
        return;
    }
    
    //姓名、邮箱、电话去除首尾空格---------------------------------------------------------------------------------------------
    NSString *currUserName = [_nameTextField.text trimHeadAndTailSpace];
    NSString *currUserPhone = [_phoneTextField.text trimHeadAndTailSpace];
    NSString *currUserEmail = [_emailTextField.text trimHeadAndTailSpace];
    
    if (![self checkPersonInfoWithName:currUserName phone:currUserPhone email:currUserEmail]) {
        return;
    }
    
    //检查是否需要选择“出发日期”
    if ([_selectedProduct.productCid intValue]==0&&!self.selectedDateCategory) {
        [self.view hideToast];
        [self.view makeToast:Toast_Select_Start_Date duration:TOAST_DURATION_NEW position:@"center" isShadow:NO];
        
        return;
    }
    
//    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
//    if ([[settings objectForKey:Settings_Buyer_Name] length]==0||[[settings objectForKey:Settings_Buyer_Phone] length]==0||[[settings objectForKey:Settings_Buyer_Email] length]==0) {
//        //存储默认联系人信息
//        [settings setObject:currUserName forKey:Settings_Buyer_Name];
//        [settings setObject:currUserPhone forKey:Settings_Buyer_Phone];
//        [settings setObject:currUserEmail forKey:Settings_Buyer_Email];
//    }
    
    //存储当前联系人信息
//    [settings setObject:currUserName forKey:Settings_Buyer_Curr_Name];
//    [settings setObject:currUserPhone forKey:Settings_Buyer_Curr_Phone];
//    [settings setObject:currUserEmail forKey:Settings_Buyer_Curr_Email];
//    [settings synchronize];
    
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
//    [params setObject:[NSString stringWithFormat:@"%d", [_selectedProduct.productId intValue]] forKey:@"pid"];
    NSInteger cid = [_selectedProduct.productCid intValue]==0?[self.selectedDateCategory.categoryId intValue]:[_selectedProduct.productCid intValue];
    
    NSLog(@"--------------cid:%d", cid);
    [params setObject:[NSString stringWithFormat:@"%d", cid] forKey:@"cid"];//[_selectedProduct.productCid intValue]
    [params setObject:[NSString stringWithFormat:@"%d", _selectedProduct.currentBuyCount] forKey:@"num"];
    [params setObject:currUserName forKey:@"name"];
    [params setObject:currUserPhone forKey:@"phone"];
    [params setObject:currUserEmail forKey:@"email"];
    //总价
//    CGFloat totalPrice = _selectedProduct.currentBuyCount*[self.selectedProduct.productPrice floatValue];
    CGFloat totalPrice = _selectedProduct.currentBuyCount*_currPrice;
    [params setObject:[NSString stringWithFormat:@"%.2f", totalPrice] forKey:@"price"];//
    
    //提交订单信息
    [self.view makeToastActivity];
    [[QYAPIClient sharedAPIClient] lastMinutePostOrderWithParams:params
                                                         success:^(NSDictionary *dic) {
                                                             [self.view hideToastActivity];
                                                             
                                                             if (dic) {
//                                                                 NSDictionary *dictionary = (NSDictionary *)[[QYAPIClient sharedAPIClient] responseJSON:data];
                                                                 NSDictionary *dataDic = [dic objectForKey:@"data"];
                                                                 NSInteger orderId = [[dataDic objectForKey:@"id"] intValue];
                                                                 NSLog(@"------orderId:%d", orderId);
                                                                 
                                                                 //显示确认订单2界面
                                                                 [self showConfirmOrderSecondViewControllerWith:orderId];
                                                                 
                                                             }else{
                                                                 [self.view hideToast];
                                                                 [self.view makeToast:Toast_Post_Order_Fail duration:TOAST_DURATION_NEW position:@"center" isShadow:NO];
                                                                 
                                                             }
                                                             
                                                         }
                                                         failure:^(NSError *error) {
                                                             [self.view hideToastActivity];
                                                             
                                                             //1_5订单确认失败（内详）
                                                             [MobClick event:@"orderconfirmfailed" label:[error localizedDescription]];                                                             
                                                             
                                                             //检测网络
                                                             if([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
                                                             {
//                                                                 MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//                                                                 hud.mode = MBProgressHUDModeText;
//                                                                 hud.labelText = @"请检查网络连接";
//                                                                 hud.yOffset -= 35;
//                                                                 dispatch_time_t popTime;
//                                                                 popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (TOAST_DURATION * NSEC_PER_SEC));
//                                                                 dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//                                                                     [MBProgressHUD hideHUDForView:self.view animated:YES];
//                                                                 });
                                                                 
                                                                 [self.view hideToast];
                                                                 [self.view makeToast:@"请检查网络连接" duration:TOAST_DURATION_NEW position:@"center" isShadow:NO];
                                                                 
                                                                 return;
                                                             }
                                                             
                                                             [self.view hideToast];
                                                             [self.view makeToast:[error localizedDescription] duration:TOAST_DURATION_NEW position:@"center" isShadow:NO];//Toast_Post_Order_Fail
                                                             
                                                         }];
    

}

//显示确认订单2界面
- (void)showConfirmOrderSecondViewControllerWith:(NSInteger)anOrderId
{
    //    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, 0.0);
    //    CGContextRef contentRef = UIGraphicsGetCurrentContext();
    //    [self.view.layer renderInContext:contentRef];
    //    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    //    UIGraphicsEndImageContext();
    //
    //    ConfirmOrderSecondViewController *confirmOrderSecondViewController = [[ConfirmOrderSecondViewController alloc] init];
    //    confirmOrderSecondViewController.orderId = anOrderId;
    //    confirmOrderSecondViewController.orderInfo = self.orderInfo;
    //    [confirmOrderSecondViewController setPopImage:image];
    //    [self.navigationController pushViewController:confirmOrderSecondViewController animated:YES];
    //    [confirmOrderSecondViewController release];
        
    ConfirmOrderSecondViewController *confirmOrderSecondViewController = [[ConfirmOrderSecondViewController alloc] init];
    confirmOrderSecondViewController.homeFillOrderViewController = self;
    confirmOrderSecondViewController.orderId = anOrderId;
    confirmOrderSecondViewController.orderInfo = self.orderInfo;
    //    [self.navigationController pushViewController:confirmOrderSecondViewController animated:YES];
    [self presentViewController:confirmOrderSecondViewController animated:YES completion:^{
        [confirmOrderSecondViewController release];
    }];
    
    
}

- (BOOL)checkPersonInfoWithName:(NSString*)aName phone:(NSString*)aPhone email:(NSString*)aEmail
{
    if ([aName length]==0) {//验证姓名不为空
        
        [self.view hideToast];
        [self.view makeToast:Toast_Complete_PersonInfo_Name duration:TOAST_DURATION_NEW position:@"center" isShadow:NO];
        
        [_nameTextField becomeFirstResponder];
        
        return NO;
        
    }else if([aPhone length]==0){//验证电话不为空
        [self.view hideToast];
        [self.view makeToast:Toast_Complete_PersonInfo_Phone duration:TOAST_DURATION_NEW position:@"center" isShadow:NO];
        
        [_phoneTextField becomeFirstResponder];
        
        return NO;
        
    }else if ([aEmail length]==0){//验证邮箱不为空
        
        [self.view hideToast];
        [self.view makeToast:Toast_Complete_PersonInfo_Email duration:TOAST_DURATION_NEW position:@"center" isShadow:NO];
        
        [_emailTextField becomeFirstResponder];
        
        return NO;
        
    }
    
    if (![QYCommonUtil checkPhone:aPhone]){//验证手机号格式
        [self.view hideToast];
        [self.view makeToast:Toast_Complete_PersonInfo_Phone_Correct duration:TOAST_DURATION_NEW position:@"center" isShadow:NO];//@"手机号码格式不正确，目前只支持国内手机号预订"
        
        [_phoneTextField becomeFirstResponder];
        
        return NO;
    }else if (![QYCommonUtil checkEmail:aEmail]){//验证邮箱格式
        [self.view hideToast];
        [self.view makeToast:Toast_Complete_PersonInfo_Email_Correct duration:TOAST_DURATION_NEW position:@"center" isShadow:NO];//@"邮箱格式不正确"
        
        [_emailTextField becomeFirstResponder];
        
        return NO;
        
    }
    
    return YES;
}

//预订说明
- (void)directionButtonClickAction:(id)sender
{
    NSLog(@"------------click 预订说明");
    
    WebViewController *webVC = [[[WebViewController alloc] init] autorelease];
    webVC.titleString = @"预订说明";
    webVC.loadingURL = kDirection_Url;
//    webVC.label_title.text = @"预订说明";
//    webVC.startURL = kDirection_Url;
    //        [self.homeViewController.navigationController pushViewController:webVC animated:YES];//old by jessie
    [self presentViewController:webVC animated:YES completion:^{
        
    }];
    
}

//checkbox 勾选框
- (void)directionCheckBoxClickAction:(id)sender
{
    //修改选择框的状态
    UIButton *checkBox = sender;
    checkBox.selected = !checkBox.selected;
    
    //记录是否选择穷游条款
    _isDirectionChecked = checkBox.selected;
    
}

#pragma mark - button click
//- button
- (void)minusNumButtonClickAction:(id)sender
{
    _selectedProduct.currentBuyCount--;
    [self setNumberUI];
    
    
}

//+ button
- (void)addNumButtonClickAction:(id)sender
{
    //如果还未选择套餐，则提示选择
    if (!self.selectedProduct) {
        [self.view hideToast];
        [self.view makeToast:Toast_Select_Product_First duration:TOAST_DURATION_NEW position:@"center" isShadow:NO];
        return;
        
    }
    
    //+ button
//    NSInteger buyLimit = [self.selectedProduct.productBuyLimit intValue];
    NSInteger buyLimit = [self.selectedProduct.productCid intValue]==0?[self.selectedDateCategory.categoryBuyLimit intValue]:[self.selectedProduct.productBuyLimit intValue];
    
    //判断购买限制
    if (buyLimit>0){
        if (_selectedProduct.currentBuyCount>=buyLimit) {
            NSString *toast = [NSString stringWithFormat:@"您选择的商品数量超出了购买限制，此产品每人限购%d个", buyLimit];//[NSString stringWithFormat:@"当前套餐每用户限购%d个", buyLimit];
            
            [self.view hideToast];
            [self.view makeToast:toast duration:TOAST_DURATION_NEW position:@"center" isShadow:NO];
            return;
            
        }
    }
    
    _selectedProduct.currentBuyCount++;
    [self setNumberUI];
    
}

//计数
- (void)setNumberUI
{
    _buyCountLabel.text = _buyCountLabel.text = [NSString stringWithFormat:@"%d", _selectedProduct.currentBuyCount];
    
    //判断+、- button的状态
    [self checkNumberButtonStatus];
    [self calculateTotalPrice];//计算总价
    
}

- (void)checkNumberButtonStatus
{
    //- button 默认1个
    _minusNumButton.enabled = _selectedProduct.currentBuyCount<=kDefaultBuyCount?NO:YES;
    
    //+ button 判断库存
    _addNumButton.enabled = _selectedProduct.currentBuyCount>=_currStock?NO:YES;//_selectedProduct.currentBuyCount>=[_selectedProduct.productStock intValue]?NO:YES;
    
}

//计算总价
- (void)calculateTotalPrice
{
//    CGFloat totalPrice = [_selectedProduct.productPrice floatValue]*_selectedProduct.currentBuyCount;
    CGFloat totalPrice = _currPrice*_selectedProduct.currentBuyCount;
    _zongeLabel.text = totalPrice==0?@"0":[NSString stringWithFormat:@"%.2f", totalPrice];
    [self adjustFrameOfZongeLabel];
}

//调整总额label和单位label的frame
- (void)adjustFrameOfZongeLabel
{
    
    CGSize size = [_zongeLabel.text sizeWithFont:_zongeLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, _zongeLabel.frame.size.height) lineBreakMode:_zongeLabel.lineBreakMode];
    
    CGFloat padding = 2;
    CGRect frame = _zongeLabel.frame;
    frame.size.width = size.width + padding;
    _zongeLabel.frame = frame;
    
    frame = _zongeUnitLabel.frame;
    frame.origin.x = _zongeLabel.frame.origin.x+_zongeLabel.frame.size.width;
    _zongeUnitLabel.frame = frame;
    
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [_orderInfo.orderInfoProductsArray count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FunctionFillOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FunctionFillOrderCellIdentifier"];
    if (cell == nil) {
        cell = [[[FunctionFillOrderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FunctionFillOrderCellIdentifier"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.delegate = self;
    
    LastMinuteProduct *product = [_orderInfo.orderInfoProductsArray objectAtIndex:indexPath.row];
    cell.product = product;
    
    if (indexPath.row==0&&!self.selectedCell) {//默认选中第一个cell
        self.selectedCell = cell;
    }
    
    return cell;
    
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LastMinuteProduct *product = [_orderInfo.orderInfoProductsArray objectAtIndex:indexPath.row];
    
    return [FunctionFillOrderCell heightForCellWithProduct:product];
}


#pragma mark - FunctionFillOrderCellDelegate
- (void)FunctionFillOrderCellContentBgButtonClick:(id)sender cell:(FunctionFillOrderCell*)aCell
{
    
    UIButton *checkBox = sender;
    if (checkBox.selected) {//self.selectedProduct == aCell.product      如果已选中该套餐，则不进行任何操作
        return;
    }
    
    //取消之前选择 old
    self.selectedProduct.isSelected = NO;
    //    self.selectedCell.contentBgButton.selected = NO;
    //改变选中样式
    [self.selectedCell setColorOfContentWithSelected:NO];//
    //    self.selectedCell.product = self.selectedProduct;
    
    //修改为当前选择 new
    self.selectedProduct = aCell.product;
    self.selectedCell = aCell;
    self.selectedProduct.isSelected = YES;
    //修改选择框的状态
    //    checkBox.selected = !checkBox.selected;
    //改变选中样式
    [aCell setColorOfContentWithSelected:!checkBox.selected];
    
    //清零
    _selectedProduct.currentBuyCount = kDefaultBuyCount;
    //修改当前剩余库存显示
    [self resetStockLabel];
    [self setNumberUI];
    
    //判断是否显示出发日期UI
    BOOL isShow = [self.selectedProduct.productCid intValue]==0?YES:NO;
    [self showStartDateUI:isShow];

    
    
    
    
}

//重置剩余库存数label
- (void)resetStockLabel
{
    _stockLabel.text = [self.selectedProduct.productCid intValue]==0?@"":[NSString stringWithFormat:@"剩余%d件", [self.selectedProduct.productStock intValue]];
    _currStock = [self.selectedProduct.productCid intValue]==0?0:[self.selectedProduct.productStock intValue];
    _currPrice = [self.selectedProduct.productCid intValue]==0?0:[self.selectedProduct.productPrice floatValue];
    
    _startDateTextField.text = @"";
    self.selectedDateCategory = nil;
    
}

//设置是否显示出发日期
- (void)showStartDateUI:(BOOL)isShow
{
    CGFloat padding = 0;
    if (isShow) {
        padding = _startDateContentView.hidden?50:0;
    }else{
        padding = _startDateContentView.hidden?0:-50;
    
    }
    
    NSLog(@"--------padding:%f", padding);
    
    _startDateContentView.hidden = !isShow;
    
    //调整产品类型模块尺寸
    CGRect frame = _productCategoryContentView.frame;
    frame.size.height = frame.size.height+padding;
    _productCategoryContentView.frame = frame;
    
    //调整个人联系信息模块位置
    [self adjustBuyerInfoView];
}

//刷新数据
- (void)reloadData
{
    
    //折扣图片
    [_zhekouImageView setImageWithURL:[NSURL URLWithString:self.orderInfo.orderInfoPicUrl] placeholderImage:[UIImage imageNamed:@"x_lastminute_default75x50.png"]];
    
    //折扣 title
    _zhekouTitleLabel.text = self.orderInfo.orderInfoTitle;
    
    
    //填充默认联系人信息
    _nameTextField.text = self.orderInfo.orderInfoBuyerInfoName;
    _phoneTextField.text = self.orderInfo.orderInfoBuyerInfoPhone;
    _emailTextField.text = self.orderInfo.orderInfoBuyerInfoEmail;
    
    //总价 1818
    //    NSLog(@"--------------orderInfoPrice:%@", anOrderInfo.orderInfoPrice);
    //    _zhekouPriceLabel.text = anOrderInfo.orderInfoPrice;
    //    _zhekouPriceUnitLabel.hidden = YES;
    
    
    [self fillLastminuteTotalPrice];
    
    if ([_orderInfo.orderInfoProductsArray count]>0) {
        //默认选中第一个套餐
        self.selectedProduct = [_orderInfo.orderInfoProductsArray objectAtIndex:0];
        
        //修改当前剩余库存显示
        [self resetStockLabel];
        [self setNumberUI];
    }
    
    //mainTableView
    [_productsTableView reloadData];
    
    //调整界面尺寸
    [self adjustTotalView];
    
    //判断是否显示出发日期UI
    BOOL isShow = [self.selectedProduct.productCid intValue]==0?YES:NO;
    [self showStartDateUI:isShow];//该方法必须放在adjustTotalView方法后面
}

//调整界面尺寸
- (void)adjustTotalView
{
    CGFloat tableViewHeight = [self calculateTableViewHeight];
    
    //调整productTableView
    CGRect frame = _productsTableView.frame;
    frame.size.height = tableViewHeight;
    _productsTableView.frame = frame;
    
    //调整产品类型模块尺寸
    frame = _productCategoryContentView.frame;
    frame.size.height = tableViewHeight + 239 + 4;
    _productCategoryContentView.frame = frame;
    
    //调整个人联系信息模块位置
    [self adjustBuyerInfoView];
    
    
}

- (void)adjustBuyerInfoView
{
    //调整个人联系信息模块位置
    CGRect frame = _buyerInfoContentView.frame;
    frame.origin.y = _productCategoryContentView.frame.origin.y + _productCategoryContentView.frame.size.height + 9;
    _buyerInfoContentView.frame = frame;
    
    //调整mainContentView尺寸
    frame = _mainContentView.frame;
    frame.size.height = _buyerInfoContentView.frame.origin.y+_buyerInfoContentView.frame.size.height+74;
    _mainContentView.frame = frame;
    
    //调整scrollView
    _mainScrollView.contentSize = _mainContentView.frame.size;
}

- (CGFloat)calculateTableViewHeight
{
    CGFloat height = 0;
    for (int i=0; i<[_orderInfo.orderInfoProductsArray count]; i++) {
        LastMinuteProduct *product = [_orderInfo.orderInfoProductsArray objectAtIndex:i];
        
        height += [FunctionFillOrderCell heightForCellWithProduct:product];
    }
    
    height += 15;//tableHeaderView 15px space
    
    
    return height;
}

//填充折扣总价
- (void)fillLastminuteTotalPrice
{
    
    //调整垂直高度-----------------------------------------------------------
    CGSize titleSize = [_zhekouTitleLabel.text sizeWithFont:_zhekouTitleLabel.font constrainedToSize:CGSizeMake(_zhekouTitleLabel.frame.size.width, MAXFLOAT) lineBreakMode:_zhekouTitleLabel.lineBreakMode];
    NSLog(@"----------titleSize:width:%f, height:%f", titleSize.width, titleSize.height);
    
    BOOL isNeedAdjust = titleSize.height>17?YES:NO;
    
    //调整折扣title
    if (isNeedAdjust) {
        
        //折扣 title 上海往返沙巴+香港5天4晚自...
        CGRect newFame = _zhekouTitleLabel.frame;
        newFame.origin.y += 2;
        _zhekouTitleLabel.frame = newFame;
        
        CGFloat yPadding = 4;
        
        newFame = _zhekouPrefixLabel.frame;
        newFame.origin.y += yPadding;
        _zhekouPrefixLabel.frame = newFame;
        
        newFame = _zhekouPriceLabel.frame;
        newFame.origin.y += yPadding;
        _zhekouPriceLabel.frame = newFame;
        
        newFame = _zhekouPriceUnitLabel.frame;
        newFame.origin.y += yPadding;
        _zhekouPriceUnitLabel.frame = newFame;
        
        
    }
    
    
    //调整水平高度-----------------------------------------------------------
    _zhekouPrefixLabel.text = @"";
    _zhekouPriceLabel.text = @"";
    _zhekouPriceUnitLabel.text = @"";
    
    NSString *priceStr = self.orderInfo.orderInfoPrice;
    NSArray *array = [priceStr componentsSeparatedByString:@"<em>"];
    
    if ([array count] > 1) {
        
        _zhekouPrefixLabel.text = (NSString *)[array objectAtIndex:0];
        
        CGFloat offsetX = 0;
        CGSize prefixSize = [_zhekouPrefixLabel.text sizeWithFont:_zhekouPrefixLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, _zhekouPrefixLabel.frame.size.height) lineBreakMode:_zhekouPrefixLabel.lineBreakMode];
        
        CGRect frame = _zhekouPrefixLabel.frame;
        frame.size.width = prefixSize.width;
        _zhekouPrefixLabel.frame = frame;
        offsetX += prefixSize.width + _zhekouPrefixLabel.frame.origin.x;
        
        NSArray *anotherArray = [(NSString *)[array objectAtIndex:1] componentsSeparatedByString:@"</em>"];
        _zhekouPriceLabel.text = [anotherArray objectAtIndex:0];
        
        CGSize priceSize = [_zhekouPriceLabel.text sizeWithFont:_zhekouPriceLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, _zhekouPriceLabel.frame.size.height) lineBreakMode:_zhekouPriceLabel.lineBreakMode];
        
        frame = _zhekouPriceLabel.frame;
        frame.origin.x = offsetX;
        frame.size.width = priceSize.width;
        _zhekouPriceLabel.frame = frame;
        offsetX += priceSize.width;
        
        if ([anotherArray count] > 1) {
            _zhekouPriceUnitLabel.text = [anotherArray objectAtIndex:1];
            CGSize suffixSize = [_zhekouPriceUnitLabel.text sizeWithFont:_zhekouPriceUnitLabel.font constrainedToSize:CGSizeMake(MAXFLOAT, _zhekouPriceUnitLabel.frame.size.height) lineBreakMode:_zhekouPriceUnitLabel.lineBreakMode];
            
            frame = _zhekouPriceUnitLabel.frame;
            frame.origin.x = offsetX;
            frame.size.width = suffixSize.width;
            _zhekouPriceUnitLabel.frame = frame;
        }
        
    }else{
        _zhekouPriceLabel.text = priceStr;
        
    }
    
    
    
}

#pragma mark - StartDateViewControllerDelegate
- (void)StartDateViewControllerCategoryButtonClickAction:(id)sender viewController:(StartDateViewController*)aViewController dateCategory:(QYDateCategory*)aDateCategory
{
    NSLog(@"--------click date:%d, cid:%d", [aDateCategory.categoryDate intValue], [aDateCategory.categoryId intValue]);
    
    self.selectedDateCategory = aDateCategory;//选择品类信息
    _startDateTextField.text = [NSString stringWithFormat:@"%d/%d/%d出发", [aDateCategory.categoryYear intValue], [aDateCategory.categoryMonth intValue], [aDateCategory.categoryDate intValue]];
    
    //清零
    _selectedProduct.currentBuyCount = kDefaultBuyCount;
    
    //剩余99999件
    _stockLabel.text = [NSString stringWithFormat:@"剩余%d件", [aDateCategory.categoryStock intValue]];
    _currStock = [aDateCategory.categoryStock intValue];
    _currPrice = [aDateCategory.categoryPrice floatValue];
    [self setNumberUI];
}


@end
