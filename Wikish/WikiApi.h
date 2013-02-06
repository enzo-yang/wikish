//
//  WikiApi.h
//  Wikish
//
//  Created by YANG ENZO on 12-11-8.
//  Copyright (c) 2012年 Side Trip. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WikiSite;

@interface WikiApi : NSObject

//+ (NSString *)contentApiOfSite:(WikiSite *)site keyword:(NSString *)keyword;
//+ (NSString *)headerApiOfSite:(WikiSite *)site keyword:(NSString *)keyword;

+ (NSString *)infoApiOfSite:(WikiSite *)site title:(NSString *)title;
+ (NSString *)pageURLStringOfSite:(WikiSite *)site title:(NSString *)title;
+ (NSString *)openSearchApiOfSite:(WikiSite *)site keyword:(NSString *)incompleteKeyword;

@end
