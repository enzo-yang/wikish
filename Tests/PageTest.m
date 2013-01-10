//
//  PageTest.m
//  Wikish
//
//  Created by YANG ENZO on 12-11-16.
//  Copyright (c) 2012年 Side Trip. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "SiteManager.h"
#import "WikiPage.h"
#import "WikiSite.h"

@interface PageTest : GHTestCase

@end


@implementation PageTest

- (BOOL)shouldRunOnMainThread {
    // By default NO, but if you have a UI test or test dependent on running on the main thread return YES
    return NO;
}

- (void)setUpClass {
    // Run at start of all tests in the class
}

- (void)tearDownClass {
    // Run at end of all tests in the class
}

- (void)setUp {
    // Run before each test method
}

- (void)tearDown {
    // Run after each test method
}

- (void)testContentApi {
    WikiSite *site = [[SiteManager instance] siteWithCode:@"zh"];
    WikiPage *page = [[WikiPage alloc] initWithSite:site title:@"树"];
    [page loadPage];
    [NSThread sleepForTimeInterval:10];
}

//- (void)testFoo {
//    NSString *a = @"foo";
//    GHTestLog(@"I can log to the GHUnit test console: %@", a);
//    
//    // Assert a is not NULL, with no custom error description
//    GHAssertNotNULL(a, nil);
//    
//    // Assert equal objects, add custom error description
//    NSString *b = @"bar";
//    GHAssertEqualObjects(a, b, @"A custom error message. a should be equal to: %@.", b);
//}
//
//- (void)testBar {
//    GHAssertTrue(TRUE, @"Yes it worked");
//}


@end
