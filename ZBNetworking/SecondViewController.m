//
//  SecondViewController.m
//  ZBNetworking
//
//  Created by 张宝 on 2018/6/27.
//  Copyright © 2018年 zb. All rights reserved.
//

#import "SecondViewController.h"
#import "ZBNetworkHeader.h"

@interface SecondViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *imgView;

@end

@implementation SecondViewController

- (void)dealloc{
    NSLog(@"----------------------SecondViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [ZBNetworkConfigManager registerObserver:self
                         networkStatusChange:@selector(networkStatusDidChange:)];
    
    NSString *url = @"https://ss2.baidu.com/6ONYsjip0QIZ8tyhnq/it/u=807506681,646568567&fm=173&app=25&f=JPEG?w=640&h=453&s=3B9346865856D5D8042E1D50030070BA";
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"aaa.jpeg"];
    [download(url, path, nil) then:^id _Nullable(NSURL * _Nullable value) {
        self.imgView.image = [UIImage imageWithContentsOfFile:value.path];
        return value;
    }];
    
    [self downloadZip];
}

- (void)downloadZip{
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"aaa.zip"];
    NSString *url = @"http://7sbkiz.com1.z0.glb.clouddn.com/Charts-master.zip";
    [download(url, path, ^(NSProgress *progress) {
        if (progress) {
            CGFloat pro = (float)progress.completedUnitCount/(float)progress.totalUnitCount;
            NSLog(@"progress:%@", @(pro));
        }
    }) then:^id _Nullable(NSURL * _Nullable value) {
        NSLog(@"-------下载完成");
        return value;
    }].zcatch(^id(NSError *error){
        NSLog(@"-------%@", error);
        return error;
    });
}

- (IBAction)clickCloseBtn:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)networkStatusDidChange:(NSNumber *)status{
    if (status.integerValue == AFNetworkReachabilityStatusNotReachable) {
        NSLog(@"--------当前无网络");
    }
    if (status.integerValue == AFNetworkReachabilityStatusReachableViaWiFi) {
        NSLog(@"--------当前网络wifi");
    }
}

@end
