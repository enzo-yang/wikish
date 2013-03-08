//
//  Setting.m
//  Wikish
//
//  Created by YANG ENZO on 13-3-2.
//  Copyright (c) 2013年 Side Trip. All rights reserved.
//

#import "Setting.h"
#import <UIKit/UIKit.h>

#define kUserDefaultsUserAgentKey       @"UserAgent"
#define kExpanedUserAgent               @"Wikish/1.0 (http://www.vegemal.net/; trm_tt@msn.com)"
#define kShrinkedUserAgent              @"Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Mobile/10A403"

#define kUserDefaultsIsInitExpandedKey  @"is-initially-expaned"
#define kUserDefaultsSearchSiteKey      @"search-site"
#define kUserDefaultsUseHttpsKey        @"use-https"
#define kUserDefaultsHomePageKey        @"home-page"

@implementation Setting

+ (void)useDefaultSetting {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:kUserDefaultsIsInitExpandedKey];
    
    NSString *use_https = NSLocalizedString(@"use-https", nil);
    BOOL bUseHttps = [use_https integerValue] == 0 ? NO : YES;
    [defaults setBool:bUseHttps forKey:kUserDefaultsUseHttpsKey];
    
    [defaults setInteger:(NSInteger)kHomePageTypeRecommend forKey:kUserDefaultsHomePageKey];
    
    [defaults synchronize];
}

+ (void)setHomePage:(HomePageType)type {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:(NSInteger)type forKey:kUserDefaultsHomePageKey];
    [defaults synchronize];
}

+ (HomePageType)homePage {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey:kUserDefaultsHomePageKey];
}

+ (void)setUseHttps:(BOOL)use {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:use forKey:kUserDefaultsUseHttpsKey];
    [defaults synchronize];
}
+ (BOOL)isHttpsUsed {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsUseHttpsKey];
}


+ (void)setInitExpanded:(BOOL)isExpanded {
    if (isExpanded != [self isLaunchTimeInitExpanded]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notice", nil) message:NSLocalizedString(@"Setting Needs Reboot App", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"I know", nil) otherButtonTitles:nil];
            [alert show];
            [alert release];
        });
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:isExpanded forKey:kUserDefaultsIsInitExpandedKey];
    [defaults synchronize];
    // [self registerUserAgent];
    
    
}
+ (BOOL)isInitExpanded {
    [self isLaunchTimeInitExpanded];
    return [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsIsInitExpandedKey];
}

+ (BOOL)isLaunchTimeInitExpanded {
    static BOOL isExpanded = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isExpanded = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsIsInitExpandedKey];
    });
    return isExpanded;
}

+ (void)registerUserAgent {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:kUserDefaultsIsInitExpandedKey] == YES) {
        NSDictionary *dictionnary = @{kUserDefaultsUserAgentKey: kExpanedUserAgent};
        [defaults registerDefaults:dictionnary];
    } else {
        NSDictionary *dictionary = @{kUserDefaultsUserAgentKey: kShrinkedUserAgent};
        [defaults registerDefaults:dictionary];
    }
    [defaults synchronize];
}

@end
