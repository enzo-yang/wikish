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



@end
