//
//  AppDelegate.m
//  Wikish
//
//  Created by YANG ENZO on 12-9-23.
//  Copyright (c) 2012年 Side Trip. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "TapDetectingWindow.h"
#import "Setting.h"
//#import "SiteManager.h"
//#import "WikiSite.h"

#define kUserDefaultsIsFirstLaunch      @"is-first-launch"

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    NSLog( @"%@", [[SiteManager sharedInstance] defaultSite].name);
    
    if ([self _isFirstLaunch]) [Setting useDefaultSetting];
    [Setting registerUserAgent];
    self.window = [[[TapDetectingWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    self.window.rootViewController = [[MainViewController new] autorelease];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
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
