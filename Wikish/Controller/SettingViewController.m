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

#import "TableViewGestureRecognizer.h"

@interface SettingViewController ()<UITableViewDataSource, UITableViewDelegate, TableViewGesturePanningRowDelegate>

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
    
    [[self.sitesTable enableGestureTableViewWithDelegate:self] retain];
    
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
    cell.contentView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
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

#pragma mark -
#pragma mark TableViewGesturePanningRowDelegate
- (BOOL)gestureRecognizer:(TableViewGestureRecognizer *)gestureRecognizer canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)gestureRecognizer:(TableViewGestureRecognizer *)gestureRecognizer didEnterPanState:(TableViewCellPanState)state forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (gestureRecognizer.tableView == self.sitesTable) {
        UITableViewCell *cell = [self.sitesTable cellForRowAtIndexPath:indexPath];
//        if (gestureRecognizer.swipeState == TableViewCellPanStateLeft) {
//            cell.contentView.backgroundColor = [UIColor redColor];
//        }
        CGFloat left = cell.contentView.frame.origin.x;
        CGFloat color_offset = fabsf(left)/150.0f;
        if (left > 0) {
            cell.contentView.backgroundColor = [UIColor colorWithRed:0.9-color_offset green:0.9 blue:0.9-color_offset alpha:1];
        } else {
            cell.contentView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9-color_offset blue:0.9-color_offset alpha:1];
        }
        
    } else {
        // TODO
    }
    
}
- (void)gestureRecognizer:(TableViewGestureRecognizer *)gestureRecognizer commitPanState:(TableViewCellPanState)state forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (gestureRecognizer.tableView == self.sitesTable) {
        [self.sitesTable beginUpdates];
        [self.sitesTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        WikiSite *theSite = [[_siteManager supportedSites] objectAtIndex:indexPath.row];
        [_siteManager removeSite:theSite];
        [self.sitesTable endUpdates];
    }
}

@end
