//
//  NetWorkHandler.m
//  support-im-ios-debugdemo
//
//  Created by 于艳平 on 2022/7/26.
//

#import "NetWorkHandler.h"
#import <CommonCrypto/CommonDigest.h>

#define WEAKSELF  __weak typeof(self) weakSelf = self;

static NetWorkHandler *netWorkHandle = nil;
static AFHTTPSessionManager *manager;

@implementation NetWorkHandler

+ (AFHTTPSessionManager *)sharedHTTPManager {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [AFHTTPSessionManager manager];
    });
    return manager;
}

+ (NSString *)getNonce {
    int randomNum = arc4random_uniform(RAND_MAX);
    NSLog(@"randomNum : %d", randomNum);
    return [NSString stringWithFormat:@"%d", randomNum];
}

+ (NSString *)getTimestamp {
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] * 1000;
    NSInteger time = interval;
    NSString *timestamp = [NSString stringWithFormat:@"%zd", time];
    NSLog(@"timestamp : %@", timestamp);
    return timestamp;
}

+ (NSString *)getApiAddress {
    // 北京
    NSString *apiAddress = @"https://api-cn.ronghub.com/";
    NSString *navi = [AppGlobalConfig shareInstance].naviServer;
    if ([navi isEqualToString:@"navsg01.cn.ronghub.com"]) {
        // 新加坡
        apiAddress = @"https://api-sg01.ronghub.com/";
    } else if ([navi isEqualToString:@"nav-us.ronghub.com"]) {
        // 北美
        apiAddress = @"https://api-us.ronghub.com/";
    }
    return apiAddress;
}
+ (NSString *)getSignature:(NSString *)secret nonce:(NSString *)nonce Timestamp:(NSString *)timestamp {
    NSString *signatureStr = [NSString stringWithFormat:@"%@%@%@", secret, nonce, timestamp];
    return [self sha1:signatureStr];
}


+ (NSString *)sha1:(NSString *)str {

    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (unsigned int) data.length, digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}

+ (void)startRequestMethod:(RequestMethod)method
                parameters:(id)parameters
                       url:(NSString *)url
                   success:(void (^)(id responseObject))success
                   failure:(void (^)(NSError *error))failure {
    NSString *secret = [AppGlobalConfig shareInstance].secret;
    if (!secret || [secret isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"请求失败，secret为空"];
        return;
    }
    NSString *apiAddress = [NetWorkHandler getApiAddress];
    if (!apiAddress || [apiAddress isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"请求失败，apiAddress为空，请检查导航配置"];
        return;
    }
    NSString *appkey = [AppGlobalConfig shareInstance].appKey;
    if (!appkey || [appkey isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"请求失败，appkey为空"];
        return;
    }
    
    AFHTTPSessionManager *manager = [NetWorkHandler sharedHTTPManager];
    NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    NSString * kAFCharactersGeneralDelimitersToEncode = @":#[]@"; // does not include "?" or "/" due to RFC 3986 - Section 3.4
    NSString * kAFCharactersSubDelimitersToEncode = @"!$&'()*+,;=";
    [allowedCharacterSet removeCharactersInString:[kAFCharactersGeneralDelimitersToEncode stringByAppendingString:kAFCharactersSubDelimitersToEncode]];
    
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
    NSString *baseURL = [NetWorkHandler getApiAddress];
    NSString *apiUrl = [baseURL stringByAppendingPathComponent:url];
    [manager.requestSerializer setValue:appkey forHTTPHeaderField:@"App-Key"];
    NSString *nonce = [NetWorkHandler getNonce];
    [manager.requestSerializer setValue:nonce forHTTPHeaderField:@"RC-Nonce"];
    NSString *timestamp = [self getTimestamp];
    [manager.requestSerializer setValue:timestamp forHTTPHeaderField:@"RC-Timestamp"];
    NSString *signature = [self getSignature:secret nonce:nonce Timestamp:timestamp];
    [manager.requestSerializer setValue:signature forHTTPHeaderField:@"Signature"];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    switch (method) {
        case POST: {
            [manager POST:apiUrl parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (responseObject && [responseObject count] > 0) {
                    NSInteger code = [responseObject[@"code"] integerValue];
                    if (code == 200) {
                        if (success) {
                            success(responseObject);
                        }
                    } else {
                        if (failure) {
                            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"接口请求失败。" forKey:NSLocalizedDescriptionKey];
                            NSError *e = [NSError errorWithDomain:NSCocoaErrorDomain code:code userInfo:userInfo];
                            failure(e);
                        }
                    }
                } else {
                    if (failure) {
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"接口请求失败。" forKey:NSLocalizedDescriptionKey];
                        NSError *e = [NSError errorWithDomain:NSCocoaErrorDomain code:0 userInfo:userInfo];
                        failure(e);
                    }
                }
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failure) {
                    NSError *e =  nil;
                    if (error.code == NSURLErrorNotConnectedToInternet) {
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"请求失败，请检查网络。" forKey:NSLocalizedDescriptionKey];
                        e = [NSError errorWithDomain:NSCocoaErrorDomain code:NSURLErrorNotConnectedToInternet  userInfo:userInfo];
                    } else if (error.code == NSURLErrorTimedOut) {
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"请求超时，换个网络试一下。" forKey:NSLocalizedDescriptionKey];
                        e = [NSError errorWithDomain:NSCocoaErrorDomain code:NSURLErrorTimedOut  userInfo:userInfo];
                    } else {
                        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"接口请求失败。" forKey:NSLocalizedDescriptionKey];
                        e = [NSError errorWithDomain:NSCocoaErrorDomain code:error.code  userInfo:userInfo];
                    }
                    failure(e);
                }
            }];
            break;
        }
            
        default:
            break;
    }
    
    
    
}
@end
