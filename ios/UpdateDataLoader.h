//
//  UpdateDataLoader.h
//  JSPatchDemo
//
//  Created by xiekang on 2018/4/24.
//  Copyright © 2018年 lucien. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UpdateDataLoader : NSObject
@property (nonatomic, strong) NSDictionary* versionInfo;
+ (UpdateDataLoader *) sharedInstance;

//创建bundle路径
-(void)createHotFixBundlePath;

//检查下载热更新包
-(void)downloadNewBundle;

-(void)writeAppVersionInfoWithDictiony:(NSDictionary*)info;

-(NSString*)iOSFileBundlePath;

-(NSDictionary*)getDataFromIosBundlePlist;


@end
