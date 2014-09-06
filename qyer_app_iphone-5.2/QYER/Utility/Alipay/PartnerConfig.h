//
//  PartnerConfig.h
//  AlipaySdkDemo
//
//  Created by ChaoGanYing on 13-5-3.
//  Copyright (c) 2013年 RenFei. All rights reserved.
//
//  提示：如何获取安全校验码和合作身份者id
//  1.用您的签约支付宝账号登录支付宝网站(www.alipay.com)
//  2.点击“商家服务”(https://b.alipay.com/order/myorder.htm)
//  3.点击“查询合作者身份(pid)”、“查询安全校验码(key)”
//

#ifndef MQPDemo_PartnerConfig_h
#define MQPDemo_PartnerConfig_h

//合作身份者id，以2088开头的16位纯数字
#define PartnerID @"2088111852312552"
//收款支付宝账号
#define SellerID  @"lmbd@qyer.com"

//安全校验码（MD5）密钥，以数字和字母组成的32位字符
#define MD5_KEY @""

//商户私钥，自助生成
#define PartnerPrivKey @"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBANmawLjXGa9KprKVe+6zKEjgk4dcnLABKcKixYKkatB8N6Yrtpw2W9F+rbTjhFFr2sbdtp24qA7a7zMkoIgCw4WUFGAsSeWIfZNzeyAUzD3OcGvx15zGV7zy5f+Cxm9b6HC0qD7HNV3/oMNwm3xknjvdDkWT12L31Pj9/PBUybr7AgMBAAECgYBz2KlFPm6UHcAFTwO9nm+R7M1dwPZB1TywPAu+c13SRG8z7g23uFDFhRVhOcbVuf+s45g2+3ms/u1dYuB7yEziMsOxXG0LoKhNh/nOL4h/NGg23WZpqhmL1lDat2DZOSdfJ9FktRjl1LvwZaHqYJec5RPudh0GLwnQ0cfb0O8M4QJBAPhTvaq8Bo02o/Cn7/0iOyLCfMIV9TBVVfXzAxWMaDGIwWs6xJeN9WZgWNUJeyuzAANIgH5jxt84vv1j+J9oQJkCQQDgU/9DkLevVgjSpT1+yvbhVZkXzEk1krazt6YQfF4r+Ay9v/l8Sb91+bDYCt2PIf0kAXhKchiYg88V4rI7kxCzAkEA4AgEg+TP8FRMQM/xhih8u1ZE4YCXzHwgahxMOwOJ+K5M+SVyuNvcefkQC1pbYchCibO+IMh5YWc7fzTS11VheQJAQkgPUENeQqxFBxhTxzbpI0NLbMCrkOy8lvVYV96nZI5yFU63xIV10MHqAquTM0tzpEPa6wQzSD0J3wmQaBHYCQJAC9f5p7swkDOBBmv3A0sWxP1cBlo6xLjsdkd7TuX8I9hAu3N5awOCJrCLjr3LAt1SMU/W4fxENqKAD2lesrpqow=="


//支付宝公钥
#define AlipayPubKey   @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCnxj/9qwVfgoUh/y2W89L6BkRAFljhNhgPdyPuBV64bfQNN1PjbCzkIM6qRdKBoLPXmKKMiFYnkd6rAoprih3/PrQEB/VsW8OoM8fxn67UDYuyBTqA23MML9q1+ilIZwBC2AQ2UBVOrFXfFl75p6/B5KsiNG9zpgmLCUYuLkxpLQIDAQAB"

#endif
