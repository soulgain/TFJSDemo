//
//  TFHttp.m
//  TrainJsDemo
//
//  Created by ikamobile on 1/21/14.
//  Copyright (c) 2014 ikamobile. All rights reserved.
//

#import "TFHttp.h"


@interface NSURLRequest (IgnoreSSL)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host;

@end

@implementation NSURLRequest (IgnoreSSL)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host
{
    return YES;
}

@end

@implementation TFHttp

+ (NSMutableURLRequest *)requestWithConfiguration:(NSDictionary *)config
{
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:config[@"url"]] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    
    [req setHTTPMethod:config[@"method"]];
    
    if (config[@"referer"]) {
        [req setValue:config[@"referer"] forHTTPHeaderField:@"Referer"];
    }
    
    NSDictionary *paramDict = config[@"data"];
    NSMutableArray *paramPairs = [NSMutableArray array];
    
    if (paramDict) {
        for (NSString *key in [paramDict allKeys]) {
            NSString *pair = [NSString stringWithFormat:@"%@=%@", key, [paramDict[key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            [paramPairs addObject:pair];
        }
    }
    
    NSMutableString *bodyString = [NSMutableString string];
    for (NSString *pair in paramPairs) {
        if ([bodyString length] == 0) {
            [bodyString appendString:pair];
        } else {
            [bodyString appendString:@"&"];
            [bodyString appendString:pair];
        }
    }
    
    if ([bodyString length]) {
        if ([config[@"method"] isEqualToString:@"POST"]) {
            [req setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
        } else {
            req.URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", config[@"url"], bodyString]];
        }
    }
    
    return req;
}

+ (NSString *)sendRequest:(NSString *)jsonString
{
    NSData *ret = [self getStream:jsonString];
    NSString *retString = [[NSString alloc] initWithData:ret encoding:NSUTF8StringEncoding];
    
    return retString;
}

+ (NSData *)getStream:(NSString *)jsonString
{
    NSError *error = nil;
    id configDict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    
    if (configDict) {
        NSURLRequest *req = [self.class requestWithConfiguration:configDict];
        NSError *error = nil;
        NSURLResponse *response = nil;
        
        NSLog(@"\n----------\n%@\n%@\n--------------", req.HTTPMethod, req.URL);
        NSData *ret = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
        if ([ret length]) {
            return ret;
        } else {
            return nil;
        }
    } else {
        @throw error;
    }
}


#pragma inner

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

- (void)get:(NSString *)url
{
    
}

- (void)post:(NSString *)url andBodyString:(NSString *)body
{
    
}

@end
