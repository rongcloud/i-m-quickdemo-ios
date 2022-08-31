//
//  NetWorkHandler.h
//  support-im-ios-debugdemo
//
//  Created by 于艳平 on 2022/7/26.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetWorkHandler : NSObject
//请求方式
typedef NS_ENUM(NSUInteger, RequestMethod) {
    POST = 0,
    GET,
    PUT,
    DELETE
};


/**
 *  AFNetworking请求方法 [AFHTTPClient shareInstance]
 *
 *  @param method     请求方式 POST / GET
 *  @param parameters 请求参数 
 *  @param url        请求url字符串
 *  @param success    请求成功回调block
 *  @param failure    请求失败回调block
 */
+ (void)startRequestMethod:(RequestMethod)method
                parameters:(id)parameters
                       url:(NSString *)url
                   success:(void (^)(id responseObject))success
                   failure:(void (^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
