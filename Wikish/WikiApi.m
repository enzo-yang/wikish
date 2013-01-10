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

static NSString *const kDefaultWikiFolder = @"wiki";


@implementation WikiApi


//+ (NSString *)contentApiOfSite:(WikiSite *)site keyword:(NSString *)keyword {
//    // https://zh.wikipedia.org/w/api.php?action=mobileview&page=Tree&sections=all&format=json
//    keyword = [keyword urlEncodedString];
//    
//    NSString *api = nil;
//    if ([kDefaultWikiFolder isEqualToString:site.folder]) {
//        api = [NSString stringWithFormat:@"https://%@.wikipedia.org/w/api.php?action=mobileview&sections=all&format=json&page=%@", site.code, keyword];
//    } else {
//        api = [NSString stringWithFormat:@"https://%@.wikipedia.org/w/api.php?action=mobileview&sections=all&format=json&page=%@&uselang=%@", site.code, keyword, site.folder];
//    }
//    return api;
//}
//
//+ (NSString *)headerApiOfSite:(WikiSite *)site keyword:(NSString *)keyword {
//    // https://en.wikipedia.org/w/api.php?action=parse&prop=headhtml&page=Tree&format=json&mobileformat=html
//    keyword = [keyword urlEncodedString];
//    NSString *api = [NSString stringWithFormat:@"https://%@.wikipedia.org/w/api.php?action=parse&prop=headhtml&format=json&mobileformat=html&page=%@", site.code, keyword];
//    return api;
//}
//
+ (NSString *)infoApiOfSite:(WikiSite *)site title:(NSString *)title {
    // https://zh.wikipedia.org/w/api.php?action=parse&prop=langlinks|headhtml|sections|displaytitle|categories|revid&page=%E7%8B%97&format=json&redirects=
    title = [title urlEncodedString];
    
    NSString *api = [NSString stringWithFormat:@"https://%@.wikipedia.org/w/api.php?action=parse&prop=%@&format=json&redirects=yes&page=%@&uselang=%@",site.lang, @"langlinks%7Csections%7Cdisplaytitle%7Ccategories%7Crevid%7Ctext",  title, site.sublang];
    
    return api;
}

+ (NSString *)openSearchApiOfSite:(WikiSite *)site keyword:(NSString *)incompleteKeyword {
    incompleteKeyword = [incompleteKeyword urlEncodedString];
    NSString *api = [NSString stringWithFormat:@"https://%@.wikipedia.org/w/api.php?action=opensearch&format=json&search=%@", site.lang, incompleteKeyword];
    return api;
}

@end
