//
//  LBNetwork.h
//  NetworkTest20200605
//
//  Created by 刘李斌 on 2020/6/9.
//  Copyright © 2020 Brilliance. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^LBRequestHandleBlock)(id _Nullable result, NSString * _Nullable msg, NSError * _Nullable err);

NS_ASSUME_NONNULL_BEGIN

@interface LBNetwork : NSObject

+ (instancetype)sharedInstance;

- (NSURLSessionDataTask *)postWithUrl:(NSString *)url token:(NSString *)token params:(NSDictionary*)params handle:(LBRequestHandleBlock)handleBlock;

- (NSURLSessionDataTask *)getWithUrl:(NSString *)url token:(NSString *)token params:(NSDictionary*)params handle:(LBRequestHandleBlock)handleBlock;

@end

NS_ASSUME_NONNULL_END
