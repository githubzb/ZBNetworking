//
//  ZBHttpRequestFormatter.m
//  ZBNetworking
//
//  Created by 张宝 on 2018/6/27.
//  Copyright © 2018年 zb. All rights reserved.
//

#import "ZBHttpRequestFormatter.h"

@interface NSMutableString (DTBCommandLineArgs)

- (void)appendCommandLineArgument:(NSString *)argument;

@end
@implementation NSMutableString (DTBCommandLineArgs)

- (void)appendCommandLineArgument:(NSString *)argument{
    [self appendFormat:@" %@", [argument stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
}

@end

@implementation ZBHttpRequestFormatter

- (NSString *)stringForObjectValue:(id)obj{
    if ([obj isKindOfClass:[NSURLRequest class]]) {
        NSURLRequest *request = (NSURLRequest *)obj;
        NSMutableString *command = [NSMutableString stringWithString:@"curl"];
        for (id key in [request allHTTPHeaderFields]) {
            NSString *value = [[request valueForHTTPHeaderField:key] stringByReplacingOccurrencesOfString:@"\'" withString:@"\\\'"];
            NSString *headers = [NSString stringWithFormat:@"\"%@: %@\"", key, value];
            [command appendCommandLineArgument:[NSString stringWithFormat:@"-H %@", headers]];
        }
        NSString *acceptEncodingHeader = request.allHTTPHeaderFields[@"Accept-Encoding"];
        if ([acceptEncodingHeader rangeOfString:@"gzip"].location != NSNotFound) {
            [command appendCommandLineArgument:@"--compressed"];
        }
        if (request.URL) {
            NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:request.URL];
            if ([cookies count]>0) {
                NSMutableString *cookieStr = [NSMutableString string];
                for (NSHTTPCookie *cookie in cookies) {
                    [cookieStr appendFormat:@"%@=%@;", cookie.name, cookie.value];
                }
                [command appendCommandLineArgument:[NSString stringWithFormat:@"--cookie \"%@\"", cookieStr]];
            }
        }
        if ([request.HTTPBody length]>0) {
            NSMutableString *httpBody = [[NSMutableString alloc] initWithData:request.HTTPBody
                                                                     encoding:NSUTF8StringEncoding];
            [httpBody replaceOccurrencesOfString:@"\\" withString:@"\\\\" options:0 range:NSMakeRange(0, [httpBody length])];
            [httpBody replaceOccurrencesOfString:@"`" withString:@"\\`" options:0 range:NSMakeRange(0, [httpBody length])];
            [httpBody replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:0 range:NSMakeRange(0, [httpBody length])];
            [httpBody replaceOccurrencesOfString:@"$" withString:@"\\$" options:0 range:NSMakeRange(0, [httpBody length])];
            [command appendCommandLineArgument:[NSString stringWithFormat:@"-d \"%@\"", httpBody]];
        }
        [command appendCommandLineArgument:@"-v"];
        [command appendCommandLineArgument:[NSString stringWithFormat:@"-X %@", request.HTTPMethod]];
        [command appendCommandLineArgument:[NSString stringWithFormat:@"\"%@\"", request.URL.absoluteString]];
        return [NSString stringWithString:command];
    }
    return nil;
}

@end
