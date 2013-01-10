//
//  WikiPage.h
//  Wikish
//
//  Created by YANG ENZO on 12-11-9.
//  Copyright (c) 2012年 Side Trip. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WikiPageDelegate;
@class WikiSite;
@class MobileView;

@interface WikiPage : NSObject {
    WikiSite        *_site;
    NSString        *_title;
    NSMutableArray  *_sections;
    NSMutableArray  *_langLinks;
    NSNumber        *_revid;
    NSString        *_bodyHtml;
    
    
    id<WikiPageDelegate> _delegate;
}

- (id)initWithSite:(WikiSite *)site title:(NSString *)title;

@property (nonatomic, readonly) WikiSite *site;
@property (nonatomic, readonly) NSString *title;

@property (nonatomic, readonly) NSArray *sections;
@property (nonatomic, readonly) NSArray *langLinks;
@property (nonatomic, readonly) NSNumber *revid;
@property (nonatomic, readonly) NSString *bodyHtml;

@property (nonatomic, assign) id<WikiPageDelegate> delegate;

// Fetch page from Internet
- (void)loadPage;

//- (NSURL *)localPageURL;

- (NSString *)pageHTML;

@end


@protocol WikiPageDelegate <NSObject>

- (void)wikiPageLoadSuccess:(WikiPage*)wikiPage;
- (void)wikiPageLoadFailed:(WikiPage*)wikiPage error:(NSError*)error;

@end