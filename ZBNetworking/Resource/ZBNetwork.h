//
//  ZBNetwork.h
//  ZBNetworking
//
//  Created by 张宝 on 2018/6/27.
//  Copyright © 2018年 zb. All rights reserved.
//

#import "ZBResponse.h"
#import "ZBFormData.h"
#import "ZBHttpDownloadHandler.h"
#import <AFNetworking/AFURLRequestSerialization.h>
#import <zbpromise/PromiseHeader.h>

typedef void(^ZBConstructBodyBlock)(id<AFMultipartFormData> formData);
typedef void(^ZBProgressBlock)(NSProgress *progress);
typedef void (^ZBDownloadResponseBlock)(BOOL success, BOOL finished, NSProgress *progress, NSURL *filePath, NSError *error);

typedef ZBPromise<ZBResponse *> ZBResult;

@interface ZBNetwork : NSObject


/**
 发送一个GET请求
 
 @param url     请求的URL（必须是全路径，例如：http://m.xx.com/user/info）
 @param header  HTTP Header
 @param params  请求参数
 @param open    是否开启SSL公钥验证，YES:开启；NO:关闭
 @return        回调数据
 */
+ (ZBResult *)getUrl:(NSString *)url
              header:(NSDictionary *)header
              params:(NSDictionary *)params
       openSSLVerify:(BOOL)open;

/**
 发送一个POST请求
 
 @param url     请求的URL（必须是全路径，例如：http://m.xx.com/user/info）
 @param header  HTTP Header
 @param params  请求参数
 @param open    是否开启SSL公钥验证，YES:开启；NO:关闭
 @return        回调数据
 */
+ (ZBResult *)postUrl:(NSString *)url
               header:(NSDictionary *)header
               params:(NSDictionary *)params
        openSSLVerify:(BOOL)open;

/**
 发送一个POST请求（multipart/form-data）
 
 @param url         请求的URL（必须是全路径，例如：http://m.xx.com/user/info/update）
 @param header      The HTTP headers to be appended to the form data.
 @param params      请求参数
 @param body        构建body的block
 @param open        是否开启SSL公钥验证，YES:开启；NO:关闭
 @param progress    进度回调
 @return            回调数据
 */
+ (ZBResult *)postUrl:(NSString *)url
               header:(NSDictionary *)header
               params:(NSDictionary *)params
   constructBodyBlock:(ZBConstructBodyBlock)body
        openSSLVerify:(BOOL)open
        progressBlock:(ZBProgressBlock)progress;

/**
 上传文件（multipart/form-data）
 
 @param url         请求的URL（必须是全路径，例如：http://m.xx.com/user/header/upload）
 @param params      请求参数
 @param header      The HTTP headers to be appended to the form data.
 @param files       上传文件数据
 @param open        是否开启SSL公钥验证，YES:开启；NO:关闭
 @param progress    上传进度回调
 @return            回调数据
 */
+ (ZBResult *)uploadUrl:(NSString *)url
                 header:(NSDictionary *)header
                 params:(NSDictionary *)params
                  files:(NSArray<ZBFormData *> *)files
          openSSLVerify:(BOOL)open
          progressBlock:(ZBProgressBlock)progress;

/**
 文件下载（支持断点下载）
 
 @param url     请求的URL（必须是全路径，例如：http://m.xx.com/user/header.jpg）
 @param path    文件下载的目标地址
 @param open    是否开启SSL公钥验证，YES:开启；NO:关闭
 @param block   回调
 @return        下载处理类
 */
+ (ZBHttpDownloadHandler *)downloadUrl:(NSString *)url
                        moveToFilePath:(NSString *)path
                         openSSLVerify:(BOOL)open
                           resultBlock:(ZBDownloadResponseBlock)block;

/**
 文件下载（支持断点下载）
 
 @param request 请求对象
 @param path    文件下载的目标地址
 @param open    是否开启SSL公钥验证，YES:开启；NO:关闭
 @param block   回调
 @return        下载处理类
 */
+ (ZBHttpDownloadHandler *)downloadRequest:(NSURLRequest *)request
                                  filePath:(NSString *)path
                             openSSLVerify:(BOOL)open
                               resultBlock:(ZBDownloadResponseBlock)block;

/**
 获取当前的下载助手
 
 @param identifier  当前下载助手的identifier
 
 @return            下载处理类
 */
+ (ZBHttpDownloadHandler *)currentDownloadHandlerWithIdentifier:(NSInteger)identifier;

/**
 判断网络是否可达
 */
+ (BOOL)isReachable;
/**
 判断当前为WIFI网络
 */
+ (BOOL)isReachableViaWiFi;

@end


ZBResult * getUrl(NSString *url, NSDictionary *header, NSDictionary *params);
ZBResult * postUrl(NSString *url, NSDictionary *header, NSDictionary *params);
ZBResult * uploadUrl(NSString *url, NSDictionary *header, NSDictionary *params, NSArray<ZBFormData *> *files, ZBProgressBlock progress);
ZBPromise<NSURL *> * download(NSString *url, NSString *filePath, ZBProgressBlock progressBlock);
