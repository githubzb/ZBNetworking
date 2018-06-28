//
//  ZBResponse.m
//  ZBNetworking
//
//  Created by 张宝 on 2018/6/27.
//  Copyright © 2018年 zb. All rights reserved.
//

#import "ZBResponse.h"

@implementation ZBResponse

+ (instancetype)newTask:(NSURLSessionDataTask *)task data:(id)data{
    ZBResponse *response = [[ZBResponse alloc] init];
    response.task = task;
    response.data = data;
    return response;
}

- (NSDictionary *)dictionary{
    if ([self.data isKindOfClass:[NSDictionary class]]) {
        return self.data;
    }
    return nil;
}

- (NSArray *)array{
    if ([self.data isKindOfClass:[NSArray class]]) {
        return self.data;
    }
    return nil;
}

- (UIImage *)image{
    if ([self.data isKindOfClass:[UIImage class]]) {
        return self.data;
    }
    return nil;
}

- (NSXMLParser *)xmlParser{
    if ([self.data isKindOfClass:[NSXMLParser class]]) {
        return self.data;
    }
    return nil;
}

@end
