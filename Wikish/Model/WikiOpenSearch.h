//
//  WikiOpenSearch.h
//  Wikish
//
//  Created by YANG ENZO on 13-2-3.
//  Copyright (c) 2013年 Side Trip. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WikiSite;

@interface WikiOpenSearch : NSObject {
    int _searchCnt;
    int _currentTag;
    NSArray *_results;
    WikiSite *_site;
}

@property (nonatomic, retain) NSArray *results;
- (void)request:(NSString *)incompleteKeyword;
- (void)updateSite;

@end
