//
//  TFHttp2.m
//  TrainJsDemo
//
//  Created by ikamobile on 1/26/14.
//  Copyright (c) 2014 ikamobile. All rights reserved.
//

#import "TFHttp2.h"


@interface TFURLConnectionDelegate : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic) BOOL isFinish;
@end


@implementation TFHttp2

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
        
        NSLog(@"\n<-----------\n%@\n%@\n------------>", req.HTTPMethod, req.URL);
        
//        NSError *error = nil;
//        NSURLResponse *response = nil;
//        NSData *ret = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
//        if ([ret length]) {
//            return ret;
//        } else {
//            return nil;
//        }
        
        TFURLConnectionDelegate *aDelegate = [[TFURLConnectionDelegate alloc] init];
        NSURLConnection *t = [[NSURLConnection alloc] initWithRequest:req delegate:aDelegate];
        [t start];
        
        while (!aDelegate.isFinish) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        
        return aDelegate.data;
    } else {
        @throw error;
    }
}

#pragma mark -

@end


#pragma mark - NSURLConnection Delegate

@implementation TFURLConnectionDelegate

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.data = [NSMutableData data];
        self.isFinish = NO;
    }
    
    return self;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.isFinish = YES;
    // notify
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.isFinish = YES;
    // notify
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
        [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
    }
}

@end
