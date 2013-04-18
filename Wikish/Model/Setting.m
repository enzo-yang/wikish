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
#import "GAI.h"

#define kUserDefaultsUserAgentKey       @"UserAgent"
// #define kExpanedUserAgent               @"Wikish/1.0 (http://www.vegemal.net/; trm_tt@msn.com)"
#define kExpanedUserAgent               @"Wikish/1.0 (http://divisoryang.github.com/; trm_tt@msn.com)"
#define kShrinkedUserAgent              @"Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Mobile/10A403"

#define kUserDefaultsIsInitExpandedKey  @"is-initially-expaned"
#define kUserDefaultsSearchSiteKey      @"search-site"
#define kUserDefaultsUseHttpsKey        @"use-https"
#define kUserDefaultsHomePageKey        @"home-page"
#define kUserDefaultsDarknessKey        @"darkness"

@implementation Setting

+ (void)useDefaultSetting {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:kUserDefaultsIsInitExpandedKey];
    
    NSString *use_https = NSLocalizedString(@"use-https", nil);
    BOOL bUseHttps = [use_https integerValue] == 0 ? NO : YES;
    [defaults setBool:bUseHttps forKey:kUserDefaultsUseHttpsKey];
    
    [defaults setInteger:(NSInteger)kHomePageTypeRecommend forKey:kUserDefaultsHomePageKey];
    
    [defaults setFloat:0.0f forKey:kUserDefaultsDarknessKey];
    
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
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:isExpanded forKey:kUserDefaultsIsInitExpandedKey];
    [defaults synchronize];
    
    
}
+ (BOOL)isInitExpanded {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsIsInitExpandedKey];
}

+ (void)lightnessUp {
    CGFloat darkness = [self lightnessMaskValue];
    darkness -= 0.06;
    if (darkness <= 0) {
        darkness = 0.0f; 
    }
    [self setLightnessMaskValue:darkness];
}
+ (void)lightnessDown {
    CGFloat darkness = [self lightnessMaskValue];
    darkness += 0.06;
    if (darkness >= 0.36) {
        darkness = 0.36f;
    }
    [self setLightnessMaskValue:darkness];
}

+ (CGFloat)lightnessMaskValue {
    return [[NSUserDefaults standardUserDefaults] floatForKey:kUserDefaultsDarknessKey];
}

+ (void)setLightnessMaskValue:(CGFloat)darkness {
    [[NSUserDefaults standardUserDefaults] setFloat:darkness forKey:kUserDefaultsDarknessKey];
}

@end
