//
//  ZBSessionManager.m
//  ZBNetworking
//
//  Created by 张宝 on 2018/6/27.
//  Copyright © 2018年 zb. All rights reserved.
//

#import "ZBSessionManager.h"
#import "ZBNetworkConfigManager.h"

NSString * const ZBDefaultSessionManagerKey = @"DefaultSessionManagerKey";
NSString * const ZBPublicKeySessionManagerKey = @"PublicKeySessionManagerKey";
typedef NSMutableDictionary ZBSessionManagerContainer;
static ZBSessionManagerContainer *container;
static void ZBRegisterSessionManager(AFHTTPSessionManager *manager, NSString *key){
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        container = [[NSMutableDictionary alloc] init];
    });
    if (container) {
        container[key] = [manager copy];
    }
}
static AFHTTPSessionManager * ZBSessionManagerForKey(NSString *key){
    if (container) {
        return container[key];
    }
    return nil;
}

@implementation ZBSessionManager

+ (AFHTTPSessionManager *)defaultSessionManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.requestSerializer.timeoutInterval = [ZBNetworkConfigManager timeout];
        
        AFJSONResponseSerializer *jsonSerializer = [AFJSONResponseSerializer serializer];
        NSMutableSet *sets = [jsonSerializer.acceptableContentTypes mutableCopy];
        [sets addObject:@"text/html"];
        [sets addObject:@"text/plain"];
        jsonSerializer.acceptableContentTypes = sets;
        AFImageResponseSerializer *imgSerializer = [AFImageResponseSerializer serializer];
        AFXMLParserResponseSerializer *xmlSerializer = [AFXMLParserResponseSerializer serializer];
        AFPropertyListResponseSerializer *plistSerializer = [AFPropertyListResponseSerializer serializer];
        manager.responseSerializer = [AFCompoundResponseSerializer
                                      compoundSerializerWithResponseSerializers:@[jsonSerializer, imgSerializer, xmlSerializer, plistSerializer]];
        ZBRegisterSessionManager(manager, ZBDefaultSessionManagerKey);
    });
    return ZBSessionManagerForKey(ZBDefaultSessionManagerKey);
}

+ (AFHTTPSessionManager *)publicKeySessionManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.requestSerializer.timeoutInterval = [ZBNetworkConfigManager timeout];
        NSSet *cers = [AFSecurityPolicy certificatesInBundle:[NSBundle mainBundle]];
        if ([cers count]>0) {
            AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey];
            securityPolicy.pinnedCertificates = cers;
            manager.securityPolicy = securityPolicy;
        }else if ([ZBNetworkConfigManager openLog]){
            printf("\nZBNetworking:未找到SSL相关证书，请导入证书到项目中!\n");
        }
        AFJSONResponseSerializer *jsonSerializer = [AFJSONResponseSerializer serializer];
        NSMutableSet *sets = [jsonSerializer.acceptableContentTypes mutableCopy];
        [sets addObject:@"text/html"];
        [sets addObject:@"text/plain"];
        jsonSerializer.acceptableContentTypes = sets;
        AFImageResponseSerializer *imgSerializer = [AFImageResponseSerializer serializer];
        AFXMLParserResponseSerializer *xmlSerializer = [AFXMLParserResponseSerializer serializer];
        AFPropertyListResponseSerializer *plistSerializer = [AFPropertyListResponseSerializer serializer];
        manager.responseSerializer = [AFCompoundResponseSerializer
                                      compoundSerializerWithResponseSerializers:@[jsonSerializer, imgSerializer, xmlSerializer, plistSerializer]];
        ZBRegisterSessionManager(manager, ZBPublicKeySessionManagerKey);
    });
    return ZBSessionManagerForKey(ZBPublicKeySessionManagerKey);
}

@end

