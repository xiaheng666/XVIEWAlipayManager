//
//  XVIEWAliManager.h
//  XVIEWAliManager
//
//  Created by yyj on 2018/12/29.
//  Copyright © 2018 zd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XVIEWAliManager : NSObject

/**
 *  单例
 */
+ (instancetype)sharedAliManager;

/**
 *  注册支付宝scheme
 @param param    data    {appId  支付宝跳转scheme},
 */
- (void)registerApp:(NSDictionary *)param;

/**
 *  支付宝支付
@param param    data    {"payData":支付参数},
                callback回调方法
 */
- (void)aliPay:(NSDictionary *)param;

/**
 *  支付宝登陆
 @param param     data    {"loginData":登陆参数},
                  callback 回调方法
 */
- (void)aliLogin:(NSDictionary *)param;

/**
 *  支付宝分享（未实现）
 */
- (void)aliShare:(NSDictionary *)param;

/**
 *  支付宝返回回调
 @param param   url  回调地址,
                callback 回调方法
 */
- (BOOL)handleUrl:(NSDictionary *)param;

@end
