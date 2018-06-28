//
//  ZBNetwork.m
//  ZBNetworking
//
//  Created by 张宝 on 2018/6/27.
//  Copyright © 2018年 zb. All rights reserved.
//

#import "ZBNetwork.h"
#import "ZBNetworkConfigManager.h"
#import "ZBSessionManager.h"
#import "ZBHttpRequestFormatter.h"
#import <Reachability/Reachability.h>

static NSString * const ZBURLErrorOfNotFoundNetwork = @"当前无网络连接";
static inline NSString *ZBURLQueryDecoding(NSString *str){
    if (str && [str isKindOfClass:[NSString class]]) {
        return [str stringByRemovingPercentEncoding];
    }
    return nil;
}
static inline NSString * ZBURLQueryEncoding(NSString *str){
    if (str && [str isKindOfClass:[NSString class]]) {
        return [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    return nil;
}
static inline NSString * ZBURLQueryEncodingNoRepeat(NSString *str){
    return ZBURLQueryEncoding(ZBURLQueryDecoding(str));
}

static inline NSError * ZBErrorWithReason(NSInteger code, NSString *reason, NSDictionary *info){
    NSMutableDictionary *userInfo = [info?:@{} mutableCopy];
    userInfo[NSLocalizedFailureReasonErrorKey] = reason;
    return [NSError errorWithDomain:NSURLErrorDomain
                               code:code
                           userInfo:userInfo];
}

//download
static NSMutableDictionary *container;
static inline void ZBDownloadHandlerContainerInsert(ZBHttpDownloadHandler *handler){
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!container) {
            container = [[NSMutableDictionary alloc] init];
        }
    });
    if (container) {
        container[@(handler.identifier)] = handler;
    }
}
static inline ZBHttpDownloadHandler * ZBDownloadHandlerContainerGet(NSInteger identifier){
    return container[@(identifier)];
}
static inline void ZBDownloadHandlerContainerRemove(ZBHttpDownloadHandler *handler){
    if ([container count]>0) {
        [container removeObjectForKey:@(handler.identifier)];
    }
}

#ifdef DEBUG
#define ZBErrorMsgWithCode(code) [NSString stringWithFormat:@"请求错误码：%@", @(code)]
#else
#define ZBErrorMsgWithCode(code) @"网络异常，请稍后再试！"
#endif

//for public use code
#define ZBCheckUrl(url, promise) \
if (url == nil|| [url isKindOfClass:[NSNull class]]) { \
NSString *msg = [NSString stringWithFormat:@"%s 'Invalid parameter not satisfying: url'", __func__]; \
[ZBNetwork printLog:msg]; \
[promise reject:ZBError(msg)]; \
return; \
} \
NSURL *URL = [ZBNetwork URL:url]; \
if (URL.scheme.length==0 || URL.host.length==0){ \
NSString *reason = [NSString stringWithFormat:@"Unsupport URL:%@", url]; \
[self printLog:reason]; \
[promise reject:ZBError(reason)]; \
return; \
}

#define ZBCheckNetwork(promise) \
if (![ZBNetwork isReachable]) { \
NSError *error = ZBErrorWithReason(NSURLErrorNotConnectedToInternet, \
ZBURLErrorOfNotFoundNetwork, \
nil); \
[promise reject:error]; \
return; \
}

#define ZBInitSessionOpenSSL(open) \
AFHTTPSessionManager *manager; \
if (open) { \
manager = [ZBSessionManager publicKeySessionManager]; \
}else{ \
manager = [ZBSessionManager defaultSessionManager]; \
}

#define ZBInitHttpHeader(header, manager) \
NSArray *keys = [manager.requestSerializer.HTTPRequestHeaders allKeys]; \
for (NSString *key in keys) { \
if (![key isEqualToString:@"Authorization"] && \
![key isEqualToString:@"Accept-Language"] && \
![key isEqualToString:@"User-Agent"]) \
{ \
[manager.requestSerializer setValue:nil forHTTPHeaderField:key]; \
} \
} \
NSDictionary *publicHeader = [ZBNetworkConfigManager publicHeader]; \
for (NSString *key in [publicHeader allKeys]) { \
NSString *val = publicHeader[key]; \
[manager.requestSerializer setValue:val forHTTPHeaderField:key]; \
} \
for (NSString *key in [header allKeys]) { \
[manager.requestSerializer setValue:header[key] forHTTPHeaderField:key]; \
}

@implementation ZBNetwork

+ (void)initialize{
    if (self == [ZBNetwork class]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(downloadHandlerFinishedNotify:)
                                                     name:ZBDownloadHandlerDidFinishedNotification
                                                   object:nil];
    }
}

