//
//  TFDom.h
//  TrainJsDemo
//
//  Created by ikamobile on 1/22/14.
//  Copyright (c) 2014 ikamobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TFDom : NSObject

+ (NSString *)stringWithXPathQuery:(NSString *)xpathQuery inHtml:(NSString *)html;
+ (NSString *)stringsWithXPathQuery:(NSString *)xpathQuery inHtml:(NSString *)html;

@end
