//
//  ZBResponse.h
//  ZBNetworking
//
//  Created by 张宝 on 2018/6/27.
//  Copyright © 2018年 zb. All rights reserved.
//

@interface ZBResponse : NSObject

@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, strong) id data;

+ (instancetype)newTask:(NSURLSessionDataTask *)task data:(id)data;

- (NSDictionary *)dictionary;
- (NSArray *)array;
- (UIImage *)image;
- (NSXMLParser *)xmlParser;

@end
