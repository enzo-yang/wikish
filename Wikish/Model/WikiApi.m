//
//  WikiApi.m
//  Wikish
//
//  Created by YANG ENZO on 12-11-8.
//  Copyright (c) 2012年 Side Trip. All rights reserved.
//

#import "WikiApi.h"
#import "WikiSite.h"
#import "NSString+Wikish.h"
#import "Setting.h"

@implementation WikiApi

+ (NSString *)infoApiOfSite:(WikiSite *)site title:(NSString *)title {
    // https://zh.wikipedia.org/w/api.php?action=parse&prop=langlinks|sections|displaytitle|revid&page=%E7%8B%97&format=json&redirects=
    title = [title urlEncodedString];
    
    NSString *protocol = @"http";
    if ([Setting isHttpsUsed]) protocol = @"https";
    NSString *api = [NSString stringWithFormat:@"%@://%@.wikipedia.org/w/api.php?action=parse&prop=%@&format=json&redirects=yes&page=%@&uselang=%@",protocol, site.lang, @"langlinks%7Csections%7Cdisplaytitle%7Crevid",  title, site.sublang];
    
    return api;
}

+ (NSString *)pageURLStringOfSite:(WikiSite *)site title:(NSString *)title {
    NSString *protocol = @"http";
    if ([Setting isHttpsUsed]) protocol = @"https";
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@.m.wikipedia.org/%@/%@",protocol, site.lang, site.sublang, [title urlEncodedString]];
    
    return urlString;
}

+ (NSString *)openSearchApiOfSite:(WikiSite *)site keyword:(NSString *)incompleteKeyword {
    NSString *protocol = @"http";
    if ([Setting isHttpsUsed]) protocol = @"https";
    
    incompleteKeyword = [incompleteKeyword urlEncodedString];
    NSString *api = [NSString stringWithFormat:@"%@://%@.m.wikipedia.org/w/api.php?action=opensearch&format=json&limit=20&search=%@",protocol, site.lang, incompleteKeyword];
    return api;
}

@end