+ (ZBPromise<ZBResponse *> *)getUrl:(NSString *)url
                             header:(NSDictionary *)header
                             params:(NSDictionary *)params
                      openSSLVerify:(BOOL)open
{
    return [ZBPromise setUp:^(ZBPromise * _Nonnull promise) {
        ZBCheckUrl(url, promise)
        ZBCheckNetwork(promise)
        ZBInitSessionOpenSSL(open)
        ZBInitHttpHeader(header, manager)
        [manager GET:URL.absoluteString
          parameters:params
            progress:nil
             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                 [promise resolve:[ZBResponse newTask:task data:responseObject]];
                 [self printRequest:task.originalRequest response:task.response];
             } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                 [promise reject:error];
                 [self printRequest:task.originalRequest response:task.response];
             }];
    }];
}

+ (ZBPromise<ZBResponse *> *)postUrl:(NSString *)url
                              header:(NSDictionary *)header
                              params:(NSDictionary *)params
                       openSSLVerify:(BOOL)open
{
    return [ZBPromise setUp:^(ZBPromise * _Nonnull promise) {
        ZBCheckUrl(url, promise)
        ZBCheckNetwork(promise)
        ZBInitSessionOpenSSL(open)
        ZBInitHttpHeader(header, manager)
        [manager POST:URL.absoluteString
           parameters:params
             progress:nil
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  [promise resolve:[ZBResponse newTask:task data:responseObject]];
                  [self printRequest:task.originalRequest response:task.response];
              } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                  [promise reject:error];
                  [self printRequest:task.originalRequest response:task.response];
              }];
    }];
}

+ (ZBPromise<ZBResponse *> *)postUrl:(NSString *)url
                              header:(NSDictionary *)header
                              params:(NSDictionary *)params
                  constructBodyBlock:(ZBConstructBodyBlock)body
                       openSSLVerify:(BOOL)open
                       progressBlock:(ZBProgressBlock)progress
{
    return [ZBPromise setUp:^(ZBPromise * _Nonnull promise) {
        ZBCheckUrl(url, promise)
        ZBCheckNetwork(promise)
        ZBInitSessionOpenSSL(open)
        ZBInitHttpHeader(header, manager)
        [manager POST:URL.absoluteString
           parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
               if (body) {
                   body(formData);
               }
           } progress:progress
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  [promise resolve:[ZBResponse newTask:task data:responseObject]];
                  [self printRequest:task.originalRequest response:task.response];
              } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                  [promise reject:error];
                  [self printRequest:task.originalRequest response:task.response];
              }];
    }];
}

+ (ZBPromise<ZBResponse *> *)uploadUrl:(NSString *)url
                                header:(NSDictionary *)header
                                params:(NSDictionary *)params
                                 files:(NSArray<ZBFormData *> *)files
                         openSSLVerify:(BOOL)open
                         progressBlock:(ZBProgressBlock)progress
{
    ZBPromise<ZBResponse *> *promise = [ZBPromise pending];
    ZBPromise<ZBResponse *> *uploadPromise =
    [ZBNetwork postUrl:url
                header:header
                params:params
    constructBodyBlock:^(id<AFMultipartFormData> formData) {
        @try{
            for (ZBFormData *data in files) {
                if (data.type == ZBFormDataTypeFileURL) {
                    NSError *error;
                    [formData appendPartWithFileURL:data.fileURL
                                               name:data.name
                                           fileName:data.fileName
                                           mimeType:data.mimeType
                                              error:&error];
                    if (error) {
                        [self printLog:error];
                        [promise reject:error];
                        break;
                    }
                }
                if (data.type == ZBFormDataTypeFileData) {
                    [formData appendPartWithFileData:data.data
                                                name:data.name
                                            fileName:data.fileName
                                            mimeType:data.mimeType];
                }
            }
        }@catch(NSException *exc){
            [promise reject:ZBErrorWithReason(0, exc.reason, exc.userInfo)];
        }
    }
         openSSLVerify:open
         progressBlock:progress];
    [uploadPromise then:^id _Nullable(ZBResponse * _Nullable value) {
        [promise resolve:value];
        return value;
    }].zcatch(^id(NSError *error){
        [promise reject:error];
        return error;
    });
    return promise;
}

+ (ZBHttpDownloadHandler *)downloadUrl:(NSString *)url
                        moveToFilePath:(NSString *)path
                         openSSLVerify:(BOOL)open
                           resultBlock:(ZBDownloadResponseBlock)block
{
    if (url == nil || [url isKindOfClass:[NSNull class]]) {
        NSString *msg = [NSString stringWithFormat:@"%s 'Invalid parameter not satisfying: url'", __func__];
        [ZBNetwork printLog:msg];
        return nil;
    }
    NSString *urlStr = ZBURLQueryEncodingNoRepeat(url);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    return [self downloadRequest:request
                        filePath:path
                   openSSLVerify:open
                     resultBlock:block];
}

