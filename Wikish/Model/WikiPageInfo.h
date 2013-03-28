//
//  WikiPageInfo.h
//  Wikish
//
//  Created by YANG ENZO on 12-11-9.
//  Copyright (c) 2012年 Side Trip. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WikiPageInfoDelegate;
@class WikiSite;

@interface WikiPageInfo : NSObject {
    WikiSite        *_site;
    NSString        *_title;
    NSMutableArray  *_sections;
    NSMutableArray  *_langLinks;
    NSNumber        *_revid;
    
    
    id<WikiPageInfoDelegate> _delegate;
}

- (id)initWithSite:(WikiSite *)site title:(NSString *)title;

@property (nonatomic, readonly) WikiSite *site;
@property (nonatomic, readonly) NSString *title;

@property (nonatomic, readonly) NSArray *sections;
@property (nonatomic, readonly) NSArray *langLinks;
@property (nonatomic, readonly) NSNumber *revid;

@property (nonatomic, assign) id<WikiPageInfoDelegate> delegate;

// Fetch page info from Internet
- (void)loadPageInfo;

- (NSUInteger)topLevelSectionCount;

- (NSURL *)pageURL;

@end


@protocol WikiPageInfoDelegate <NSObject>

- (void)wikiPageInfoLoadSuccess:(WikiPageInfo*)wikiPage;
- (void)wikiPageInfoLoadFailed:(WikiPageInfo*)wikiPage error:(NSError*)error;

@end