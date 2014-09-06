//
//  EditBuyerInfoViewController.m
//  LastMinute
//
//  Created by 蔡 小雨 on 14-2-14.
//
//

#import "EditBuyerInfoViewController.h"

//#import "ConfirmOrderFirstViewController.h"

#import "BuyerInfo.h"
#import "Toast+UIView.h"
#import "NSString+MD5.h"
#import "QYCommonUtil.h"
#import "QYCommonToast.h"



@interface EditBuyerInfoViewController ()

@property (nonatomic, retain) BuyerInfo        *buyerInfo;

@property (nonatomic, retain) UITextField      *nameTextField;
@property (nonatomic, retain) UITextField      *phoneTextField;
@property (nonatomic, retain) UITextField      *emailTextField;

@end

@implementation EditBuyerInfoViewController

-(void)dealloc
{
    
    QY_SAFE_RELEASE(_buyerInfo);
    
    QY_VIEW_RELEASE(_nameTextField);
    QY_VIEW_RELEASE(_phoneTextField);
    QY_VIEW_RELEASE(_emailTextField);
//    QY_SAFE_RELEASE(_fillOrderView);
//    QY_SAFE_RELEASE(_homeDetailViewController);
    [super dealloc];
}

#pragma mark - super
- (id)init
{
    self = [super init];
    if(self != nil)
    {
//        _panEnable = YES;//do it later
        
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithRed:240.0 / 255.0 green:240.0 / 255.0 blue:240.0 / 255.0 alpha:1.0];
    
    _titleLabel.text = @"确认购买人信息";
    
    //表格背景图
    UIImageView *contentBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, _headView.frame.size.height+10, 320, 136)];
    contentBgImageView.userInteractionEnabled = YES;
    [contentBgImageView setImage:[UIImage imageNamed:@"x_editBuyerInfo_bg.png"]];
    [self.view addSubview:contentBgImageView];
    
    //姓名 label
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 90, 44)];
    nameLabel.text = @"姓名";
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    [nameLabel setFont:[UIFont systemFontOfSize:15.0f]];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [contentBgImageView addSubview:nameLabel];
    [nameLabel release];
    
    //姓名 textField
    _nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(10+90+30, 0, 210-30, 44)];
    _nameTextField.placeholder = @"请填写您的真实姓名";
    _nameTextField.font = [UIFont systemFontOfSize:15.0f];
    _nameTextField.backgroundColor = [UIColor clearColor];
    _nameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _nameTextField.keyboardType = UIKeyboardTypeNamePhonePad;
    [contentBgImageView addSubview:_nameTextField];
    
    //电话 label
    UILabel *phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 44, 90, 44)];
    phoneLabel.text = @"电话";
    phoneLabel.backgroundColor = [UIColor clearColor];
    phoneLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    [phoneLabel setFont:[UIFont systemFontOfSize:15.0f]];
    phoneLabel.textAlignment = NSTextAlignmentCenter;
    [contentBgImageView addSubview:phoneLabel];
    [phoneLabel release];
    
    //电话 textField
    _phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(10+90+30, 44, 210-30, 44)];
    _phoneTextField.placeholder = @"请填写您的手机号码";
    _phoneTextField.font = [UIFont systemFontOfSize:15.0f];
    _phoneTextField.backgroundColor = [UIColor clearColor];
    _phoneTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _phoneTextField.keyboardType = UIKeyboardTypePhonePad;
    [contentBgImageView addSubview:_phoneTextField];
    
    //邮箱 label
    UILabel *emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 44*2, 90, 44)];
    emailLabel.text = @"邮箱";
    emailLabel.backgroundColor = [UIColor clearColor];
    emailLabel.textColor = [UIColor colorWithRed:68.0/255.0f green:68.0/255.0f blue:68.0/255.0f alpha:1.0f];
    [emailLabel setFont:[UIFont systemFontOfSize:15.0f]];
    emailLabel.textAlignment = NSTextAlignmentCenter;
    [contentBgImageView addSubview:emailLabel];
    [emailLabel release];
    
    //邮箱 textField
    _emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(10+90+30, 44*2, 210-30, 44)];
    _emailTextField.placeholder = @"请填写您的电子邮箱";
    _emailTextField.font = [UIFont systemFontOfSize:15.0f];
    _emailTextField.backgroundColor = [UIColor clearColor];
    _emailTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _emailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    [contentBgImageView addSubview:_emailTextField];
    
    //确定按钮
    UIButton *confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(93, contentBgImageView.frame.origin.y+contentBgImageView.frame.size.height+20, 134, 34)];
    [confirmButton setImage:[UIImage imageNamed:@"x_btn_comfirm.png"] forState:UIControlStateNormal];
    [confirmButton setImage:[UIImage imageNamed:@"x_btn_comfirm_highlighted.png"] forState:UIControlStateHighlighted];
    [confirmButton addTarget:self action:@selector(confirmButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confirmButton];
    [confirmButton release];
    
    [contentBgImageView release];
    
    
    
    
    
    
    //根据本机记录信息，预先填写表单
//    [self fillInFields];
}

////根据本机记录信息，预先填写表单
//- (void)fillInFields{
//    
//    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
//    
//    _nameTextField.text = [settings objectForKey:Settings_Buyer_Name];
//    _phoneTextField.text = [settings objectForKey:Settings_Buyer_Phone];
//    _emailTextField.text = [settings objectForKey:Settings_Buyer_Email];
//
//}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //根据本机记录信息，预先填写表单
//    [self fillInFields];
    
    //请求默认联系人信息
    [self requestForBuyerInfo];
}

