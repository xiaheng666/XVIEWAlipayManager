//
//  XVIEWAlipayManager.m
//  XVIEW2.0
//
//  Created by njxh on 16/11/28.
//  Copyright © 2016年 南京 夏恒. All rights reserved.
//

#import "XVIEWAlipayManager.h"
#import <UIKit/UIKit.h>
#import <AlipaySDK/AlipaySDK.h>
//#import "Order.h"
//#import "DataSigner.h"
@interface XVIEWAlipayManager ()
#pragma mark ==支付宝支付结果回调到支付界面==
@property (nonatomic, copy) void (^alipayCallbackBlock) (XVIEWSDKResonseStatusCode statusCode, NSDictionary *responseData);

@end
@implementation XVIEWAlipayManager

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}
+ (instancetype)shareAlipayManager {
    static XVIEWAlipayManager *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_instance) {
            _instance = [[XVIEWAlipayManager alloc] init];
        }
    });
    return _instance;
}
#pragma mark ==支付宝的回调==
- (void)XVIEWAlipaySDKCallbackUrl:(NSURL *)url {
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
        //【由于在跳转支付宝客户端支付的过程中，商户app在后台很可能被系统kill了，所以pay接口的callback就会失效，请商户对standbyCallback返回的回调结果进行处理,就是在这个方法里面处理跟callback一样的逻辑】
        //异常 ->【callback处理支付结果】
        [self alipayResult:resultDic];
    }];
}
#pragma mark == 字符串支付
- (void)XVIEWSDKAliPay:(NSString *)orderString appScheme:(NSString *)appScheme callback:(void (^)(XVIEWSDKResonseStatusCode statusCode, NSDictionary *responseData))callbackBlock {
    self.alipayCallbackBlock = callbackBlock;
    [self aliPay:orderString appScheme:appScheme];
}
#pragma mark ==跳转支付宝之后回调的支付结果==
- (void)alipayResult:(NSDictionary *)resultDict {
    //【callback处理支付结果】
    XVIEWSDKResonseStatusCode code;
    NSString *codeStr = @"";
    NSString *result = @"";
    NSString *message = @"";
    if ([resultDict[@"resultStatus"] isEqual:@"9000"]) {
        codeStr = @"0";
        code = XVIEWSDKCodeSuccess;
        result = @"订单支付成功";
        message = @"支付宝支付成功";
    }
    else if ([resultDict[@"resultStatus"] isEqual:@"8000"]) {
        codeStr = @"01";
        code = XVIEWSDKCodeInProcess;
        result = @"正在处理中，支付结果未知";
        message = @"正在处理中，支付结果未知（有可能已经支付成功），请查询商户订单列表中订单的支付状态";
    }
    else if ([resultDict[@"resultStatus"] isEqual:@"4000"]) {
        codeStr = @"-1";
        code = XVIEWSDKCodeFail;
        result = @"订单支付失败";
        message = @"支付宝支付失败";
    }
    else if ([resultDict[@"resultStatus"] isEqual:@"6001"]) {
        codeStr = @"-1";
        code = XVIEWSDKCodeCancel;
        result = @"用户中途取消";
        message = @"支付宝支付失败";
    }
    else if ([resultDict[@"resultStatus"] isEqual:@"6002"]) {
        codeStr = @"-1";
        code = XVIEWSDKCodeNetworkError;
        result = @"网络连接出错";
        message = @"支付宝支付失败";
    }
    else if ([resultDict[@"resultStatus"] isEqual:@"6004"]) {
        codeStr = @"01";
        code = XVIEWSDKCodeResultUnknown;
        result = @"支付结果未知";
        message = @"支付结果未知（有可能已经支付成功），请查询商户订单列表中订单的支付状态";
    }
    else {
        codeStr = @"-1";
        code = XVIEWSDKCodeOtherErro;
        result = @"其它支付错误";
        message = @"支付宝支付失败";
    }
    if (self.alipayCallbackBlock) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:resultDict];
        [dic setObject:result forKey:@"result"];
        [dic setObject:@"aliPay" forKey:@"type"];
        self.alipayCallbackBlock(code, @{@"code":codeStr, @"message":message, @"data":dic});
    }
}

/*
#pragma mark == 字典支付
- (void)XVIEWSDKAlipayParameters:(NSDictionary *)orderDict appScheme:(NSString *)appScheme callback:(void (^)(XVIEWSDKResonseStatusCode statusCode, NSDictionary *responseData))callbackBlock {
    self.alipayCallbackBlock = callbackBlock;
    [self aliPayParameters:orderDict appScheme:appScheme];
}
#pragma mark ==支付宝支付==
- (void)aliPayParameters:(NSDictionary *)parameters appScheme:(NSString *)appScheme {
    Order *myorder = [[Order alloc] init];
    myorder.service = parameters[@"service"];
    myorder.partner = parameters[@"partner"];
    myorder.inputCharset = parameters[@"_input_charset"];
    myorder.notifyURL = parameters[@"notify_url"];
    myorder.outTradeNO = parameters[@"out_trade_no"];
    myorder.subject = parameters[@"subject"];
    myorder.paymentType = parameters[@"payment_type"];
    myorder.sellerID = parameters[@"seller_id"];
    myorder.totalFee = parameters[@"total_fee"];
    myorder.body = parameters[@"body"];
    if ([parameters[@"rn_check"] isEqualToString:@""] || parameters[@"rn_check"] == nil) {
        myorder.rnCheck = parameters[@"rn_check"];
    }
    if ([parameters[@"it_b_pay"] isEqualToString:@""] || parameters[@"it_b_pay"] == nil) {
        myorder.itBPay = parameters[@"it_b_pay"];
    }
    if ([parameters[@"goods_type"] isEqualToString:@""] || parameters[@"goods_type"] == nil) {
        myorder.goodsType = parameters[@"goods_type"];
    }
    if ([parameters[@"app_id"] isEqualToString:@""] || parameters[@"app_id"] == nil) {
        myorder.appID = parameters[@"app_id"];
    }
    if ([parameters[@"appenv"] isEqualToString:@""] || parameters[@"appenv"] == nil) {
        myorder.appenv = parameters[@"appenv"];
    }
    if ([parameters[@"showURL"] isEqualToString:@""] || parameters[@"showURL"] == nil) {
        myorder.showURL = parameters[@"showURL"];
    }
    //将商品信息拼接成字符串
    NSString *orderSpec = [myorder description];
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(parameters[@"privateKey"]);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            [self alipayResult:resultDic];
        }];
    }
}
- (void)registerAppKey:(NSString *)appKey parameters:(NSDictionary *)orderDict appScheme:(NSString *)appScheme callback:(void (^)(XVIEWSDKResonseStatusCode statusCode, NSDictionary *responseData))callbackBlock {
    self.alipayCallbackBlock = callbackBlock;
    [self aliPayParameters:orderDict appScheme:appScheme];
}
*/
#pragma mark ==旧的方法==
- (void)registerAppKey:(NSString *)appKey aliPay:(NSString *)orderString appScheme:(NSString *)appScheme callback:(void (^)(XVIEWSDKResonseStatusCode statusCode, NSDictionary *responseData))callbackBlock {
    self.alipayCallbackBlock = callbackBlock;
    [self aliPay:orderString appScheme:appScheme];
}
#pragma mark ==支付宝支付==
- (void)aliPay:(NSString *)string appScheme:(NSString *)appScheme {
    [[AlipaySDK defaultService] payOrder:string fromScheme:appScheme callback:^(NSDictionary *resultDic) {
        //正常 ->【callback处理支付结果】
        [self alipayResult:resultDic];
    }];
}
@end
