//
//  ViewController.m
//  TrainJsDemo
//
//  Created by ikamobile on 1/20/14.
//  Copyright (c) 2014 ikamobile. All rights reserved.
//

#import "ViewController.h"
#import "JavaScriptCore.h"
#import "TFHttp.h"
#import "TFHttp2.h"
#import "TFDom.h"


static JSGlobalContextRef gContext = NULL;
static JSObjectRef gGlobalObject = NULL;


@interface NSString(JSValue)
- (JSStringRef)copyToJSStringValue;
+ (NSString *)stringWithJSString:(JSStringRef)jss;
+ (NSString *)stringWithJSValue:(JSValueRef)jsv;
@end


@implementation NSString(JSValue)

- (JSStringRef)copyToJSStringValue
{
    return JSStringCreateWithUTF8CString([self UTF8String]);
}

+ (NSString *)stringWithJSString:(JSStringRef)jss
{
    return (__bridge_transfer NSString *)JSStringCopyCFString(NULL, jss);
}

+ (NSString *)stringWithJSValue:(JSValueRef)jsv
{
    JSStringRef jss = JSValueToStringCopy(gContext, jsv, NULL);
    return [self stringWithJSString:jss];
}

@end


#pragma JS Stuff

JSValueRef getJSValueFromNamePropertyArray(JSContextRef ctx, JSStringRef name)
{
    JSObjectRef obj = JSContextGetGlobalObject(ctx);
    JSPropertyNameArrayRef pArr = JSObjectCopyPropertyNames(ctx, obj);
    size_t count = JSPropertyNameArrayGetCount(pArr);
    JSValueRef ret = NULL;
    for (size_t i = 0; i < count; i++) {
        JSStringRef tmp = JSPropertyNameArrayGetNameAtIndex(pArr, i);
        //        NSString *out = (__bridge_transfer NSString *)JSStringCopyCFString(NULL, tmp);
        if (JSStringIsEqual(tmp, name)) {
            ret = JSObjectGetProperty(ctx, obj, name, NULL);
            break;
        }
    }
    
    return ret;
}

void dumpJSObject(JSContextRef c, JSObjectRef obj)
{
    LOG_FUNCTION;
    
    JSPropertyNameArrayRef pArr = JSObjectCopyPropertyNames(c, obj);
    size_t count = JSPropertyNameArrayGetCount(pArr);
    for (size_t i = 0; i < count; i++) {
        JSStringRef tmp = JSPropertyNameArrayGetNameAtIndex(pArr, i);
        JSValueRef v = JSObjectGetProperty(c, obj, tmp, NULL);
        NSLog(@"%@: %@", (__bridge_transfer NSString *)JSStringCopyCFString(NULL, tmp), [NSString stringWithJSValue:v]);
    }
}

void dumpJSValue(JSContextRef c, JSValueRef v)
{
    LOG_FUNCTION;
    
    if (v == NULL) {
        NSLog(@"value is NULL!");
        return;
    }
    
    switch (JSValueGetType(c, v)) {
        case kJSTypeString:
        {
            JSStringRef jss = JSValueToStringCopy(c, v, NULL);
            
            NSLog(@"%@", JSStringCopyCFString(NULL, jss));
            break;
        }
            
        case kJSTypeObject:
        {
            JSObjectRef obj = JSValueToObject(c, v, NULL);
            if (JSObjectIsFunction(c, obj)) {
//                JSValueRef v = JSObjectCallAsFunction(c, obj, NULL, 0, NULL, NULL);
//                dumpJSValue(c, v);
            } else {
                dumpJSObject(c, obj);
            }
            break;
        }
        case kJSTypeBoolean:
        {
            NSNumber *b = [NSNumber numberWithBool:JSValueToBoolean(c, v)];
            NSLog(@"%@", b);
            break;
        }
        case kJSTypeNumber:
        {
            NSNumber *d = [NSNumber numberWithDouble:JSValueToNumber(c, v, NULL)];
            NSLog(@"%@", d);
            break;
        }
        case kJSTypeNull:
        {
            NSLog(@"null");
            break;
        }
        case kJSTypeUndefined:
        {
            NSLog(@"undefined");
            break;
        }
        default:
            break;
    }
}

void dumpGlobalNamePropertyArray(JSContextRef c)
{
    LOG_FUNCTION;
    
    JSObjectRef obj = JSContextGetGlobalObject(c);
    JSPropertyNameArrayRef pArr = JSObjectCopyPropertyNames(c, obj);
    size_t count = JSPropertyNameArrayGetCount(pArr);
    for (size_t i = 0; i < count; i++) {
        JSStringRef tmp = JSPropertyNameArrayGetNameAtIndex(pArr, i);
        NSLog(@"%@", (__bridge_transfer NSString *)JSStringCopyCFString(NULL, tmp));
    }
}

void setGlobalObject(JSContextRef c, JSStringRef name)
{
    
}


#pragma Wrapper

