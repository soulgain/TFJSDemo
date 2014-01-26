//
//  TFDom.m
//  TrainJsDemo
//
//  Created by ikamobile on 1/22/14.
//  Copyright (c) 2014 ikamobile. All rights reserved.
//

#import "TFDom.h"

#import "TFHpple.h"

@implementation TFDom

+ (NSString *)stringWithXPathQuery:(NSString *)xpathQuery inHtml:(NSString *)html
{
    TFHpple *hpple = [TFHpple hppleWithHTMLData:[html dataUsingEncoding:NSUTF8StringEncoding]];
    TFHppleElement *element = [hpple peekAtSearchWithXPathQuery:xpathQuery];
    
    return [element text];
}

+ (NSString *)stringsWithXPathQuery:(NSString *)xpathQuery inHtml:(NSString *)html
{
    TFHpple *hpple = [TFHpple hppleWithHTMLData:[html dataUsingEncoding:NSUTF8StringEncoding]];
    NSArray *array = [hpple searchWithXPathQuery:xpathQuery];
    
    NSMutableString *ret = [NSMutableString string];
    for (TFHppleElement *element in array) {
        [ret appendString:[element raw]];
    }
    [ret insertString:@"<html><meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />" atIndex:0];
    [ret appendString:@"</html>"];
    
    return [ret copy];
}

@end
