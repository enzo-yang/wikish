//
//  AppDelegate.m
//  Wikish
//
//  Created by YANG ENZO on 12-9-23.
//  Copyright (c) 2012年 Side Trip. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "HelpController.h"
#import "TapDetectingWindow.h"
#import "Setting.h"
#import "GAI.h"
#import "InjectScriptManager.h"
#import "WikishFileUtil.h"

#define kUserDefaultsIsFirstLaunch      @"is-first-launch"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [WikishFileUtil createWikishCachFolder];
    
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = -1; // 手动控制
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-39546615-1"];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    BOOL isFirstLaunch = [self _isFirstLaunch];
    if (isFirstLaunch) [Setting useDefaultSetting];
    
    [InjectScriptManager launched];

    self.window = [[TapDetectingWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    UINavigationController *nav = nil;
    if (isFirstLaunch) {
        HelpController *hCtrl = [HelpController new];
        MainViewController *mainCtrl = [MainViewController new];
        nav = [[UINavigationController alloc] initWithRootViewController:hCtrl];
        hCtrl.okBlock = ^{
            [nav pushViewController:mainCtrl animated:YES];
        };
        
    } else {
        nav = [[UINavigationController alloc] initWithRootViewController:[MainViewController new]];
    }
    nav.navigationBarHidden = YES;
    self.window.rootViewController = nav;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [[GAI sharedInstance] dispatch];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

- (BOOL)_isFirstLaunch {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL result = NO;
    if (![defaults objectForKey:kUserDefaultsIsFirstLaunch]) {
        result = YES;
        [defaults setBool:NO forKey:kUserDefaultsIsFirstLaunch];
    }
    return result;
}


@end