JSValueRef sendRequestWrap(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception)
{
    if (argumentCount == 0) {
        assert("arg error");
        return JSValueMakeUndefined(gContext);
    }
    
    JSValueRef jsReqString = arguments[0];
    NSString *reqString = (__bridge_transfer NSString *)JSStringCopyCFString(NULL, JSValueToStringCopy(gContext, jsReqString, NULL));
    
    NSString *ret = [TFHttp2 sendRequest:reqString];
    
    return JSValueMakeString(gContext, [ret copyToJSStringValue]);
}

JSValueRef getStreamWrap(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception)
{
    if (argumentCount == 0) {
        assert("arg error");
        return JSValueMakeUndefined(gContext);
    }
    
    JSValueRef jsReqString = arguments[0];
    NSString *reqString = (__bridge_transfer NSString *)JSStringCopyCFString(NULL, JSValueToStringCopy(gContext, jsReqString, NULL));
    
    NSData *ret = [TFHttp2 getStream:reqString];
    NSString *retString = [ret base64Encoding];
    
    return JSValueMakeString(gContext, [retString copyToJSStringValue]);
}

JSValueRef testFunc(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception)
{
    return JSValueMakeNull(ctx);
}

JSValueRef logWrap(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception)
{
    if (argumentCount != 0) {
        JSValueRef v = arguments[0];
        if (JSValueGetType(gContext, v) == kJSTypeString) {
            NSLog(@"%@", [NSString stringWithJSValue:v]);
        }
    }
    
    return JSValueMakeNull(gContext);
}

JSValueRef selectNodeTextWrap(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception)
{
    if (argumentCount != 2) {
        return JSValueMakeNull(gContext);
    }
    
    JSValueRef html = arguments[0];
    JSValueRef xpath = arguments[1];
    
    NSString *ret = [TFDom stringWithXPathQuery:[NSString stringWithJSValue:xpath] inHtml:[NSString stringWithJSValue:html]];
    JSValueRef r = JSValueMakeString(gContext, [ret copyToJSStringValue]);
    
    return r;
}

JSValueRef selectNodeSetWrap(JSContextRef ctx, JSObjectRef function, JSObjectRef thisObject, size_t argumentCount, const JSValueRef arguments[], JSValueRef* exception)
{
    if (argumentCount != 2) {
        return JSValueMakeNull(gContext);
    }
    
    JSValueRef html = arguments[0];
    JSValueRef xpath = arguments[1];
    
    NSString *ret = [TFDom stringsWithXPathQuery:[NSString stringWithJSValue:xpath] inHtml:[NSString stringWithJSValue:html]];
    JSValueRef r = JSValueMakeString(gContext, [ret copyToJSStringValue]);
    
    return r;
}


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    gContext = JSGlobalContextCreate(NULL);
    gGlobalObject = JSContextGetGlobalObject(gContext);
    
    [super viewDidLoad];

    [self TFHttpTest];
    UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:tapG];
}

- (void)hideKeyboard
{
    [self.view.window endEditing:YES];
}

- (void)demoTest
{
    NSString *jsString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"hello" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
    JSStringRef t = JSStringCreateWithUTF8CString([jsString UTF8String]);
    JSValueRef exception = NULL;
    JSValueRef ret = JSEvaluateScript(gContext, t, NULL, NULL, 0, &exception);
    JSStringRelease(t);
    dumpJSValue(gContext, ret);
    
    JSValueRef r = getJSValueFromNamePropertyArray(gContext, [@"asd" copyToJSStringValue]);
    dumpJSValue(gContext, r);
    JSObjectRef obj = JSContextGetGlobalObject(gContext);
    JSObjectRef functionObj = JSObjectMakeFunction(gContext, NULL, 0, NULL, [@"return 'functionname222'" copyToJSStringValue], NULL, 0, NULL);
    JSObjectSetProperty(gContext, obj, [@"functionName2" copyToJSStringValue], functionObj, kJSPropertyAttributeNone, NULL);
    dumpGlobalNamePropertyArray(gContext);
    
    r = JSEvaluateScript(gContext, [@"functionName2()" copyToJSStringValue], NULL, NULL, 0, NULL);
    dumpJSValue(gContext, r);
    
    functionObj = JSObjectMakeFunctionWithCallback(gContext, NULL, testFunc);
    JSObjectSetProperty(gContext, obj, [@"nativeFunc" copyToJSStringValue], functionObj, 0, NULL);
    dumpGlobalNamePropertyArray(gContext);
    r = JSEvaluateScript(gContext, [@"nativeFunc()" copyToJSStringValue], NULL, NULL, 0, NULL);
    dumpJSValue(gContext, r);
}


#pragma inject

- (void)inject_http
{
    JSObjectRef globalObj = JSContextGetGlobalObject(gContext);
    JSObjectRef httpObj = JSObjectMake(gContext, NULL, NULL);
    JSObjectRef sendFunctionObj = JSObjectMakeFunctionWithCallback(gContext, NULL, sendRequestWrap);
    JSObjectRef getStreamFunctionObj = JSObjectMakeFunctionWithCallback(gContext, NULL, getStreamWrap);
    
    JSObjectSetProperty(gContext, httpObj, [@"sendRequest" copyToJSStringValue], sendFunctionObj, 0, NULL);
    JSObjectSetProperty(gContext, httpObj, [@"getStream" copyToJSStringValue], getStreamFunctionObj, 0, NULL);
    JSObjectSetProperty(gContext, globalObj, [@"http" copyToJSStringValue], httpObj, 0, NULL);
}

