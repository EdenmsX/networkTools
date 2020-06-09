//
//  LBDownloadNetWork.m
//  NetworkTest20200605
//
//  Created by 刘李斌 on 2020/6/9.
//  Copyright © 2020 Brilliance. All rights reserved.
//

#import "LBDownloadNetWork.h"

@interface LBDownloadNetWork () <NSURLSessionDownloadDelegate>

/** session */
@property(nonatomic, strong) NSURLSession *session;

/** sessionTask */
@property(nonatomic, strong) NSURLSessionDownloadTask *sessionTask;

/** resumeData */
@property(nonatomic, strong) NSData *resumeData;

/** isSuspend */
@property(nonatomic, assign) BOOL isSuspend;

/** timert */
@property(nonatomic, strong) NSTimer *timer;

@end

@implementation LBDownloadNetWork


/// 下载文件
/// @param fileUrl 文件url
/// @param isBreakPoint 是否断点续传
- (void)downloadFileWithFileUrl:(NSString *)fileUrl isBreakPoint:(BOOL)isBreakPoint {
    
    if (!fileUrl || fileUrl.length == 0 || ![self checkIsUrlAtString:fileUrl]) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(downError:tag:)]) {
            [self.delegate downError:[NSError errorWithDomain:@"file url error" code:-90001 userInfo:nil] tag:self.tag];
        }
        
        return;
    }
    
    NSURL *url = [NSURL URLWithString:fileUrl];
    //创建session
    if (!self.session) {
        
        //创建可在后台下载的session
        self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[self getCurrentDateStr]] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    
    //判断是否为断点续传
    if (isBreakPoint) {
        //断点续传,继续任务
        [self resumeDownloadTask];
    } else {
        //不是断点续传,新建任务
        self.sessionTask = [self.session downloadTaskWithURL:url];
    }
    
    [self.sessionTask resume];
    
    [self saveTmpFile];
    
}


/// 暂停下载
- (void)suspendDownload {
    if (self.isSuspend) {
        [self.sessionTask resume];
        //        [self.timer invalidate];
        //        self.timer = nil;
    } else {
        [self.sessionTask suspend];
//        [self.timer invalidate];
//        self.timer = nil;
    }
    self.isSuspend = !self.isSuspend;
}


/// 取消下载
- (void)cancelDownload {
    
    __weak typeof(self) weakSelf = self;
    [self.sessionTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        weakSelf.sessionTask = nil;
        [resumeData writeToFile:[weakSelf getTmpFileUrl] atomically:NO];
    }];
}


#pragma mark - NSURLSessionDelegate
//每一次收到数据调用
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
             didWriteData:(int64_t)bytesWritten
        totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    float progress = totalBytesWritten * 1.0 / totalBytesExpectedToWrite;
    if (self.delegate && [self.delegate respondsToSelector:@selector(backDownprogress:tag:)]) {
        [self.delegate backDownprogress:progress tag:self.tag];
    }
}

//文件下载完成
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    NSLog(@"location path = %@", location.path);
    [self.timer invalidate];
    self.timer = nil;
    
    //文件保存路径
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",self.fileName]];
    
    //保存文件
    NSFileManager *fm = [NSFileManager defaultManager];
    //如果有重名文件就删除旧文件
    if ([fm fileExistsAtPath:filePath]) {
        
        [fm removeItemAtPath:filePath error:nil];
    }
    //将文件移动到目标位置
    NSError *err;
    BOOL moveResult =[fm moveItemAtPath:location.path toPath:filePath error:&err];
//    BOOL copyResult = [fm copyItemAtPath:location.path toPath:filePath error:&err];
    if (moveResult) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(downSucceed:tag:)]) {
            [self.delegate downSucceed:[NSURL URLWithString:filePath] tag:self.tag];
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(downError:tag:)]) {
            [self.delegate downError:err tag:self.tag];
        }
    }
    //删除缓存文件
    [fm removeItemAtPath:location.path error:nil];
    [fm removeItemAtPath:[self getTmpFileUrl] error:nil];
    
    
    
}

//下载失败
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(downError:tag:)] && error != nil) {
        [self.delegate downError:[NSError errorWithDomain:@"download fail" code:-90003 userInfo:nil] tag:self.tag];
    }
}

//所有后台任务完成
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    NSLog(@"所有后台任务已经完成: %@",session.configuration.identifier);
}





/// 检查url是否合法
/// @param url url字符串
- (BOOL)checkIsUrlAtString:(NSString *)url {
    NSString *pattern = @"http(s)?://([\\w-]+\\.)+[\\w-]+(/[\\w- ./?%&=]*)?";
    
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:0 error:nil];
    NSArray *regexArray = [regex matchesInString:url options:0 range:NSMakeRange(0, url.length)];
    
    if (regexArray.count > 0) {
        return YES;
    }else {
        return NO;
    }
}

//获取当前时间 下载id标识用
- (NSString *)getCurrentDateStr{
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSTimeInterval timeInterval = [currentDate timeIntervalSince1970];
    return [NSString stringWithFormat:@"%.f",timeInterval];
}


/// 断点续传任务
- (void)resumeDownloadTask{
    
    if (!self.session) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(downError:tag:)]) {
            [self.delegate downError:[NSError errorWithDomain:@"resume faile, session is nil" code:-90002 userInfo:nil] tag:self.tag];
        }
        
        return;
    }
    NSLog(@"-----%ld----", self.sessionTask.state);
    if (self.sessionTask && self.sessionTask.state == 0) {
        NSLog(@"task is runing");
        return;
    }
    
    NSData *data = nil;
    if (self.resumeData && self.resumeData.length > 0) {
        data = self.resumeData;
    } else {
        NSFileManager *fm = [NSFileManager defaultManager];
        data = [fm contentsAtPath:[self getTmpFileUrl]];
        
        NSLog(@"data: %@", data);
    }
    
    self.sessionTask = [self.session downloadTaskWithResumeData:data];
}

//未下载完的临时文件url地址
-(NSString*)getTmpFileUrl{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [documentPath stringByAppendingPathComponent:@"download.tmp"];
    
    NSLog(@"filePath  %@",filePath);
    
//    NSString* url = [NSString stringWithFormat:@"/Users/LM/Desktop/%@.tmp",self.fileName];
    return filePath;
}

- (void)saveTmpFile {
    //每4秒保存一次文件,防止app被杀死下载数据丢失
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self downloadFile];
    }];
}

- (void)downloadFile {
    NSLog(@"timer ---- ");
    __weak typeof(self) weakSelf = self;
    [self.sessionTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        weakSelf.resumeData = resumeData;
        weakSelf.sessionTask = nil;
        if (!resumeData) {
            resumeData = [NSData dataWithContentsOfFile:[self getTmpFileUrl]];
        } else {
        [resumeData writeToFile:[self getTmpFileUrl] atomically:NO];
        }
        NSLog(@"---===---%@",resumeData);
        weakSelf.sessionTask = [self.session downloadTaskWithResumeData:resumeData];
        [weakSelf.sessionTask resume];
    }];
}


- (NSData *)resumeData {
    if (!_resumeData) {
        _resumeData = [NSData data];
    }
    return _resumeData;
}

@end
