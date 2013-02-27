//
//  SettingViewController.m
//  Wikish
//
//  Created by YANG ENZO on 13-2-6.
//  Copyright (c) 2013年 Side Trip. All rights reserved.
//

#import "SettingViewController.h"
#import "Constants.h"
#import "SiteManager.h"
#import "WikiSite.h"

@interface SettingViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) SiteManager *siteManager;

@end

@implementation SettingViewController

- (id)init {
    self = [super init];
    if (self) {
        self.siteManager = [SiteManager sharedInstance];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // https
    NSNumber *useHttps = [defaults objectForKey:kUserDefaultsUseHttpsKey];
    [self.httpsSwitch setOn:[useHttps boolValue] animated:NO];
    
    // expanded
    NSNumber *expanded = [defaults objectForKey:kUserDefaultsIsInitExpandedKey];
    [self.expanedSwitch setOn:[expanded boolValue] animated:NO];
    
}

- (IBAction)useHttpsSwitchChanged:(UISwitch *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:[sender isOn] forKey:kUserDefaultsUseHttpsKey];
    [defaults synchronize];
}

- (IBAction)sectionExpandedSwitchChanged:(UISwitch *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:[sender isOn] forKey:kUserDefaultsIsInitExpandedKey];
    [defaults synchronize];
}

#pragma mark -
#pragma mark UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _sitesTable) {
        return [self _sitesTable_numberOfRowsInSection:section];
    } else {
        return [self _commonSitesTable_numberOfRowsInSection:section];
    }
}

- (NSInteger)_sitesTable_numberOfRowsInSection:(NSInteger)section {
    return [[_siteManager supportedSites] count];
}

- (NSInteger)_commonSitesTable_numberOfRowsInSection:(NSInteger)section {
    return [[_siteManager commonSites] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _sitesTable) {
        return [self _sitesTable_cellForRowAtIndexPath:indexPath];
    } else {
        return [self _commonSitesTable_cellForRowAtIndexPath:indexPath];
    }
}

- (UITableViewCell *)_sitesTable_cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cid = @"left";
    UITableViewCell *cell = [_sitesTable dequeueReusableCellWithIdentifier:cid];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cid] autorelease];
    }
    WikiSite *site = [[_siteManager supportedSites] objectAtIndex:indexPath.row];
    cell.textLabel.text = site.name;
    return cell;
}

- (UITableViewCell *)_commonSitesTable_cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cid = @"right";
    UITableViewCell *cell = [_commonSitesTable dequeueReusableCellWithIdentifier:cid];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cid] autorelease];
    }
    WikiSite *site = [[_siteManager commonSites] objectAtIndex:indexPath.row];
    cell.textLabel.text = site.name;
    return cell;
}
@end
