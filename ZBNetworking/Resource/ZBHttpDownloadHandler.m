//
//  ZBHttpDownloadHandler.m
//  ZBNetworking
//
//  Created by 张宝 on 2018/6/27.
//  Copyright © 2018年 zb. All rights reserved.
//

#import "ZBHttpDownloadHandler.h"
#import "ZBNetworkConfigManager.h"
#import <CommonCrypto/CommonDigest.h>

static inline void ZBSafeDownloadCallBack(ZBDownloadHandlerBlock block, BOOL finished, NSProgress *progress, id response, NSError *error)
{
    if (block) {
        if ([NSThread isMainThread]) {
            block(finished, progress, response, error);
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                block(finished, progress, response, error);
            });
        }
    }
}

@interface ZBHttpDownloadHandler ()

@property (nonatomic, weak) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, copy) NSString *resumeDataCachePath;

@end
@implementation ZBHttpDownloadHandler

- (instancetype)init{
    self = [super init];
    if (self) {
        NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        self.resumeDataCachePath = [cachePath stringByAppendingPathComponent:@"ZBDownloadResumeData"];
        NSFileManager *fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:self.resumeDataCachePath]) {
            NSError *error;
            [fm createDirectoryAtPath:self.resumeDataCachePath
          withIntermediateDirectories:YES
                           attributes:nil
                                error:&error];
            [self printError:error];
        }
    }
    return self;
}

- (NSInteger)identifier{
    return self.downloadTask.taskIdentifier;
}

- (NSData *)resumeDataWithUrl:(NSString *)url{
    if (url&&url.length>0) {
        NSString *filePath = [self.resumeDataCachePath stringByAppendingPathComponent:[self md5String:url]];
        return [NSData dataWithContentsOfFile:filePath];
    }
    return nil;
}

#pragma mark - private
- (void)postDownloadFinishedNotify{
    if ([NSThread isMainThread]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ZBDownloadHandlerDidFinishedNotification
                                                            object:self];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:ZBDownloadHandlerDidFinishedNotification
                                                                object:self];
        });
    }
}
- (void)printError:(NSError *)error{
    if (error && [ZBNetworkConfigManager openLog]) {
        NSString *msg = [error description];
        printf("\nZBHttpDownloadHandler: %s\n", [msg UTF8String]);
    }
}
- (NSString *)md5String:(NSString *)aString{
    const char *value = [aString UTF8String];
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (unsigned int)strlen(value), outputBuffer);
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    return outputString;
}

- (BOOL)saveResumeData:(NSData *)data{
    if (data && data.length>0) {
        @synchronized (data) {
            NSError *error;
            NSDictionary *plist = [NSPropertyListSerialization propertyListWithData:data
                                                                            options:0
                                                                             format:NULL
                                                                              error:&error];
            [self printError:error];
            NSString *url = plist[@"NSURLSessionDownloadURL"];
            if (url&&![url isKindOfClass:[NSNull class]]&&url.length>0) {
                NSString *filePath = [self.resumeDataCachePath stringByAppendingPathComponent:[self md5String:url]];
                return [data writeToFile:filePath atomically:YES];
            }
        }
    }
    return NO;
}

- (BOOL)removeResumeDataByUrl:(NSString *)url{
    if (url) {
        NSString *filePath = [self.resumeDataCachePath stringByAppendingPathComponent:[self md5String:url]];
        NSError *error;
        BOOL result = [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
        [self printError:error];
        return result;
    }
    return NO;
}

- (instancetype)initWithSessionManager:(AFHTTPSessionManager *)sessionManager{
    self = [self init];
    if (self) {
        self.sessionManager = sessionManager;
    }
    return self;
}

- (ZBHttpDownloadHandler *)downloadRequest:(NSURLRequest *)request
                            moveToFilePath:(NSString *)path
                               resultBlock:(ZBDownloadHandlerBlock)block
{
    NSParameterAssert(request);
    NSParameterAssert(path);
    
    __weak __typeof__(self) weakSelf = self;
    if (request == nil || path == nil || [path isKindOfClass:[NSNull class]]) {
        return self;
    }
    if (self.sessionManager) {
        self.downloadTask =
        [self.sessionManager downloadTaskWithRequest:request
                                            progress:^(NSProgress * _Nonnull downloadProgress)
         {
             ZBSafeDownloadCallBack(block, NO, downloadProgress, nil, nil);
         } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response)
         {
             NSURL *toURL = [NSURL fileURLWithPath:path isDirectory:NO];
             ///这里可以指定下载某个位置
             return toURL;
         } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error)
         {
             ZBSafeDownloadCallBack(block, YES, nil, filePath, error);
             [weakSelf postDownloadFinishedNotify];
         }];
        [self.downloadTask resume];
    }
    return self;
}

- (ZBHttpDownloadHandler *)downloadResumeData:(NSData *)data
                               moveToFilePath:(NSString *)path
                                  resultBlock:(ZBDownloadHandlerBlock)block
{
    NSParameterAssert(data);
    NSParameterAssert(path);
    
    __weak __typeof__(self) weakSelf = self;
    if (data == nil || [data isKindOfClass:[NSNull class]] || path == nil || [path isKindOfClass:[NSNull class]]) {
        return self;
    }
    if (self.sessionManager) {
        self.downloadTask =
        [self.sessionManager downloadTaskWithResumeData:data
                                               progress:^(NSProgress * _Nonnull downloadProgress)
         {
             ZBSafeDownloadCallBack(block, NO, downloadProgress, nil, nil);
         } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response)
         {
             NSURL *toURL = [NSURL fileURLWithPath:path isDirectory:NO];
             ///这里可以指定下载某个位置
             return toURL;
         } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error)
         {
             if (!error) {
                 [weakSelf removeResumeDataByUrl:[response.URL absoluteString]];
             }
             ZBSafeDownloadCallBack(block, YES, nil, filePath, error);
             [weakSelf postDownloadFinishedNotify];
         }];
        [self.downloadTask resume];
    }
    return self;
}

#pragma mark - DTBURLDownloadHandler
- (void)cancel{
    if (self.downloadTask) {
        __weak __typeof__(self) weakSelf = self;
        [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            [weakSelf saveResumeData:resumeData];
            [weakSelf postDownloadFinishedNotify];
        }];
    }
}

+ (id<ZBURLDownloadHandler>)downloadSessionManager:(AFHTTPSessionManager *)sessionManager
                                           request:(NSURLRequest *)request
                                    moveToFilePath:(NSString *)path
                                       resultBlock:(ZBDownloadHandlerBlock)block
{
    ZBHttpDownloadHandler *handler = [[ZBHttpDownloadHandler alloc] initWithSessionManager:sessionManager];
    NSData *resumeData = [handler resumeDataWithUrl:[request.URL absoluteString]];
    if (resumeData) {
        return [handler downloadResumeData:resumeData moveToFilePath:path resultBlock:block];
    }
    return [handler downloadRequest:request moveToFilePath:path resultBlock:block];
}

+ (id<ZBURLDownloadHandler>)downloadSessionManager:(AFHTTPSessionManager *)sessionManager
                                        resumeData:(NSData *)data
                                    moveToFilePath:(NSString *)path
                                       resultBlock:(ZBDownloadHandlerBlock)block
{
    ZBHttpDownloadHandler *handler = [[ZBHttpDownloadHandler alloc] initWithSessionManager:sessionManager];
    return [handler downloadResumeData:data moveToFilePath:path resultBlock:block];
}

@end

NSString *const ZBDownloadHandlerDidFinishedNotification = @"com.zb.download.finished";
