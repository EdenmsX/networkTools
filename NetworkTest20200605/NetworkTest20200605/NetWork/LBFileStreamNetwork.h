//
//  LBFileStreamNetwork.h
//  NetworkTest20200605
//
//  Created by 刘李斌 on 2020/6/9.
//  Copyright © 2020 Brilliance. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^fileHandleBlock)(NSURL * _Nullable fileUrl, NSString * _Nullable progress, NSError * _Nullable err) ;

NS_ASSUME_NONNULL_BEGIN

@interface LBFileStreamNetwork : NSObject


- (NSURLSessionDataTask*)getDownFileUrl:(NSString*)fileUrl backBlock:(fileHandleBlock)handleBlock;
@end

NS_ASSUME_NONNULL_END
