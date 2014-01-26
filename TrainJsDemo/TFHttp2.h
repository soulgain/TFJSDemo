//
//  TFHttp2.h
//  TrainJsDemo
//
//  Created by ikamobile on 1/26/14.
//  Copyright (c) 2014 ikamobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TFHttp2 : NSObject

+ (NSData *)getStream:(NSString *)jsonString;
+ (NSString *)sendRequest:(NSString *)jsonString;

@end
