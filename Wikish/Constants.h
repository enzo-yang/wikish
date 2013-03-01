//
//  Constants.h
//  Wikish
//
//  Created by YANG ENZO on 12-11-18.
//  Copyright (c) 2012年 Side Trip. All rights reserved.
//

#ifndef Wikish_Constants_h
#define Wikish_Constants_h

#define kWikiPageInfoMissingErrorDomain @"Wiki Page Infomation Missing"
#define kWikiPageInfoMissingErrorCode -11

#define kUserDefaultsUserAgentKey       @"UserAgent"
#define kExpanedUserAgent               @"Wikish/1.0 (http://www.baidu.com/; trm_tt@msn.com)"
#define kShrinkedUserAgent              @"Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Mobile/10A403"

#define kUserDefaultsIsInitExpandedKey  @"is-initially-expaned"
#define kUserDefaultsSearchSiteKey      @"search-site"
#define kUserDefaultsUseHttpsKey        @"use-https"

UIColor *GetTableBackgourndColor();
UIColor *GetTableCellBackgroundColor();

#endif
