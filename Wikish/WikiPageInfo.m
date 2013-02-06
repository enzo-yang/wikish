//
//  WikiPage.m
//  Wikish
//
//  Created by YANG ENZO on 12-11-9.
//  Copyright (c) 2012年 Side Trip. All rights reserved.
//

#import "WikiPage.h"
#import "Constants.h"
#import "FileUtil.h"

#import "WikiSite.h"
#import "SiteManager.h"
#import "LangLink.h"
#import "WikiSection.h"
#import "WikiApi.h"
#import "AFNetworking.h"
#import "MobileView.h"

/*
 wikipage store at [document path]/[lang]/[sub-lang]/[title]
 first check local wikipage file
 if exist load it
 if not load from web and save at local storage
 
 */

static NSString *const kRevidKey = @"revid";
static NSString *const kHTMLBodyKey = @"body";
static NSString *const kLangLinksKey = @"langlinks";
static NSString *const kSectionsKey = @"sections";

@interface WikiPage()

- (void)_loadContentFromWeb;
- (void)_loadLocalContent;
- (void)_loadContentSuccess;
- (void)_loadContentFailed:(NSError *)error;
- (void)_loadContentFromWebSuccess:(NSDictionary *)resultDict;

- (NSString *)_localWikiPagePath;
- (NSString *)_localWikiPagesFolder;
- (void)_savePageInfos;

@end

@implementation WikiPage

@synthesize site = _site, title = _title, sections = _sections, langLinks = _langLinks, revid = _revid, bodyHtml = _bodyHtml;
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

- (void)loadPage {
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self _localWikiPagePath]]) {
        [self _loadLocalContent];
    } else {
        [self _loadContentFromWeb];
    }
}

- (NSString *)pageHTML {
    NSString *page = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"wiki-page-head-html" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
    if (!page) return nil;
    page = [page stringByAppendingString:self.bodyHtml];
    page = [page stringByAppendingString:@"<div style='height: 45px !important;'/></body></html>"];
    return page;
}

- (void)_loadLocalContent {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^() {
        NSDictionary *dict = (NSDictionary *)[FileUtil deserializeObjectAtPath:[self _localWikiPagePath]];
        
        dispatch_async(dispatch_get_main_queue(), ^() {
            _revid = [[dict objectForKey:kRevidKey] copy];
            _bodyHtml = [[dict objectForKey:kHTMLBodyKey] retain];
            _langLinks = [[dict objectForKey:kLangLinksKey] retain];
            _sections = [[dict objectForKey:kSectionsKey] retain];
            [self _loadContentSuccess];
        });
    });
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
    text : { * : "" },
    langlinks : [ { lang : "", url : "", * : "" } ],
    sections : [ { toclevel : 1, line : "", anchor : "" }] 
 */
- (void)_loadContentFromWebSuccess:(NSDictionary *)resultDict {
    NSNumber *revid = nil;
    NSString *text = nil;
    NSMutableArray *langlinks = nil;
    NSMutableArray *sections = nil;
    @try {
        NSDictionary *parseDict = [resultDict objectForKey:@"parse"];
        revid = [self _extractWebRevid:parseDict];
        text = [self _extractWebBodyHtml:parseDict];
        langlinks = [self _extractWebLangLinks:parseDict];
        sections = [self _extractWebSections:parseDict];
    }
    @catch (NSException *exception) {
        revid = nil;
    }
    
    
    if (!revid || !text || !langlinks || !sections) [self _loadContentFailed:[NSError errorWithDomain:kWikiPageInfoMissingErrorDomain code:kWikiPageInfoMissingErrorCode userInfo:nil]];
    
    [self _cleanInfos];
    _revid = [revid copy];
    _bodyHtml = [text stringByReplacingOccurrencesOfString:@"src=\"//" withString:@"src=\"https://"];
    _sections = [sections retain];
    _langLinks = [langlinks retain];
    
    [self _savePageInfos];
    [self _loadContentSuccess];
}

- (NSNumber *)_extractWebRevid:(NSDictionary *)dict {
    NSNumber *revid = [dict objectForKey:@"revid"];
    if (![revid isKindOfClass:[NSNumber class]]) revid = nil;
    
    return revid;
}

- (NSString *)_extractWebBodyHtml:(NSDictionary *)dict {
    NSDictionary *textDict = [dict objectForKey:@"text"];
    if (![textDict isKindOfClass:[NSDictionary class]]) return nil;
    
    NSString *text = [textDict objectForKey:@"*"];
    if (![text isKindOfClass:[NSString class]]) return nil;
    
    return text;
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
    }
    
    return sections;
}

- (void)_loadContentSuccess {
    [self.delegate wikiPageLoadSuccess:self];
}

- (void)_loadContentFailed:(NSError *)error {
    NSLog(@"load content failed, reason: %@", [error localizedDescription]);
    [self.delegate wikiPageLoadFailed:self error:error];
}

- (NSString *)_localWikiPagePath {
    NSString *path = [[self _localWikiPagesFolder] stringByAppendingPathComponent:_title];
    return path;
}

- (NSString *)_localWikiPagesFolder {
    NSString *folder = [NSString stringWithFormat:@"%@/%@/%@",
                        [FileUtil documentPath],
                        _site.lang,
                        _site.sublang];
    
    if (![FileUtil isFolderAtPath:folder]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return folder;
}

- (void) _savePageInfos {
    NSString *path = [self _localWikiPagePath];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          self.revid, kRevidKey,
                          self.bodyHtml, kHTMLBodyKey,
                          self.langLinks, kLangLinksKey,
                          self.sections, kSectionsKey, nil];
    
    [FileUtil serializeObject:dict toPath:path];
}

- (void)_cleanInfos {
    [_revid release]; _revid = nil;
    [_bodyHtml release]; _bodyHtml = nil;
    [_sections release]; _sections = nil;
    [_langLinks release]; _langLinks = nil;
}

@end
