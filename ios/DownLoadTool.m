//
//  DownLoadTool.m
//  JSPatchDemo
//
//  Created by xiekang on 2018/4/24.
//  Copyright © 2018年 lucien. All rights reserved.
//

#import "DownLoadTool.h"
#import "ZipArchive.h"
#import "AFURLSessionManager.h"
#import "UpdateDataLoader.h"

@implementation DownLoadTool
+ (DownLoadTool *) defaultDownLoadTool{
    static DownLoadTool *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DownLoadTool alloc] init];
    });
    
    return sharedInstance;
}

-(void)downLoadWithUrl:(NSString*)url patchCode:(NSString *)patchCode serverAppVersion:(NSString *)serverVersion{
    //根据url下载相关文件
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURL *URL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        //获取下载进度
        NSLog(@"Progress is %f", downloadProgress.fractionCompleted);
    } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        //有返回值的block，返回文件存储路径
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        NSURL* targetPathUrl = [documentsDirectoryURL URLByAppendingPathComponent:@"BundleZip"];
        return [targetPathUrl URLByAppendingPathComponent:[response suggestedFilename]];
        
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if(error){
            //下载出现错误
            NSLog(@"%@",error);
        }else{
            //下载成功
            if([filePath absoluteString].length>7){
                self.zipPath = [[filePath absoluteString] substringFromIndex:7];
            }
            //下载成功后更新本地存储信息
            NSDictionary*infoDic=@{@"patchCode":serverVersion,@"appVerion":serverVersion,};
            [[UpdateDataLoader sharedInstance] writeAppVersionInfoWithDictiony:infoDic];
            //解压并删除压缩包
            [self unZip];
        }
    }];
    [downloadTask resume];
}

//解压压缩包
-(void)unZip{
    if (self.zipPath == nil) {
        return;
    }
    //检查Document里有没有bundle文件夹
    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* bundlePath = [path stringByAppendingPathComponent:@"/IOSBundle"];
    dispatch_queue_t _opQueue = dispatch_queue_create("cn.reactnative.hotupdate", DISPATCH_QUEUE_SERIAL);
    dispatch_async(_opQueue, ^{
        BOOL isDir;
        //如果有，则删除后解压，如果没有则直接解压
        if ([[NSFileManager defaultManager] fileExistsAtPath:bundlePath isDirectory:&isDir]&&isDir) {
            [[NSFileManager defaultManager] removeItemAtPath:bundlePath error:nil];
        }
        NSString *zipPath = self.zipPath;
        NSString *destinationPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]stringByAppendingString:@"/IOSBundle"];
        [SSZipArchive unzipFileAtPath:zipPath toDestination:destinationPath progressHandler:^(NSString * _Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {
        } completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nullable error) {
            //删除压缩包
            NSError* merror = nil;
            [[NSFileManager defaultManager] removeItemAtPath:self.zipPath error:&merror];
        }];
    });
}
@end


