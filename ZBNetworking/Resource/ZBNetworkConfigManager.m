//
//  ZBNetworkConfigManager.m
//  ZBNetworking
//
//  Created by 张宝 on 2018/6/27.
//  Copyright © 2018年 zb. All rights reserved.
//

#import "ZBNetworkConfigManager.h"
#import "ZBObserver.h"

@interface ZBNetworkConfigManager ()

@property (nonatomic, strong) NSMutableArray *observers;

@end
@implementation ZBNetworkConfigManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        __weak __typeof(self) weakSelf = self;
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:
         ^(AFNetworkReachabilityStatus status)
         {
             // 标记网络监听已经开启
             __strong __typeof(weakSelf) strongSelf = weakSelf;
             [strongSelf executeObserversWithStatus:status];
             [strongSelf setStartedMonitoring:YES];
         }];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    }
    return self;
}

- (NSDictionary *)publicParameter{
    if (_publicParamBlock) {
        return _publicParamBlock();
    }
    return nil;
}

- (NSDictionary *)publicHeader{
    if (_publicHeaderBlock) {
        return _publicHeaderBlock();
    }
    return nil;
}

+ (instancetype)shareManager{
    static ZBNetworkConfigManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ZBNetworkConfigManager alloc] init];
        manager.openLog = NO;
        manager.timeout = 20;
    });
    return manager;
}

+ (BOOL)openLog{
    return [ZBNetworkConfigManager shareManager].openLog;
}
+ (void)setOpenLog:(BOOL)openLog{
    [ZBNetworkConfigManager shareManager].openLog = openLog;
}
+ (void)setBaseURL:(NSURL *)baseURL{
    [ZBNetworkConfigManager shareManager].baseURL = baseURL;
}
+ (NSURL *)baseURL{
    return [ZBNetworkConfigManager shareManager].baseURL;
}
+ (BOOL)startedMonitoring{
    return [ZBNetworkConfigManager shareManager].startedMonitoring;
}
+ (NSDictionary *)publicParameter{
    return [ZBNetworkConfigManager shareManager].publicParameter;
}
+ (NSDictionary *)publicHeader{
    return [ZBNetworkConfigManager shareManager].publicHeader;
}
+ (NSTimeInterval)timeout{
    return [ZBNetworkConfigManager shareManager].timeout;
}
+ (void)setPublicParamBlock:(ZBConfigBlock)publicParamBlock{
    [ZBNetworkConfigManager shareManager].publicParamBlock = publicParamBlock;
}
+ (void)setPublicHeaderBlock:(ZBConfigBlock)publicHeaderBlock{
    [ZBNetworkConfigManager shareManager].publicHeaderBlock = publicHeaderBlock;
}

+ (void)registerObserver:(id)observer networkStatusChange:(SEL)aSelector{
    [[ZBNetworkConfigManager shareManager] addObserver:observer selector:aSelector];
}

+ (void)removeNetworkStatusObserver:(id)observer{
    [[ZBNetworkConfigManager shareManager] removeObserver:observer];
}

#pragma mark - private
- (void)setStartedMonitoring:(BOOL)startedMonitoring{
    _startedMonitoring = startedMonitoring;
}

- (NSMutableArray *)observers{
    if (!_observers) {
        _observers = [[NSMutableArray alloc] init];
    }
    return _observers;
}

- (void)addObserver:(id)observer selector:(SEL)aSelector{
    if ([observer respondsToSelector:aSelector]) {
        ZBObserver *obs = [[ZBObserver alloc] init];
        obs.name = NSStringFromClass([observer class]);
        obs.target = observer;
        obs.selector = aSelector;
        NSUInteger index = [self indexOfObserver:observer];
        if (index==NSNotFound) {
            [self.observers addObject:obs];
        }else{
            [self.observers replaceObjectAtIndex:index withObject:obs];
        }
        if (self.startedMonitoring) {
            AFNetworkReachabilityStatus status = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
            [observer performSelectorOnMainThread:aSelector
                                       withObject:@(status)
                                    waitUntilDone:NO];
        }
    }
}

- (void)removeObserver:(id)observer{
    NSUInteger index = [self indexOfObserver:observer];
    if (index!=NSNotFound) {
        [self.observers removeObjectAtIndex:index];
    }
}

- (void)executeObserversWithStatus:(AFNetworkReachabilityStatus)status{
    NSMutableArray *deleteObservers = [NSMutableArray arrayWithCapacity:0];
    for (ZBObserver *observer in self.observers) {
        if ([observer.target respondsToSelector:observer.selector]) {
            [observer.target performSelectorOnMainThread:observer.selector
                                              withObject:@(status)
                                           waitUntilDone:NO];
        }else{
            [deleteObservers addObject:observer];
        }
    }
    if (deleteObservers.count>0) {
        [self.observers removeObjectsInArray:[NSArray arrayWithArray:deleteObservers]];
    }
}

- (NSUInteger)indexOfObserver:(id)observer{
    NSString *name = NSStringFromClass([observer class]);
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"name == %@", name];
    NSArray *arr = [self.observers filteredArrayUsingPredicate:pre];
    if (arr.count>0) {
        return [self.observers indexOfObject:arr.firstObject];
    }
    return NSNotFound;
}

@end
