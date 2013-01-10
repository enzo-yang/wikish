//
//  MainViewController.m
//  Wikish
//
//  Created by YANG ENZO on 12-11-10.
//  Copyright (c) 2012年 Side Trip. All rights reserved.
//

#import "MainViewController.h"
#import "WikiSite.h"
#import "SiteManager.h"
#import "WikiPage.h"

@interface MainViewController ()<WikiPageDelegate>

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    WikiSite *site = [[SiteManager sharedInstance] siteOfLang:@"zh"];
    WikiPage *page = [[WikiPage alloc] initWithSite:site title:@"恐龙"];
    page.delegate = self;
    [page loadPage];
}

- (void)wikiPageLoadSuccess:(WikiPage *)wikiPage {
    NSLog(@"%@", [wikiPage pageHTML]);
    [self.webView loadHTMLString:[wikiPage pageHTML] baseURL:[NSURL URLWithString:@"https://zh.m.wiki.org"]];
}

- (void)wikiPageLoadFailed:(WikiPage *)wikiPage error:(NSError *)error {
    NSLog(@"wiki page load failed");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_webView release];
    [super dealloc];
}
@end
