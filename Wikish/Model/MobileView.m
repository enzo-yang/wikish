//
//  MobileView.m
//  Wikish
//
//  Created by YANG ENZO on 12-11-18.
//  Copyright (c) 2012年 Side Trip. All rights reserved.
//

#import "MobileView.h"
#import "WikishFileUtil.h"
#import "NSString+Wikish.h"

@interface MobileView()

- (void)_composePageAndSave;
- (void)_savePage:(NSString *)page;

@end

@implementation MobileView

- (id)initWithTitle:(NSString *)title {
    self = [super init];
    if (self) {
        _title = [[title urlDecodedString] copy];

        _headHTML = [[NSString alloc] initWithString:@"<html lang=\"zh-CN\" class="">\
        <head>\
        <title>维基百科</title>\
        <meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\" />\
        <meta name=\"viewport\" content=\"initial-scale=1.0, user-scalable=yes\">\
        <link rel=\"stylesheet\" href=\"https://bits.wikimedia.org/zh.wikipedia.org/load.php?debug=false&lang=zh-cn&modules=mobile%7Cmobile.production-only%2Cproduction-jquery%7Cmobile.device.iphone&only=styles&skin=mobile&*\" />\
        <link rel=\"stylesheet\" href=\"https://bits.wikimedia.org/zh.wikipedia.org/load.php?debug=false&lang=zh-cn&modules=mobile.site&only=styles&skin=mobile&*\" />\
        <script src=\"https://bits.wikimedia.org/zh.wikipedia.org/load.php?debug=false&lang=zh-cn&modules=mobile.head&only=scripts&skin=mobile&*\"></script>\
        </head>\
        <body>"];
    }
    LOG(@"title is :%@", _title);
    return self;
}

- (BOOL)parseSectionsFromDict:(NSDictionary *)dict {
    if (![dict isKindOfClass:[NSDictionary class]]) return NO;
    dict = [dict valueForKey:@"mobileview"];
    if (![dict isKindOfClass:[NSDictionary class]]) return NO;
    
    NSArray *rawSections = [dict valueForKey:@"sections"];
    
    if (![rawSections isKindOfClass:[NSArray class]]) return NO;
    
    [_sections release]; _sections = nil;
    NSMutableArray *tmpSections = [NSMutableArray new];
    
    BOOL result = YES;
    @try {
        for (int i=0; i<[rawSections count]; ++i) {
            NSDictionary *rawSection = [rawSections objectAtIndex:i];
            if ([(NSNumber*)[rawSection valueForKey:@"id"] intValue] != i) {
                for (rawSection in rawSections) {
                    if ([(NSNumber*)[rawSection valueForKey:@"id"] intValue] != i) break;
                }
            }
            if ([[rawSection valueForKey:@"text"] isKindOfClass:[NSString class]]) {
                [tmpSections addObject:[rawSection valueForKey:@"text"]];
            }
        }
        _sections = [tmpSections retain];
    }
    @catch (NSException *exception) {
        [_sections release]; _sections = nil;
        result = NO;
    }
    @finally {
        [tmpSections release];
    }
    
    [self _composePageAndSave];
    return result;
}

- (void)_composePageAndSave {
    if (!_sections || !_headHTML) return;
    NSMutableString *fullHTML = [NSMutableString stringWithString:_headHTML];
    for (NSString *section in _sections) {
        [fullHTML appendString:section];
    }
    [fullHTML appendString:@"</body></html>"];
    [self _savePage:fullHTML];
}

- (void)_savePage:(NSString *)page {
    NSString *folderPath = [[WikishFileUtil wikishCachePath] stringByAppendingPathComponent:_title];
    if (![FileUtil isFolderAtPath:folderPath]) {
        [FileUtil createFolderAtPath:folderPath];
    }
    NSString *filePath = [folderPath stringByAppendingPathComponent:@"page.html"];
    LOG(@"filePath: %@", filePath);
    [page writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

@end
