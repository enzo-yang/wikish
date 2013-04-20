//
//  AdviceViewController.m
//  Wikish
//
//  Created by YANG ENZO on 13-4-20.
//  Copyright (c) 2013年 Side Trip. All rights reserved.
//

#import "AdviceViewController.h"

@interface AdviceViewController ()

@end

@implementation AdviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *htmlString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ducky_advice" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
    [self.webview loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"http://divisoryang.github.io/ductionary/ducky_advice.html"]];
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload {
    [self setWebview:nil];
    [super viewDidUnload];
}

- (void)dealloc {
    NSLog(@"advice controller dealloced");
}
@end
