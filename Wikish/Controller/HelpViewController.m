//
//  HelpViewController.m
//  Wikish
//
//  Created by YANG ENZO on 13-3-22.
//  Copyright (c) 2013年 Side Trip. All rights reserved.
//

#import "HelpViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"

@interface HelpViewController ()

@end

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = NSLocalizedString(@"Help", nil);
    [self.backBtn setTitle:NSLocalizedString(@"Back", nil) forState:UIControlStateNormal];
    [self _customizeHelpAppearance];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://divisoryang.github.com/ductionary-help.html"]]];
}

- (void)_customizeHelpAppearance {
    self.backBtn.layer.cornerRadius = 6.0f;
    self.backBtn.layer.masksToBounds = YES;
    [self.backBtn setBackgroundColor:DarkGreenColor() forState:UIControlStateNormal];
    [self.backBtn setBackgroundColor:GetTableHighlightRowColor() forState:UIControlStateHighlighted];
    self.backBtn.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.backBtn.layer.shouldRasterize = YES;
}

- (void)dealloc {
    [_backBtn release];
    [_titleLabel release];
    [_webView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setBackBtn:nil];
    [self setTitleLabel:nil];
    [self setWebView:nil];
    [super viewDidUnload];
}
- (IBAction)backBtnPressed:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}
@end
