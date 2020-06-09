//
//  LBFileStreamNetwork.m
//  NetworkTest20200605
//
//  Created by 刘李斌 on 2020/6/9.
//  Copyright © 2020 Brilliance. All rights reserved.
//

#import "LBFileStreamNetwork.h"



@interface LBFileStreamNetwork () <NSURLSessionDataDelegate>

/** block */
@property (nonatomic, copy) fileHandleBlock handleBlock;

/** fileTotoal */
@property(nonatomic, assign) NSInteger fileTotoal;

/** fileDown */
@property(nonatomic, assign) NSInteger fileDown;

/** recieve */
@property(nonatomic, strong) NSMutableData *recieveData;

/** outputStream */
@property(nonatomic, strong) NSOutputStream *outputStream;

@end

@implementation LBFileStreamNetwork

- (NSURLSessionDataTask *)getDownFileUrl:(NSString *)fileUrl backBlock:(fileHandleBlock)handleBlock {
    if (!fileUrl && fileUrl.length == 0 && ![self checkIsUrlAtString:fileUrl]) {
        
        handleBlock(nil,nil,[NSError errorWithDomain:@"url 错误" code:-90001 userInfo:nil]);
        return nil;
    }
    
    self.handleBlock = handleBlock;
    self.fileTotoal = 0;
    self.fileDown = 0;
    
    NSURL *url = [NSURL URLWithString:fileUrl];
    NSMutableURLRequest *mRequest = [NSMutableURLRequest requestWithURL:url];
    mRequest.HTTPMethod = @"GET";
    mRequest.timeoutInterval = 30;
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:mRequest];
    [task resume];
    
    
    return task;
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    self.fileTotoal = response.expectedContentLength;
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    //直接append会造成内存暴增
//    [self.recieveData appendData:data];
    
    //使用文件流保存数据
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.outputStream open];
        [self.outputStream write:data.bytes maxLength:data.length];
        [self.outputStream close];
    });
    
    self.fileDown += data.length;
    float progress = self.fileDown * 1.0 / self.fileTotoal;
    NSString *proStr = [NSString stringWithFormat:@"%.2f %@", progress*100, @"%"];
    self.handleBlock(nil, proStr, nil);
    
    
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error != nil) {
        self.handleBlock([NSURL URLWithString:[self getSaveFilePath]], nil, nil);
    } else {
        self.handleBlock(nil, nil, error);
    }
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

- (NSString *)getSaveFilePath{
    
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"download.mp4"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    }
    return filePath;
}


- (NSMutableData *)recieveData {
    if (!_recieveData) {
        _recieveData = [NSMutableData data];
    }
    return _recieveData;
}

- (NSOutputStream *)outputStream {
    if (!_outputStream) {
        _outputStream = [NSOutputStream outputStreamToFileAtPath:[self getSaveFilePath] append:YES];
    }
    return _outputStream;
}
@end