+ (ZBHttpDownloadHandler *)downloadRequest:(NSURLRequest *)request
                                  filePath:(NSString *)path
                             openSSLVerify:(BOOL)open
                               resultBlock:(ZBDownloadResponseBlock)block
{
    if (request==nil) {
        NSString *msg = [NSString stringWithFormat:@"%s 'Invalid parameter not satisfying: request'", __func__];
        [ZBNetwork printLog:msg];
        return nil;
    }
    if (path == nil || [path isKindOfClass:[NSNull class]]) {
        NSString *msg = [NSString stringWithFormat:@"%s 'Invalid parameter not satisfying: moveToFilePath'", __func__];
        [ZBNetwork printLog:msg];
        return nil;
    }
    ZBInitSessionOpenSSL(open)
    if (![ZBNetwork isReachable]) {
        if (block) {
            block(NO, NO, nil, nil, ZBErrorWithReason(NSURLErrorNotConnectedToInternet, ZBURLErrorOfNotFoundNetwork, nil));
        }
        return nil;
    }
    ZBHttpDownloadHandler *handler =
    [ZBHttpDownloadHandler downloadSessionManager:manager
                                          request:request
                                   moveToFilePath:path
                                      resultBlock:^(BOOL finished, NSProgress *progress, NSURL *filePath, NSError *error)
     {
         if (block) {
             if (error) {
                 block(NO, finished, progress, filePath, ZBErrorWithReason(error.code, ZBErrorMsgWithCode(error.code), error.userInfo));
             }else{
                 block(YES, finished, progress, filePath, nil);
             }
         }
     }];
    ZBDownloadHandlerContainerInsert(handler);
    return handler;
}

+ (ZBHttpDownloadHandler *)currentDownloadHandlerWithIdentifier:(NSInteger)identifier{
    return ZBDownloadHandlerContainerGet(identifier);
}

+ (BOOL)isReachable{
    if ([ZBNetworkConfigManager shareManager].startedMonitoring) {
        return [[AFNetworkReachabilityManager sharedManager] isReachable];
    }
    return [[ZBNetwork reachability] currentReachabilityStatus] != NotReachable;
}

+ (BOOL)isReachableViaWiFi{
    if ([ZBNetworkConfigManager shareManager].startedMonitoring) {
        return [[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi];
    }
    return [[ZBNetwork reachability] currentReachabilityStatus] == ReachableViaWiFi;
}

#pragma mark - private
+ (void)downloadHandlerFinishedNotify:(NSNotification *)notify{
    if ([notify.object isKindOfClass:[ZBHttpDownloadHandler class]]) {
        ZBDownloadHandlerContainerRemove(notify.object);
    }
}
+ (Reachability *)reachability{
    return [Reachability reachabilityWithHostName:@"www.baidu.com"];
}
+ (NSURL *)URL:(NSString *)url{
    return [NSURL URLWithString:ZBURLQueryEncodingNoRepeat(url)];
}

+ (void)printRequest:(NSURLRequest *)request response:(NSURLResponse *)response{
    if ([ZBNetworkConfigManager openLog]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        ZBHttpRequestFormatter *formatter = [[ZBHttpRequestFormatter alloc] init];
        NSString *requestInfo = [formatter stringForObjectValue:request];
        NSString *requestHeader = [NSString stringWithFormat:@"request headerFields:%@", [request allHTTPHeaderFields]];
        NSString *responseHeader = [NSString stringWithFormat:@"response headerFields:%@", [httpResponse allHeaderFields]];
        NSString *msg = [NSString stringWithFormat:@"请求信息：%@\n%@\n%@",requestInfo, requestHeader, responseHeader];
        [self printLog:msg];
    }
}
+ (void)printLog:(id)log{
    if ([ZBNetworkConfigManager openLog]) {
        NSString *msg = [log description];
        printf("\nZBNetworking:%s\n", [msg UTF8String]);
    }
}

@end


ZBPromise<ZBResponse *> * getUrl(NSString *url, NSDictionary *header, NSDictionary *params){
    return [ZBNetwork getUrl:url header:header params:params openSSLVerify:NO];
}
ZBPromise<ZBResponse *> * postUrl(NSString *url, NSDictionary *header, NSDictionary *params){
    return [ZBNetwork postUrl:url header:header params:params openSSLVerify:NO];
}
ZBPromise<ZBResponse *> * uploadUrl(NSString *url, NSDictionary *header, NSDictionary *params, NSArray<ZBFormData *> *files, ZBProgressBlock progress){
    return [ZBNetwork uploadUrl:url
                         header:header
                         params:params
                          files:files
                  openSSLVerify:NO
                  progressBlock:progress];
}
ZBPromise<NSURL *> * download(NSString *url, NSString *filePath, ZBProgressBlock progressBlock){
    return [ZBPromise setUp:^(ZBPromise * _Nonnull promise) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            if (progressBlock) {
                progressBlock(nil);
            }
            [promise resolve:[NSURL fileURLWithPath:filePath]];
            return;
        }
        [ZBNetwork downloadUrl:url
                moveToFilePath:filePath
                 openSSLVerify:NO
                   resultBlock:^(BOOL success, BOOL finished, NSProgress *progress, NSURL *filePath, NSError *error)
         {
             if (success) {
                 if (finished) {
                     [promise resolve:filePath];
                 }else if (progressBlock){
                     progressBlock(progress);
                 }
             }else{
                 [promise reject:error];
             }
         }];
    }];
}
