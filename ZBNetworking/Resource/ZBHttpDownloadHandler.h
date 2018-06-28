//
//  ZBHttpDownloadHandler.h
//  ZBNetworking
//
//  Created by 张宝 on 2018/6/27.
//  Copyright © 2018年 zb. All rights reserved.
//

typedef void (^ZBDownloadHandlerBlock)(BOOL finished, NSProgress *progress, NSURL *filePath, NSError *error);

@class AFHTTPSessionManager;
@protocol ZBURLDownloadHandler <NSObject>

+ (id<ZBURLDownloadHandler>)downloadSessionManager:(AFHTTPSessionManager *)sessionManager
                                           request:(NSURLRequest *)request
                                    moveToFilePath:(NSString *)path
                                       resultBlock:(ZBDownloadHandlerBlock)block;

+ (id<ZBURLDownloadHandler>)downloadSessionManager:(AFHTTPSessionManager *)sessionManager
                                        resumeData:(NSData *)data
                                    moveToFilePath:(NSString *)path
                                       resultBlock:(ZBDownloadHandlerBlock)block;
- (void)cancel;

@end
@interface ZBHttpDownloadHandler : NSObject<ZBURLDownloadHandler>

///handler unique identifier
@property (nonatomic, readonly) NSInteger identifier;

- (NSData *)resumeDataWithUrl:(NSString *)url;

@end

FOUNDATION_EXPORT NSString *const ZBDownloadHandlerDidFinishedNotification;
