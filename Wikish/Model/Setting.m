//
//  Setting.m
//  Wikish
//
//  Created by YANG ENZO on 13-3-2.
//  Copyright (c) 2013年 Side Trip. All rights reserved.
//

#import "Setting.h"
#import <UIKit/UIKit.h>
#import "Constants.h"

@implementation Setting

+ (void)useDefaultSetting {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:kUserDefaultsIsInitExpandedKey];
    
    NSString *use_https = NSLocalizedString(@"use-https", nil);
    BOOL bUseHttps = [use_https integerValue] == 0 ? NO : YES;
    [defaults setBool:bUseHttps forKey:kUserDefaultsUseHttpsKey];
    
    [defaults synchronize];
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
