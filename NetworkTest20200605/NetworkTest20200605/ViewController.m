//
//  ViewController.m
//  NetworkTest20200605
//
//  Created by 刘李斌 on 2020/6/5.
//  Copyright © 2020 Brilliance. All rights reserved.
//

#import "ViewController.h"
#import <AFHTTPSessionManager.h>
#import "LBDownloadNetWork.h"

@interface ViewController () <LBDownloadNetWorkDelegate>
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;

/** downloadtask */
@property(nonatomic, strong) LBDownloadNetWork *downloadTask;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    NSString *url = @"https://www.baidu.com";
//    
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
////    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
////    manager.securityPolicy.allowInvalidCertificates = YES;
////    manager.securityPolicy.validatesDomainName = NO;
//    
//    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSLog(@"success: %@", responseObject);
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"faile: %@", error);
//    }];
    
    
    
    
    
    
}

- (IBAction)beginDownloadFile:(id)sender {
    [self downloadFile:NO];
}
- (IBAction)suspendOrContinue:(id)sender {
    [self.downloadTask suspendDownload];
}
- (IBAction)ddxc:(id)sender {
    [self downloadFile:YES];
}
- (IBAction)cancel:(id)sender {
    [self.downloadTask cancelDownload];
}


- (void)downloadFile:(BOOL)isBreakPoint {
    NSString *url = @"https://pic.ibaotu.com/00/48/71/79a888piCk9g.mp4";
    
    
    [self.downloadTask downloadFileWithFileUrl:url isBreakPoint:isBreakPoint];
}



- (void)backDownprogress:(float)progress tag:(NSInteger)tag {
    NSLog(@"progress: %f", progress);
    self.progressView.progress = progress;
    self.progressLabel.text = [NSString stringWithFormat:@"%.1f %@",progress*100, @"%"];
}
- (void)downSucceed:(NSURL*)url tag:(NSInteger)tag {
    NSLog(@"success: %@", url);
}
- (void)downError:(NSError*)error tag:(NSInteger)tag {
    NSLog(@"error: %@", error);
}

- (LBDownloadNetWork *)downloadTask {
    if (!_downloadTask) {
        _downloadTask = [[LBDownloadNetWork alloc] init];
        _downloadTask.tag = 1;
        _downloadTask.fileName = @"download";
        _downloadTask.delegate = self;
    }
    return _downloadTask;
}

@end
