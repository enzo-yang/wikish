//
//  FirstLaunchHelpController.m
//  Wikish
//
//  Created by ENZO YANG on 13-4-12.
//  Copyright (c) 2013年 Side Trip. All rights reserved.
//

#import "HelpController.h"

@interface HelpController ()<UIScrollViewDelegate>

@end

@implementation HelpController

- (id)initWithShouldShowAdvicePage:(BOOL)should {
    self = [super init];
    if (self) {
        _shouldShowAdvicePage = should;
    }
    return self;
}

- (void)viewDidLoad {
    int pages = 3;
    if (_shouldShowAdvicePage) pages = 4;
    
    self.scroller.contentSize = CGSizeMake(CGRectGetWidth(self.scroller.bounds) * pages, CGRectGetHeight(self.scroller.bounds));
    [self.scroller addSubview:self.page1];
}

- (void)viewDidAppear:(BOOL)animated {
    if (![self.page2 superview]) {
        CGFloat scrollerWidth = CGRectGetWidth(self.scroller.bounds);
        CGFloat scrollerHeight = CGRectGetHeight(self.scroller.bounds);
        
        self.scroller.contentSize = CGSizeMake(self.scroller.contentSize.width, scrollerHeight);
        self.page1.frame = CGRectMake(0, 0, scrollerWidth, scrollerHeight);
        
        self.page2.frame = CGRectMake(scrollerWidth, 0, scrollerWidth, scrollerHeight);
        [self.scroller addSubview:self.page2];
        
        self.page3.frame = CGRectMake(scrollerWidth * 2, 0, scrollerWidth, scrollerHeight);
        [self.scroller addSubview:self.page3];
        
        if (_shouldShowAdvicePage) {
            self.adviceView.frame = CGRectMake(scrollerWidth * 3, 0, scrollerWidth, scrollerHeight);
            [self.scroller addSubview:self.adviceView];
        }
        
        self.pageControl = [[StyledPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 20, scrollerWidth, 10)];
        self.pageControl.diameter = 8.0f;
        self.pageControl.coreNormalColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0f];
        self.pageControl.coreSelectedColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0f];
        self.pageControl.numberOfPages = self.scroller.contentSize.width / scrollerWidth;
        [self.view addSubview:self.pageControl];
    }
}

- (void)viewDidUnload {
    [self setScroller:nil];
    [self setPage1:nil];
    [self setPage2:nil];
    [self setPage3:nil];
    [self setPageControl:nil];
    [self setAdviceView:nil];
    [super viewDidUnload];
}

- (IBAction)okPressed:(id)sender {
    if (self.okBlock) {
        self.okBlock();
    }
    self.okBlock = nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    if (offsetX < 0) {
        self.pageControl.currentPage = 0;
        return;
    }
    if (offsetX > scrollView.contentSize.width) {
        self.pageControl.currentPage = self.pageControl.numberOfPages - 1;
        return;
    }
    
    self.pageControl.currentPage = (int)(offsetX / scrollView.bounds.size.width);
}
@end
