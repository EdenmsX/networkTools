//
//  LBDownloadNetWork.h
//  NetworkTest20200605
//
//  Created by 刘李斌 on 2020/6/9.
//  Copyright © 2020 Brilliance. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LBDownloadNetWorkDelegate <NSObject>

- (void)backDownprogress:(float)progress tag:(NSInteger)tag;
- (void)downSucceed:(NSURL*)url tag:(NSInteger)tag;
- (void)downError:(NSError*)error tag:(NSInteger)tag;

@end

@interface LBDownloadNetWork : NSObject

@property (nonatomic, weak) id<LBDownloadNetWorkDelegate> delegate;

/** tag */
@property(nonatomic, assign) NSInteger tag;

/** 文件名 */
@property (nonatomic, copy) NSString *fileName;


/// 下载文件
/// @param fileUrl 文件url
/// @param isBreakPoint 是否断点续传
- (void)downloadFileWithFileUrl:(NSString *)fileUrl isBreakPoint:(BOOL)isBreakPoint;


/// 暂停下载
- (void)suspendDownload;


/// 取消下载
- (void)cancelDownload;

@end

NS_ASSUME_NONNULL_END
