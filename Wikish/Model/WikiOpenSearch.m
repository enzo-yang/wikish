//
//  WikiOpenSearch.m
//  Wikish
//
//  Created by YANG ENZO on 13-2-3.
//  Copyright (c) 2013年 Side Trip. All rights reserved.
//

#import "WikiOpenSearch.h"
#import "WikiSite.h"
#import "SiteManager.h"
#import "WikiApi.h"
#import "AFNetworking.h"

@interface OpenSearchRequest : NSURLRequest
@property (nonatomic, assign) int tag;
@end

@implementation OpenSearchRequest
@synthesize tag;
@end

@interface WikiOpenSearch()

@property (nonatomic, strong) NSMutableArray *operations;
@property (nonatomic, strong) NSString          *lastIncompleteKeyword;

@end

@implementation WikiOpenSearch

- (id)init {
    self = [super init];
    if (self) {
        _site = [[SiteManager sharedInstance] defaultSite];
        self.operations = [NSMutableArray new];
        self.results = [NSArray new];
        self.lastIncompleteKeyword = @"";
        _searchCnt = 0;
        _currentTag = -1;
    }
    return self;
}

- (void)dealloc {
    [self _cancelAllOperations];
    
}

- (void)request:(NSString *)incompleteKeyword {
    LOG(@"%@", _site.lang);
    if (incompleteKeyword == nil) incompleteKeyword = @"";
    incompleteKeyword = [incompleteKeyword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.lastIncompleteKeyword = incompleteKeyword;
    if ([incompleteKeyword isEqualToString:@""]) return;
    
    NSString *urlstring = [WikiApi openSearchApiOfSite:_site keyword:incompleteKeyword];
    OpenSearchRequest *request = [OpenSearchRequest requestWithURL:[NSURL URLWithString:urlstring]];
    LOG(@"%@", urlstring);
    request.tag = ++_searchCnt;
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                                 success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                                                     [self _removeOperationOfRequest:request];
                                                                                     [self _handleNewResults:JSON request:(OpenSearchRequest*)request];
                                                                                     
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [self _removeOperationOfRequest:request];
    }];
    
    [op start];
    
    if (op) [self.operations addObject:op];
    
}

- (void)updateSite {
    WikiSite *site = [[SiteManager sharedInstance] defaultSite];
    if (![site sameAs:_site]) {
        [self _cancelAllOperations];
        _site = site;
        
        if ([self.results count] != 0) self.results = @[];
        [self request:self.lastIncompleteKeyword];
    }
}

- (void)_removeOperationOfRequest:(NSURLRequest *)request {
    for (AFJSONRequestOperation *op in self.operations) {
        if (op.request == request) {
            [self.operations removeObject:op];
            break;
        }
    }
}

- (void)_cancelAllOperations {
    for (AFJSONRequestOperation *op in self.operations) {
        [op cancel];
    }
}

- (void)_handleNewResults:(id)JSON request:(OpenSearchRequest *)request {
    if (request.tag < _currentTag) return;
    if (![JSON isKindOfClass:[NSArray class]]) return;
    NSArray *arr = (NSArray *)JSON;
    NSArray *theResult = nil;
    for (NSObject *o in arr) {
        if ([o isKindOfClass:[NSArray class]]) {
            theResult = (NSArray *)o;
            break;
        }
    }
    
    if (theResult) {
        _currentTag = request.tag;
        self.results = theResult;
    }
}
@end
