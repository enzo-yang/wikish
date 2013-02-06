//
//  SiteManager.m
//  Wikish
//
//  Created by YANG ENZO on 12-11-13.
//  Copyright (c) 2012年 Side Trip. All rights reserved.
//

#import "SiteManager.h"
#import "FileUtil.h"
#import "AppUtil.h"
#import "JSONKit.h"
#import "WikiSite.h"
#import "Constants.h"

static NSString *const kSitesFileName = @"sites.json";
static NSString *const kVersionToCompare = @"kVersionToCompare_Sites";

@interface SiteManager()

@property (nonatomic, retain) NSMutableArray *sites;

- (NSString *)_sitesFilePath;
- (NSMutableArray *)_loadSitesFromPlist;
- (NSMutableArray *)_loadSitesFromFile;
- (NSMutableArray *)_dictsToSites:(NSArray *)dicts;
- (NSMutableArray *)_sitesToDicts:(NSArray *)sites;
- (void)_mergeSites;
- (BOOL)_justUpdatedToNewVersion;
- (void)_saveSites;

@end

@implementation SiteManager

@synthesize sites = _sites;

+ (SiteManager *)sharedInstance {
    static SiteManager *sharedInstance = nil;
    @synchronized(self) {
        if (sharedInstance == nil) sharedInstance = [self new];
    }
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.sites = [self _loadSitesFromFile];
        if (nil == _sites) {
            self.sites = [self _loadSitesFromPlist];
        } else if ([self _justUpdatedToNewVersion]) {
            [self _mergeSites];
        }
    }
    return self;
}

- (void)dealloc {
    self.sites = nil;
    [super dealloc];
}

- (NSArray *)supportedSites {
    return _sites;
}

- (WikiSite *)siteOfLang:(NSString *)lang {
    for (WikiSite *site in _sites) {
        if ([site.lang isEqualToString:lang])
            return site;
    }
    return nil;
}

- (WikiSite *)siteOfName:(NSString *)name {
    for (WikiSite *site in _sites) {
        if ([site.name isEqualToString:name])
            return site;
    }
    return nil;
}

- (NSString *)_sitesFilePath {
    return [[FileUtil documentPath] stringByAppendingPathComponent:kSitesFileName];
}

- (NSMutableArray *)_loadSitesFromPlist {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Sites" ofType:@"plist"];
    NSArray *dicts = [NSArray arrayWithContentsOfFile:plistPath];
    return [self _dictsToSites:dicts];
}

- (NSMutableArray *)_loadSitesFromFile {
    NSString *sitesFilePath = [self _sitesFilePath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:sitesFilePath]) return nil;
    
    NSData *sitesData = [NSData dataWithContentsOfFile:sitesFilePath];
    NSArray *dicts = [sitesData objectFromJSONData];
    if ([dicts isKindOfClass:[NSArray class]]) {
        return [self _dictsToSites:dicts];
    }
    
    return nil;
}

- (NSMutableArray *)_dictsToSites:(NSArray *)dicts {
    if (!dicts) return nil;
    NSMutableArray *sites = [[NSMutableArray new] autorelease];
    for (NSDictionary *dict in dicts) {
        WikiSite *site = [[WikiSite alloc] initWithDictionary:dict];
        if (site) [sites addObject:site];
        [site release];
    }
    return sites;
}

- (NSMutableArray *)_sitesToDicts:(NSArray *)sites {
    if (!sites) return nil;
    NSMutableArray *dicts = [[NSMutableArray new] autorelease];
    for (WikiSite *site in sites) {
        NSDictionary *dict = [site toDictionary];
        [dicts addObject:dict];
    }
    return dicts;
}

- (void)_mergeSites {
    NSArray *plistSites = [self _loadSitesFromPlist];
    NSMutableArray *appends = [NSMutableArray new];
    
    for (WikiSite *plistSite in plistSites) {
        BOOL exist = NO;
        for (WikiSite *site in _sites) {
            if ([site sameAs:plistSite]) {
                [site copy:plistSite];
                exist = YES;
                break;
            }
        }
        
        if (!exist) {
            [appends addObject:plistSite];
        }
    }
    
    [_sites addObjectsFromArray:appends];
    [appends release];
    
    [self _saveSites];
}

- (BOOL)_justUpdatedToNewVersion {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *currentVersion = [AppUtil currentVersion];
    
    NSString *recordedVersion = [userDefaults valueForKey:kVersionToCompare];
    
    if ([currentVersion isEqualToString:recordedVersion]) {
        return NO;
    } else {
        [userDefaults setValue:currentVersion forKey:kVersionToCompare];
        [userDefaults synchronize];
    }
    return YES;
}

- (void)_saveSites {
    NSArray *dicts = [self _sitesToDicts:_sites];
    NSData *data = [dicts JSONData];
    [data writeToFile:[self _sitesFilePath] atomically:YES];
}


@end
