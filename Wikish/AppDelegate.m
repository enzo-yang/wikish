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
#import "Constants.h"


@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self _registerUserAgent];
    
    self.window = [[[TapDetectingWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    self.window.rootViewController = [[MainViewController new] autorelease];
    
    // NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    // NSArray* languages = [defs objectForKey:@"AppleLanguages"];
    // NSLog(@"%@", languages);
    // languages = [NSLocale preferredLanguages];
    // NSLog(@"%@", languages);
    
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

- (void)_registerUserAgent {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    if ([defaults objectForKey:kUserDefaultsUserAgentKey] == nil) {
        NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:@"Wikish/1.0 (http://www.baidu.com/; trm_tt@msn.com)", @"UserAgent", nil];
        [dictionary setObject:@"Wikish/1.0 (http://www.baidu.com/; trm_tt@msn.com)" forKey:kUserDefaultsUserAgentKey];
        [defaults registerDefaults:dictionnary];
        [dictionnary release];
    }
}

@end
