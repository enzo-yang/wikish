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
    NSMutableArray *_commonSites;
}

+ (SiteManager *)sharedInstance;

- (NSArray *)supportedSites;

- (NSArray *)commonSites;

- (WikiSite *)defaultSite;
// set next wikisite in _commonSites to be defaultSite
- (WikiSite *)alterDefaultSite;
- (void)setDefaultSite:(WikiSite *)site;

- (void)addCommonSite:(WikiSite *)site;
- (BOOL)isCommonSite:(WikiSite *)site;
- (BOOL)removeCommonSite:(WikiSite *)site;

- (void)addSite:(WikiSite *)site;
- (BOOL)hasSite:(WikiSite *)site;
- (void)removeSite:(WikiSite *)site;

- (WikiSite *)siteOfLang:(NSString *)lang;
- (WikiSite *)siteOfLang:(NSString *)lang subLang:(NSString *)subLang;

- (WikiSite *)siteOfName:(NSString *)name;

@end
