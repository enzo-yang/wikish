//
//  FirstLaunchHelpController.m
//  Wikish
//
//  Created by ENZO YANG on 13-4-12.
//  Copyright (c) 2013年 Side Trip. All rights reserved.
//

#import "HelpController.h"

@interface HelpController ()

@end

@implementation HelpController

- (IBAction)okPressed:(id)sender {
    if (self.okBlock) {
        self.okBlock();
    }
    self.okBlock = nil;
}

- (void)viewDidLoad {
    self.scroller.contentSize = self.content.bounds.size;
    [self.scroller addSubview:self.content];
}

- (void)dealloc {
    [_scroller release];
    [_content release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setScroller:nil];
    [self setContent:nil];
    [super viewDidUnload];
}
@end
