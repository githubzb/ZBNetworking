//
//  ZBObserver.h
//  ZBNetworking
//
//  Created by 张宝 on 2018/6/27.
//  Copyright © 2018年 zb. All rights reserved.
//

@interface ZBObserver : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;

@end
