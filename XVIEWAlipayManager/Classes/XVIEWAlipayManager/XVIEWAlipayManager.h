//
//  XVIEWAlipayManager.h
//  XVIEW2.0
//
//  Created by njxh on 16/11/28.
//  Copyright © 2016年 南京 夏恒. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XVIEWSDKObject.h"
@interface XVIEWAlipayManager : NSObject
/*
 https://doc.open.alipay.com/doc2/detail?treeId=59&articleId=103676&docType=1  集成网址
 https://doc.open.alipay.com/doc2/detail.htm?spm=0.0.0.0.0KAJF6&treeId=59&articleId=103675&docType=1  点击“资源下载”，下载SDK&DEMO
 支付宝SDK依赖的其他库
 libc++.tbd
 libz.tbd
 SystemConfiguration.framework
 CoreTelephony.framework
 QuartzCore.framework
 CoreText.framework
 CoreGraphics.framework
 UIKit.framework
 Foundation.framework
 CFNetwork.framework
 CoreMotion.framework
 
 第一个问题：类似的/Users/...../Util/base64.h:63:21: Cannot find interface declaration for 'NSObject', superclass of 'Base64'。。。。
 解决办法是：在报错的文件添加  #import <Foundation/Foundation.h>
 
 
 第二个问题：/Users/..../Alipay15.1.6/openssl/rsa.h:62:10: 'openssl/asn1.h' file not found
 解决办法是：在Header Search Paths 里面添加支付宝SDK文件夹的路径
 
 第三个问题：报错：
 Undefined symbols for architecture x86_64:
 "_BIO_ctrl", referenced from:
 _rsa_sign_with_private_key_pem in openssl_wrapper.o
 解决办法：这种情况将支付宝客户端Demo下，AliSDKDemo程序下的libcrypto.a 和 libel.a 拷贝，然后导入到自己的项目中搞定
 */


/**
 *  AlipayApiManager的单例类
 *
 *  @return 您可以通过此方法，获取AlipayApiManager的单例，访问对象中的属性和方法
 */
+ (instancetype)shareAlipayManager;

@end
