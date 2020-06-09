//
//  LBNetwork.m
//  NetworkTest20200605
//
//  Created by 刘李斌 on 2020/6/9.
//  Copyright © 2020 Brilliance. All rights reserved.
//

#import "LBNetwork.h"

@interface LBNetwork () <NSURLSessionDataDelegate>
/** block */
@property (nonatomic, copy) LBRequestHandleBlock handleBlock;

/** recieveData */
@property(nonatomic, strong) NSMutableData *recieveData;
@end

@implementation LBNetwork
+ (instancetype)sharedInstance {
    static LBNetwork *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (NSURLSessionDataTask *)postWithUrl:(NSString *)url token:(NSString *)token params:(NSDictionary*)params handle:(LBRequestHandleBlock)handleBlock {
    if (!url && url.length == 0 && ![self checkIsUrlAtString:url]) {
        handleBlock(nil,nil,[NSError errorWithDomain:@"url 错误" code:-900001 userInfo:nil]);
        return nil;
    }
    if (!token && token.length == 0) {
        handleBlock(nil,nil,[NSError errorWithDomain:@"token 错误" code:-900002 userInfo:nil]);
        return nil;
    }
    self.handleBlock = handleBlock;
    self.recieveData = [NSMutableData data];
    
    NSURL *requestUrl = [NSURL URLWithString:url];
    NSMutableURLRequest *mRequest = [NSMutableURLRequest requestWithURL:requestUrl];
    //设置请求头
    [mRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [mRequest setValue:token forHTTPHeaderField:@"token"];
    //设置请求方式
    mRequest.HTTPMethod = @"POST";
    //设置超时时间,默认60s
    mRequest.timeoutInterval = 30;
    //设置请求体
    mRequest.HTTPBody = [[self convertToJSONData:params] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:mRequest];
    [task resume];
    
    return task;
}

- (NSURLSessionDataTask *)getWithUrl:(NSString *)url token:(NSString *)token params:(NSDictionary*)params handle:(LBRequestHandleBlock)handleBlock {
    
    
    
    return nil;
}


#pragma mark - NSURLSessionDelegate
//接收到服务器的响应
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    completionHandler(NSURLSessionResponseAllow);
}

//接收到数据
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self.recieveData appendData:data];
}

//任务完成调用
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error == nil) {
        NSString *dataStr = [[NSString alloc] initWithData:self.recieveData encoding:NSUTF8StringEncoding];
        id obj = [self dictionaryWithJsonString:dataStr];
        self.handleBlock(obj, @"请求成功", nil);
    } else {
        self.handleBlock(nil, @"请求失败", [NSError errorWithDomain:[self getErrCode:error.code] code:error.code userInfo:nil]);
    }
}

-(NSString*)getErrCode:(NSInteger)code{
    
    switch (code) {
        case 700:
            return @"会话过期";
            break;
            
        case 800:
            return @"后台gg正常维护中";
            break;
            
        case 404:
            return @"网络连接失败";
            break;
            
        case 500:
            return @"服务器拒绝请求";
            break;
            
        default:
            break;
    }
    
    return @"未知错误";
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


#pragma mark - json 序列化
- (NSString*)convertToJSONData:(id)infoDict{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *jsonString = @"";
    if (!jsonData){
        NSLog(@"json 序列化错误: %@", error);
    }else{
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //去除掉首尾的空白字符和换行字符
    [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return jsonString;
}

#pragma mark - json 反序列化 -- json 解析
-(NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err){
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
@end
