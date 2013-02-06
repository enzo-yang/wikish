//
//  SiteManager.h
//  Wikish
//
//  Created by YANG ENZO on 12-11-13.
//  Copyright (c) 2012年 Side Trip. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WikiSite;

@interface SiteManager : NSObject {
    NSMutableArray *_sites;
}

+ (SiteManager *)sharedInstance;

- (NSArray *)supportedSites;

- (WikiSite *)siteOfLang:(NSString *)lang;

- (WikiSite *)siteOfName:(NSString *)name;

@end