//请求默认联系人信息
- (void)requestForBuyerInfo
{
    [self.view makeToastActivity];
    
    [BuyerInfo getBuyerInfoSuccess:^(NSArray *data) {
        
        [self.view hideToastActivity];
        
        if([data isKindOfClass:[NSArray class]] && [data count] > 0)
        {
            
            self.buyerInfo = [data objectAtIndex:0];
            //刷新数据
            [self reloadData];
        }

        
    } failure:^{
        
        [self.view hideToastActivity];
        
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - click
//确定按钮
- (void)confirmButtonClick:(id)sender
{
    //姓名、邮箱、电话去除首尾空格
    NSString *userName = [_nameTextField.text trimHeadAndTailSpace];
    NSString *userPhone = [_phoneTextField.text trimHeadAndTailSpace];
    NSString *userEmail = [_emailTextField.text trimHeadAndTailSpace];
    
    //检查姓名、手机号、邮箱是否为空
    if ([userName length]==0) {
        
        [self.view hideToast];
        [self.view makeToast:Toast_Complete_PersonInfo_Name duration:TOAST_DURATION_NEW position:@"center" isShadow:NO];//@"姓名不能为空"
        return;
        
    }else if([userPhone length]==0){
        
        [self.view hideToast];
        [self.view makeToast:Toast_Complete_PersonInfo_Phone duration:TOAST_DURATION_NEW position:@"center" isShadow:NO];//@"手机号不能为空"
        return;
        
    }else if ([userEmail length]==0){
        
        [self.view hideToast];
        [self.view makeToast:Toast_Complete_PersonInfo_Email duration:TOAST_DURATION_NEW position:@"center" isShadow:NO];//@"邮箱不能为空"
        return;
        
    }
    
    if (![QYCommonUtil checkPhone:userPhone]){//验证手机号格式
        [self.view hideToast];
        [self.view makeToast:Toast_Complete_PersonInfo_Phone_Correct duration:TOAST_DURATION_NEW position:@"center" isShadow:NO];//@"手机号码格式不正确，目前只支持国内手机号预订"
        return;
    }else if (![QYCommonUtil checkEmail:userEmail]){//验证邮箱格式
        [self.view hideToast];
        [self.view makeToast:Toast_Complete_PersonInfo_Email_Correct duration:TOAST_DURATION_NEW position:@"center" isShadow:NO];//@"邮箱格式不正确"
        return;
    
    }
    
//    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
//    [settings setObject:userName forKey:Settings_Buyer_Name];
//    [settings setObject:userPhone forKey:Settings_Buyer_Phone];
//    [settings setObject:userEmail forKey:Settings_Buyer_Email];
//    [settings synchronize];
    
    [self.view makeToastActivity];
    [BuyerInfo changeBuyerInfoWithName:userName phone:userPhone email:userEmail Success:^(NSDictionary *dic) {
        [self.view hideToastActivity];
        [self.view hideToast];
        [self.view makeToast:@"修改购买人信息成功" duration:TOAST_DURATION_NEW position:@"center" isShadow:NO];
        
        [self clickBackButton:nil];
        
    } failure:^ {
        [self.view hideToastActivity];
//        [self.view hideToast];
//        [self.view makeToast:[error localizedDescription] duration:TOAST_DURATION_NEW position:@"center" isShadow:NO];
        
    }];
    
//    if (self.fillOrderView) {
//        [self showConfirmOrderFirstViewControllerWithFillOrderView:self.fillOrderView];
//    }else{
//        [self clickBackButton:nil];
//    }

}

////显示确认订单界面
//- (void)showConfirmOrderFirstViewControllerWithFillOrderView:(FunctionFillOrderView*)aView
//{
//    UIGraphicsBeginImageContextWithOptions(self.view.frame.size, NO, 0.0);
//    CGContextRef contentRef = UIGraphicsGetCurrentContext();
//    [self.view.layer renderInContext:contentRef];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    ConfirmOrderFirstViewController *confirmOrderFirstViewController = [[ConfirmOrderFirstViewController alloc] init];
//    confirmOrderFirstViewController.orderInfo = aView.orderInfo;
//    confirmOrderFirstViewController.homeDetailViewController = self.homeDetailViewController;
//    confirmOrderFirstViewController.selectedProduct = aView.selectedProduct;//[aView.orderInfo.orderInfoProductsArray lastObject];//objectAtIndex:0];
//    [confirmOrderFirstViewController setPopImage:image];
//    [self.navigationController pushViewController:confirmOrderFirstViewController animated:YES];
//    [confirmOrderFirstViewController release];
//    
//}

//验证姓名：有值即可
- (BOOL)checkName:(NSString*)aContent
{
    return [aContent length]>0?YES:NO;
}

////验证电话：开头为1，共11位
//- (BOOL)checkPhone:(NSString*)aContent
//{
//    if ([aContent length]==11) {//11位
//        NSString *firstChar = [aContent substringToIndex:1];
//        return [firstChar isEqualToString:@"1"]?YES:NO;
//    }
//    return NO;
//}

////验证邮箱：邮箱正则
//- (BOOL)checkEmail:(NSString*)aContent
//{
//    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
//    NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
//    return [emailPredicate evaluateWithObject:aContent];
//
//}

//刷新数据
- (void)reloadData
{
    _nameTextField.text = self.buyerInfo.buyerInfoName;
    _phoneTextField.text = self.buyerInfo.buyerInfoPhone;
    _emailTextField.text = self.buyerInfo.buyerInfoEmail;

}

@end
