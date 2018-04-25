/**
 * Copyright (c) 2015-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "AppDelegate.h"

#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>
#import "AVOSCloud.h"
#import "UpdateDataLoader.h"
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//  NSURL *jsCodeLocation;
//  
//  jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];
//  
//  RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
//                                                      moduleName:@"AwesomeProject"
//                                               initialProperties:nil
//                                                   launchOptions:launchOptions];
  NSURL *jsCodeLocation;
  NSString* iOSBundlePath = [[[UpdateDataLoader sharedInstance] iOSFileBundlePath] stringByAppendingString:@"/bundle/index.ios.jsbundle"];
//  if ([[NSFileManager defaultManager] fileExistsAtPath:iOSBundlePath] && [self compareAppVersionIsSame]) {
//#ifdef DEBUG
//    //开发包
//    jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];
//#else
    //加载热修复下载的bundle
//    jsCodeLocation = [NSURL URLWithString:iOSBundlePath];
//#endif
//  }else{
//#ifdef DEBUG
//    //开发包
//    jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];
//#else
//    //离线包
    jsCodeLocation = [[NSBundle mainBundle] URLForResource:@"index.ios" withExtension:@"jsbundle"];//第一次用RN玩玩，本宝宝真是掉了很多坑啊，心碎了都
//#endif
//  }
  
  RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                      moduleName:@"AwesomeProject"
                                               initialProperties:nil
                                                   launchOptions:launchOptions];
  rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];
  //因为我将压缩包托管在leanCould上，此处是设置该SDK,如果有自己的后台则直接请求是否需要更新补丁，自己在AVCloud上注册了个账号，只能开发使用！
    [self AVOSCloudSetting];
  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  UIViewController *rootViewController = [UIViewController new];
  rootViewController.view = rootView;
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];
  return YES;
}
//判断热更新记录的版本与当前版本是否相同
-(BOOL)compareAppVersionIsSame{
  NSString *currentAppVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
  NSDictionary *dic = [[UpdateDataLoader sharedInstance]getDataFromIosBundlePlist];
  NSString *recordAppVersion = @"";
  if(dic !=nil && dic[@"appVerion"]){
    recordAppVersion = dic[@"appVerion"] ;
  }
  return [currentAppVersion isEqualToString:recordAppVersion];
}

-(void)AVOSCloudSetting{
  [[UpdateDataLoader sharedInstance] createHotFixBundlePath]; //在沙盒新建三个文件夹和一个plist文件，如果有则不新建
    [AVOSCloud setApplicationId:@"z8553NUibWJM9F4MwB0XQccw-gzGzoHsz" clientKey:@"u1jLdrFI2109aEsnl7mS6YN9"];
  #ifdef DEBUG
    [AVOSCloud setAllLogsEnabled:YES];
  #else
    [AVOSCloud setAllLogsEnabled:FALSE];
  #endif
  
//  AVObject *testObject = [AVObject objectWithClassName:@"hot_update_file"];
//  [testObject setObject:@"112" forKey:@"patchCode"];
//   [testObject setObject:@"1.1" forKey:@"version"];
//  [testObject save];
  [[UpdateDataLoader sharedInstance] downloadNewBundle];//进行网络请求判断是否需要下载补丁
}
@end
