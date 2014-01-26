//
//  TFHttp.h
//  TrainJsDemo
//
//  Created by ikamobile on 1/21/14.
//  Copyright (c) 2014 ikamobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TFHttp : NSObject

+ (NSData *)getStream:(NSString *)jsonString;
+ (NSString *)sendRequest:(NSString *)jsonString;

@end
