//
//  ZBSessionManager.h
//  ZBNetworking
//
//  Created by 张宝 on 2018/6/27.
//  Copyright © 2018年 zb. All rights reserved.
//

@interface ZBSessionManager : NSObject

/**
 AFSSLPinningModeNone
 response support json、xml（NSXMLParser）、image、plist
 */
@property (class, readonly) AFHTTPSessionManager *defaultSessionManager;

/**
 AFSSLPinningModePublicKey
 response support json、xml（NSXMLParser）、image、plist
 */
@property (class, readonly) AFHTTPSessionManager *publicKeySessionManager;

@end
