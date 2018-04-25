//
//  UpdateDataLoader.m
//  JSPatchDemo
//
//  Created by xiekang on 2018/4/24.
//  Copyright © 2018年 lucien. All rights reserved.
//
#import "UpdateDataLoader.h"
#import "DownLoadTool.h"
//#import "Network.h"
#import "AFNetworking.h"
//#import <AVOSCloud/AVOSCloud.h>
@implementation UpdateDataLoader

+ (UpdateDataLoader *) sharedInstance
{
    static UpdateDataLoader *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[UpdateDataLoader alloc] init];
    });
    return sharedInstance;
}

//创建bundle路径
-(void)createHotFixBundlePath{
    if([[NSFileManager defaultManager]fileExistsAtPath:[self getVersionPlistPath]]){
        return;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path = [paths lastObject];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *directryPath = [path stringByAppendingPathComponent:@"IOSBundle"];
    [fileManager createDirectoryAtPath:directryPath withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *bundleZipPath = [path stringByAppendingPathComponent:@"BundleZip"];
    [fileManager createDirectoryAtPath:bundleZipPath withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *PatchPlistPath = [path stringByAppendingPathComponent:@"PatchPlist"];
    [fileManager createDirectoryAtPath:PatchPlistPath withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *filePath = [PatchPlistPath stringByAppendingPathComponent:@"Version.plist"];
    [fileManager createFileAtPath:filePath contents:nil attributes:nil];
}

//获取版本信息,有下载就下载新的热更新包
-(void)downloadNewBundle{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSDictionary *dic = [self getDataFromIosBundlePlist];
    int patchCode = 0;
    if(dic !=nil && dic[@"patchCode"]){
        patchCode = [dic[@"patchCode"] intValue];
    }
    //此处应该将version和patchCode穿给后台，且要求后台返回数据要按修改时间升序（时间越新越靠前），拿version到数据库中匹配，与该version相同且大于该patchCode，有满足条件的数据则表明有补丁包需要下载，这时返回一个数组，我们取数组的第一个对象，该对象包含需要下载的url,然后下载。应该我使用了leanCloud，所以代码是这样
//    AVQuery *fileQuery = [AVQuery queryWithClassName:@"hot_update_file"];
//    [fileQuery whereKey:@"patchCode" greaterThan:@(patchCode)];
//    [fileQuery whereKey:@"version" equalTo:version];
//    [fileQuery orderByDescending:@"createdAt"];
//    [fileQuery findObjectsInBackgroundWithBlock:^(NSArray *lists, NSError *error) {
//        if(error==nil){
//            if(lists!=nil && lists.count>0){
//                AVObject *avObject = lists.firstObject;
//                if(avObject !=nil){
//                    NSDictionary *dic = (NSDictionary *)[avObject objectForKey:@"localData"];
//                    NSString *patchCode = (NSString *)dic[@"patchCode"];
//                    if(dic[@"pathfile"]!=nil){
//                        AVFile *file = dic[@"pathfile"];
//                        NSString *downLoadURL = (NSString *)file.url;
//                        [[DownLoadTool defaultDownLoadTool] downLoadWithUrl:downLoadURL patchCode:patchCode serverAppVersion:version];
//                    }
//                }
//            }
//        }
//    }];
}

//获取Bundle 路径
-(NSString*)iOSFileBundlePath{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* path = [paths objectAtIndex:0];
    NSString* filePath = [path stringByAppendingPathComponent:@"/IOSBundle"];
    return  filePath;
}

//获取版本信息储存的文件路径
-(NSString*)getVersionPlistPath{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* path = [paths objectAtIndex:0];
    NSString* filePath = [path stringByAppendingPathComponent:@"/PatchPlist/Version.plist"];
    return filePath;
}

//读取plist文件数据
-(NSDictionary*)getDataFromIosBundlePlist{
    return [NSDictionary dictionaryWithContentsOfFile:[self getVersionPlistPath]];
}

//创建或修改版本信息
-(void)writeAppVersionInfoWithDictiony:(NSDictionary*)dictionary{
    NSString* filePath  = [self getVersionPlistPath];
    [dictionary writeToFile:filePath atomically:YES];
}
@end


