//
//  WikiPageInfo.m
//  Wikish
//
//  Created by YANG ENZO on 12-11-9.
//  Copyright (c) 2012年 Side Trip. All rights reserved.
//

#import "WikiPageInfo.h"
#import "Constants.h"
#import "FileUtil.h"

#import "WikiSite.h"
#import "SiteManager.h"
#import "LangLink.h"
#import "WikiSection.h"
#import "WikiApi.h"
#import "AFNetworking.h"
#import "MobileView.h"


static NSString *const kRevidKey = @"revid";
static NSString *const kHTMLBodyKey = @"body";
static NSString *const kLangLinksKey = @"langlinks";
static NSString *const kSectionsKey = @"sections";

@interface WikiPageInfo()

- (void)_loadContentFromWeb;
- (void)_loadContentSuccess;
- (void)_loadContentFailed:(NSError *)error;
- (void)_loadContentFromWebSuccess:(NSDictionary *)resultDict;


@end

@implementation WikiPageInfo

@synthesize site = _site, title = _title, sections = _sections, langLinks = _langLinks, revid = _revid;
@synthesize delegate = _delegate;

- (id)initWithSite:(WikiSite *)site title:(NSString *)title {
    if (site == nil || title == nil) return nil;
    self = [super init];
    if (self) {
        _site = [site copy];
        _title = [title copy];
    }
    return self;
}

- (void)dealloc {
    self.delegate = nil;
    [self _cleanInfos];
    [_site release];
    [_title release];
    [super dealloc];
}

- (void)loadPageInfo {
    [self _loadContentFromWeb];
}

- (NSUInteger)topLevelSectionCount {
    if (!_sections) return 0;
    NSUInteger cnt = 0;
    for (WikiSection *section in _sections) {
        if (section.level == 1) ++cnt;
    }
    return cnt;
}

- (NSURL *)pageURL {
    NSString *urlString = [WikiApi pageURLStringOfSite:_site title:_title];
    return [NSURL URLWithString:urlString];
}


- (void)_loadContentFromWeb {
    NSString *infoApi = [WikiApi infoApiOfSite:_site title:_title];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:infoApi]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self _loadContentFromWebSuccess:JSON];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [self _loadContentFailed:error];
    }];
    
    [operation start];
}

/*
 { parse: {
    title : "",
    revid : 0,
    redirects : [ { from : "", to : "" } ],
    langlinks : [ { lang : "", url : "", * : "" } ],
    sections : [ { toclevel : 1, line : "", anchor : "" , number : ""}] 
 */
- (void)_loadContentFromWebSuccess:(NSDictionary *)resultDict {
    NSNumber *revid = nil;
    NSMutableArray *langlinks = nil;
    NSMutableArray *sections = nil;
    @try {
        NSDictionary *parseDict = [resultDict objectForKey:@"parse"];
        revid = [self _extractWebRevid:parseDict];
        langlinks = [self _extractWebLangLinks:parseDict];
        sections = [self _extractWebSections:parseDict];
    }
    @catch (NSException *exception) {
        revid = nil;
    }
    
    
    if (!revid || !langlinks || !sections) {
        [self _loadContentFailed:[NSError errorWithDomain:kWikiPageInfoMissingErrorDomain code:kWikiPageInfoMissingErrorCode userInfo:nil]];
        return;
    }
    
    [self _cleanInfos];
    _revid = [revid copy];
    _sections = [sections retain];
    _langLinks = [langlinks retain];
    
    [self _loadContentSuccess];
}

- (NSNumber *)_extractWebRevid:(NSDictionary *)dict {
    NSNumber *revid = [dict objectForKey:@"revid"];
    if (![revid isKindOfClass:[NSNumber class]]) revid = nil;
    
    return revid;
}


- (NSMutableArray *)_extractWebLangLinks:(NSDictionary *)dict {
    NSMutableArray *langlinks = [[NSMutableArray new] autorelease];
    NSArray *rawLangLinks = [dict objectForKey:@"langlinks"];
    if (![rawLangLinks isKindOfClass:[NSArray class]]) return langlinks;
    
    // 搜索设置到的语言
    NSArray *supportedSites = [[SiteManager sharedInstance] supportedSites];
    for (WikiSite *site in supportedSites) {
        for (NSDictionary *langDict in rawLangLinks) {
            if ([site.lang isEqualToString:[langDict objectForKey:@"lang"]]) {
                LangLink *langlink = [[[LangLink alloc] initWithDict:langDict] autorelease];
                if (langlink) [langlinks addObject:langlink];
            }
        }
    }
    
    return langlinks;
}

- (NSMutableArray *)_extractWebSections:(NSDictionary *)dict {
    NSMutableArray *sections = [[NSMutableArray new] autorelease];
    NSArray *rawSections = [dict objectForKey:@"sections"];
    if (![rawSections isKindOfClass:[NSArray class]]) return sections;
    
    for (NSDictionary *rawSection in rawSections) {
        WikiSection *section = [[[WikiSection alloc] initWithDict:rawSection] autorelease];
        if (section) [sections addObject:section];
//        NSInteger nIndex = [sections indexOfObject:section];
//        int i = nIndex-1;
//        int sameLevelCnt = 1;
//        WikiSection *pre = nil;
//        for (; i>=0; --i) {
//            pre = [sections objectAtIndex:i];
//            if (pre.level < section.level) break;
//            if (pre.level == section.level) sameLevelCnt++;
//        }
//        if (i<0)
//            section.index = [NSString stringWithFormat:@"%d", sameLevelCnt];
//        else {
//            section.index = [pre.index stringByAppendingFormat:@".%d", sameLevelCnt];
//        }
    }
    
    return sections;
}

- (void)_loadContentSuccess {
    [self.delegate wikiPageInfoLoadSuccess:self];
}

- (void)_loadContentFailed:(NSError *)error {
    LOG(@"load content failed, reason: %@", [error localizedDescription]);
    [self.delegate wikiPageInfoLoadFailed:self error:error];
}

- (void)_cleanInfos {
    [_revid release]; _revid = nil;
    [_sections release]; _sections = nil;
    [_langLinks release]; _langLinks = nil;
}

@end
