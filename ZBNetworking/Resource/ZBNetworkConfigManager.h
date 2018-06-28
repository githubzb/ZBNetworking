//
//  ZBNetworkConfigManager.h
//  ZBNetworking
//
//  Created by 张宝 on 2018/6/27.
//  Copyright © 2018年 zb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>

typedef NSDictionary * (^ZBConfigBlock)(void);

@interface ZBNetworkConfigManager : NSObject

/**
 打印日志，默认：NO
 */
@property (nonatomic, assign) BOOL openLog;

/**
 标示是否已经启动了网络监听服务
 YES：已启动    NO：未启动
 */
@property (nonatomic, assign, readonly) BOOL startedMonitoring;

/**
 设置公共参数block
 */
@property (nonatomic, copy) ZBConfigBlock publicParamBlock;

/**
 设置公共header block
 */
@property (nonatomic, copy) ZBConfigBlock publicHeaderBlock;

///获取公共参数
@property (nonatomic, readonly) NSDictionary *publicParameter;

///获取公共header
@property (nonatomic, readonly) NSDictionary *publicHeader;

///请求超时时间，默认：20秒
@property (nonatomic, assign) NSTimeInterval timeout;

+ (instancetype)shareManager;

+ (BOOL)openLog;
+ (void)setOpenLog:(BOOL)openLog;
+ (BOOL)startedMonitoring;
+ (NSDictionary *)publicParameter;
+ (NSDictionary *)publicHeader;
+ (NSTimeInterval)timeout;
+ (void)setPublicParamBlock:(ZBConfigBlock)publicParamBlock;
+ (void)setPublicHeaderBlock:(ZBConfigBlock)publicHeaderBlock;

/**
 注册网络状态监听

 @param observer    观察者
 @param aSelector   执行方法
 */
+ (void)registerObserver:(id)observer networkStatusChange:(SEL)aSelector;

/**
 移除网络状态监听
 
 @param observer    观察者
 */
+ (void)removeNetworkStatusObserver:(id)observer;

@end
