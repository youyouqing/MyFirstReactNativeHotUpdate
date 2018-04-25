//
//  DownLoadTool.h
//  JSPatchDemo
//
//  Created by xiekang on 2018/4/24.
//  Copyright © 2018年 lucien. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownLoadTool : NSObject
@property (nonatomic, strong) NSString *zipPath;

+ (DownLoadTool *) defaultDownLoadTool;

//根据url下载相关文件
-(void)downLoadWithUrl:(NSString*)url patchCode:(NSString *)patchCode serverAppVersion:(NSString *)serverVersion;

@end
