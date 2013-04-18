//
//  InjectScriptManager.m
//  Wikish
//
//  Created by ENZO YANG on 13-4-18.
//  Copyright (c) 2013年 Side Trip. All rights reserved.
//

#import "InjectScriptManager.h"
#import "Constants.h"
#import "WikishFileUtil.h"
#import "JSONKit.h"
#define kScriptInfoUrlString @"http://divisoryang.github.io/ductionary/script-info.json"
#define kScriptWebFolder @"http://divisoryang.github.io/ductionary/"

#define kUserDefaultScriptVersionKey @"js-version"
#define kUserDefaultLastCheckSciptVerstionDate @"last-check-js-version-date"

@interface InjectScriptManager()

@property (nonatomic, strong) NSString *script;

@end

@implementation InjectScriptManager

+ (InjectScriptManager *)sharedInstance {
    static InjectScriptManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [InjectScriptManager new];
    });
    return shared;
}

+ (void)launched {
    [self sharedInstance];
}

+ (NSString *)script {
    return [self sharedInstance].script;
}

- (id)init {
    self = [super init];
    if (self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSNumber *currentVersion = [defaults objectForKey:kUserDefaultScriptVersionKey];
        if (!currentVersion) {
            currentVersion = [NSNumber numberWithInt:kVersionOfInAppScript];
            [defaults setObject:currentVersion forKey:kUserDefaultScriptVersionKey];
        }
        
        NSString *scriptPath = [[WikishFileUtil wikishCachePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"w-i-s-%@.js", currentVersion]];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:scriptPath]) {
            scriptPath = [[NSBundle mainBundle] pathForResource:@"wiki-inject-functions" ofType:@"js"];
        }
        
        self.script = [NSString stringWithContentsOfFile:scriptPath encoding:NSUTF8StringEncoding error:nil];
        
        if (!self.script) self.script = @"";
        
        [self _checkScriptUpdate];
    }
    return self;
}

- (void)_checkScriptUpdate {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSDate *lastCheckDate = [defaults objectForKey:kUserDefaultLastCheckSciptVerstionDate];
        BOOL shouldCheck = NO;
        if (!lastCheckDate) {
            shouldCheck = YES;
        } else {
            if ([[NSDate date] timeIntervalSinceDate:lastCheckDate] > 24*60*60) {
                shouldCheck = YES;
            }
        }
        
        if (shouldCheck) {
            [defaults setObject:[NSDate date] forKey:kUserDefaultLastCheckSciptVerstionDate];
            NSString *versionInfoString = [NSString stringWithContentsOfURL:[NSURL URLWithString:kScriptInfoUrlString] encoding:NSUTF8StringEncoding error:nil];
            
            if (versionInfoString) {
                NSDictionary *dict = [versionInfoString objectFromJSONString];
                if (![dict isKindOfClass:[NSDictionary class]]) {
                    return;
                }
                NSNumber *ver = [dict objectForKey:@"ver"];
                NSNumber *currentVersion = [defaults objectForKey:kUserDefaultScriptVersionKey];
                if (ver != nil && [ver intValue] > [currentVersion intValue]) {
                    dispatch_async(dispatch_get_current_queue(), ^{
                        [self _updateScript:dict];
                    });
                }
            }
        }
    });
}

- (void)_updateScript:(NSDictionary *)dict {
    NSString *scriptPath = [NSString stringWithFormat:@"%@%@-%@.js", kScriptWebFolder, [dict objectForKey:@"name"], [dict objectForKey:@"ver"]];
    
    NSError *error;
    NSString *theScript = [NSString stringWithContentsOfURL:[NSURL URLWithString:scriptPath] encoding:NSUTF8StringEncoding error:&error];
    
    if (error == nil && [theScript isKindOfClass:[NSString class]]) {
        self.script = theScript;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:[[dict objectForKey:@"ver"] intValue] forKey:kUserDefaultScriptVersionKey];
        [defaults synchronize];
        
        NSString *scriptPath = [[WikishFileUtil wikishCachePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"w-i-s-%d.js", [[dict objectForKey:@"ver"] intValue]]];
        NSError *error;
        BOOL success = [self.script writeToFile:scriptPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
        if (!success) {
            LOG(@"error %@", error);
        }
    }
}

@end