- (void)inject_log
{
    JSObjectRef globalObj = JSContextGetGlobalObject(gContext);
    JSObjectRef logObj = JSObjectMakeFunctionWithCallback(gContext, NULL, logWrap);
    JSObjectSetProperty(gContext, globalObj, [@"log" copyToJSStringValue], logObj, 0, NULL);
}

- (void)inject_dom
{
    JSObjectRef globalObj = JSContextGetGlobalObject(gContext);
    JSObjectRef domObj = JSObjectMake(gContext, NULL, NULL);
    JSObjectRef domFunctionObj = JSObjectMakeFunctionWithCallback(gContext, NULL, selectNodeTextWrap);
    JSObjectRef domFunctionObj2 = JSObjectMakeFunctionWithCallback(gContext, NULL, selectNodeSetWrap);
    
    JSObjectSetProperty(gContext, domObj, [@"selectNodeText" copyToJSStringValue], domFunctionObj, 0, NULL);
    JSObjectSetProperty(gContext, domObj, [@"selectNodeSet" copyToJSStringValue], domFunctionObj2, 0, NULL);
    JSObjectSetProperty(gContext, globalObj, [@"dom" copyToJSStringValue], domObj, 0, NULL);
}


#pragma JS eval

- (JSValueRef)evalJS:(NSString *)jsString
{
    JSStringRef t = JSStringCreateWithUTF8CString([jsString UTF8String]);
    JSValueRef exception = NULL;
    JSValueRef ret = JSEvaluateScript(gContext, t, NULL, NULL, 0, &exception);
    JSStringRelease(t);
    
    if (exception) {
        assert("exception");
    }
    dumpJSValue(gContext, ret);
    
    return ret;
}

- (BOOL)loadJS:(NSString *)jsString
{
    JSStringRef t = JSStringCreateWithUTF8CString([jsString UTF8String]);
    JSValueRef exception = NULL;
    JSEvaluateScript(gContext, t, NULL, NULL, 0, &exception);
    JSStringRelease(t);
    
    if (exception) {
        assert("exception");
        return NO;
    } else {
        return YES;
    }
}

- (void)TFHttpTest
{
    [self inject_http];
    [self inject_log];
    [self inject_dom];
    dumpJSObject(gContext, JSContextGetGlobalObject(gContext));
    
    NSString *jsString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"hello" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
    
    if (![self loadJS:jsString]) {
        assert("load fail!");
    }
    
    JSValueRef loginValue = JSObjectGetProperty(gContext, gGlobalObject, [@"getLoginVerificationCode" copyToJSStringValue], NULL);
    if (JSValueIsObject(gContext, loginValue)) {
        JSObjectRef loginFunc = JSValueToObject(gContext, loginValue, NULL);
        if (JSObjectIsFunction(gContext, loginFunc)) {
            JSValueRef ret = JSObjectCallAsFunction(gContext, loginFunc, NULL, 0, NULL, NULL);
            
            NSData *data = [[NSData alloc] initWithBase64Encoding:[NSString stringWithJSValue:ret]];
            self.verifyCodeView.image = [UIImage imageWithData:data];
            self.verifyCodeView.contentMode = UIViewContentModeCenter;
        }
    }
}

- (IBAction)login:(id)sender
{
    NSString *userName = self.inputField1.text;
    NSString *passWord = self.inputField2.text;
    NSString *verifyCode = self.inputField3.text;
    
    userName = @"falcon_cjj";
    passWord = @"asdasd_";
    
    JSValueRef r = JSObjectGetProperty(gContext, gGlobalObject, [@"login" copyToJSStringValue], NULL);
    
    if (JSValueIsObject(gContext, r)) {
        JSObjectRef funcObj = JSValueToObject(gContext, r, NULL);

        JSValueRef v1 = JSValueMakeString(gContext, [userName copyToJSStringValue]);
        JSValueRef v2 = JSValueMakeString(gContext, [passWord copyToJSStringValue]);
        JSValueRef v3 = JSValueMakeString(gContext, [verifyCode copyToJSStringValue]);
        
        if (JSObjectIsFunction(gContext, funcObj)) {
            JSValueRef argList[] = {v1, v2, v3};
            JSValueRef e = NULL;
            JSValueRef ret = JSObjectCallAsFunction(gContext, funcObj, NULL, 3, argList, &e);

            if (e) {
                dumpJSValue(gContext, e);
                assert("e");
            } else {
//                dumpJSValue(gContext, ret);
                NSString *jsonString = [NSString stringWithJSValue:ret];
                NSDictionary *d = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                NSLog(@"%@", d);
            }
        }
    }
}

@end
