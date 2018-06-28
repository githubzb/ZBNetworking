//
//  ViewController.m
//  ZBNetworking
//
//  Created by 张宝 on 2018/6/27.
//  Copyright © 2018年 zb. All rights reserved.
//

#import "ViewController.h"
#import "SecondViewController.h"
#import "ZBNetworkHeader.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self testGetUrl];
    
}

- (void)testGetUrl{
    NSString *url = @"http://api.zb.com/data/v1/kline?market=eos_usdt&type=1day";
    [getUrl(url, nil, nil) then:^id _Nullable(ZBResponse * _Nullable value) {
        NSArray *arr = [[value dictionary] objectForKey:@"data"];
        NSLog(@"-------response:%@", arr);
        return value;
    }].zcatch(^id(NSError *error){
        NSLog(@"----------catch:%@", error);
        return error;
    });
}

- (IBAction)clickBtn:(id)sender{
    SecondViewController *vc = [[SecondViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

@end
