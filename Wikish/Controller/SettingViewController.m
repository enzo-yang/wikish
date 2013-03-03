//
//  SettingViewController.m
//  Wikish
//
//  Created by YANG ENZO on 13-2-6.
//  Copyright (c) 2013年 Side Trip. All rights reserved.
//

#import "SettingViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
#import "Setting.h"
#import "SiteManager.h"
#import "WikiSite.h"
#import "AutoPropertyRelease.h"
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

- (void)dealloc {
    [AutoPropertyRelease releaseProperties:self thisClass:[SettingViewController class]];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _customizeSettingAppearance];
    [self _localizeTexts];
    // https
    [self.httpsSwitch setOn:[Setting isHttpsUsed] animated:NO];
    
    // expanded
    [self.expanedSwitch setOn:[Setting isInitExpanded] animated:NO];
    
    self.sitesTable.backgroundColor = GetTableBackgourndColor();
    self.commonSitesTable.backgroundColor = GetTableBackgourndColor();
    
    self.sitesGestureRecognizer = [self.sitesTable enableGestureTableViewWithDelegate:self];
    self.sitesGestureRecognizer.blockSide = TableViewCellBlockLeft;
    self.commonSitesGestureRecognizer = [self.commonSitesTable enableGestureTableViewWithDelegate:self];
    
}

- (IBAction)useHttpsSwitchChanged:(UISwitch *)sender {
    [Setting setUseHttps:[sender isOn]];
}

- (IBAction)sectionExpandedSwitchChanged:(UISwitch *)sender {
    [Setting setInitExpanded:[sender isOn]];
}

- (IBAction)okButtonPressed:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UITableViewDelegate
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)] autorelease];
    [headerView setBackgroundColor:DarkGreenColor()];
    UILabel *label = [[[UILabel alloc] initWithFrame:headerView.bounds] autorelease];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize:17.0f];
    [headerView addSubview:label];
    
    if (tableView == _sitesTable) {
        label.text = NSLocalizedString(@"All Language", nil);
    } else {
        label.text = NSLocalizedString(@"Common Use", nil);
    }
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0f;
}

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
        cell.backgroundView = [[UIView new] autorelease];
        cell.backgroundView.backgroundColor = GetTableCellBackgroundColor();
        cell.textLabel.font = [UIFont systemFontOfSize:17.0f];
    }
    cell.contentView.backgroundColor = GetTableBackgourndColor();
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
        cell.backgroundView = [[UIView new] autorelease];
        cell.backgroundView.backgroundColor = GetTableCellBackgroundColor();
        cell.textLabel.font = [UIFont systemFontOfSize:17.0f];
    }
    cell.contentView.backgroundColor = GetTableBackgourndColor();
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    WikiSite *site = [[_siteManager commonSites] objectAtIndex:indexPath.row];
    if ([site sameAs:[_siteManager defaultSite]]) {
        cell.contentView.backgroundColor = GetTableHighlightRowColor();
    }
    cell.textLabel.text = site.name;
    return cell;
}

#pragma mark -
#pragma mark TableViewGesturePanningRowDelegate
- (BOOL)gestureRecognizer:(TableViewGestureRecognizer *)gestureRecognizer canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)gestureRecognizer:(TableViewGestureRecognizer *)gestureRecognizer didEnterPanState:(TableViewCellPanState)state forRowAtIndexPath:(NSIndexPath *)indexPath {
    // 两边的颜色一样
    UITableViewCell *cell = [gestureRecognizer.tableView cellForRowAtIndexPath:indexPath];
    CGFloat left = cell.contentView.frame.origin.x;
    CGFloat color_offset = fabsf(left)/160.0f;
    CGFloat r, g, b; // 正常状态的颜色 rgb
    CGFloat rd, gd, bd; // 目的状态颜色
    CGFloat rv, gv, bv; // rgb 变化权值
    [GetTableBackgourndColor() getRed:&r green:&g blue:&b alpha:NULL];
    if (left > 0) { // 偏绿
        [GetTableHighlightRowColor() getRed:&rd green:&gd blue:&bd alpha:NULL];
    } else { // 偏红
        [[UIColor redColor] getRed:&rd green:&gd blue:&bd alpha:NULL];
    }
    rv = rd-r; gv = gd-g; bv = bd-b;
    
    cell.contentView.backgroundColor = [UIColor colorWithRed:r+color_offset*rv green:g+color_offset*gv blue:b+color_offset*bv alpha:1];
}

- (void)gestureRecognizer:(TableViewGestureRecognizer *)gestureRecognizer commitPanState:(TableViewCellPanState)state forRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [gestureRecognizer.tableView cellForRowAtIndexPath:indexPath];
    if (gestureRecognizer.tableView == self.sitesTable) {
        WikiSite *theSite = [[_siteManager supportedSites] objectAtIndex:indexPath.row];
        
        /* if (gestureRecognizer.panState == TableViewCellPanStateLeft) {
         [self.sitesTable beginUpdates];
         [self.sitesTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
         [_siteManager removeSite:theSite];
         [self.sitesTable endUpdates];
         } else */
        if (gestureRecognizer.panState == TableViewCellPanStateRight) {
            [_siteManager addCommonSite:theSite];
            [self.commonSitesTable reloadData];
            [UIView beginAnimations:nil context:nil];
            cell.contentView.frame = cell.contentView.bounds;
            cell.contentView.backgroundColor = GetTableBackgourndColor();
            [UIView commitAnimations];
        }
        
    } else {
        WikiSite *theSite = [[[_siteManager commonSites] objectAtIndex:indexPath.row] retain];
        if (gestureRecognizer.panState == TableViewCellPanStateLeft) {
            if ([[_siteManager commonSites] count] == 1) {
                [self gestureRecognizer:gestureRecognizer recoverRowAtIndexPath:indexPath];
            }
            if (![_siteManager removeCommonSite:theSite]) return;
            [self.commonSitesTable beginUpdates];
            [self.commonSitesTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.commonSitesTable endUpdates];
            [self _highlightDefaultSite];
        } else if (gestureRecognizer.panState == TableViewCellPanStateRight) {
            [self _unhighlightDefaultSite];
            [_siteManager setDefaultSite:theSite];
            [UIView beginAnimations:nil context:nil];
            cell.contentView.frame = cell.contentView.bounds;
            cell.contentView.backgroundColor = GetTableHighlightRowColor();
            [UIView commitAnimations];
        }
        [theSite release];
    }
}

- (void)gestureRecognizer:(TableViewGestureRecognizer *)gestureRecognizer recoverRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [gestureRecognizer.tableView cellForRowAtIndexPath:indexPath];
    if (gestureRecognizer.tableView == self.sitesTable) {
        [UIView beginAnimations:nil context:nil];
        cell.contentView.backgroundColor = GetTableBackgourndColor();
        [UIView commitAnimations];
    } else {
        WikiSite *defaultSite = [_siteManager defaultSite];
        WikiSite *theSite = [[_siteManager commonSites] objectAtIndex:indexPath.row];
        [UIView beginAnimations:nil context:nil];
        if ([defaultSite sameAs:theSite]) {
            cell.contentView.backgroundColor = GetTableHighlightRowColor();
        } else {
            cell.contentView.backgroundColor = GetTableBackgourndColor();
        }
        [UIView commitAnimations];
    }
}

- (void)_highlightDefaultSite {
    int index = 0;
    for (; index < [_siteManager commonSites].count; ++index) {
        WikiSite *aSite = [[_siteManager commonSites] objectAtIndex:index];
        if ([aSite sameAs:[_siteManager defaultSite]]) break;
    }
    if (index == [_siteManager commonSites].count) return;
    UITableViewCell *cell = [self.commonSitesTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [UIView beginAnimations:nil context:nil];
    cell.contentView.backgroundColor = GetTableHighlightRowColor();
    [UIView commitAnimations];
}

- (void)_unhighlightDefaultSite {
    int index = 0;
    for (; index < [_siteManager commonSites].count; ++index) {
        WikiSite *aSite = [[_siteManager commonSites] objectAtIndex:index];
        if ([aSite sameAs:[_siteManager defaultSite]]) break;
    }
    if (index == [_siteManager commonSites].count) return;
    UITableViewCell *cell = [self.commonSitesTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [UIView beginAnimations:nil context:nil];
    cell.contentView.backgroundColor = GetTableBackgourndColor();
    [UIView commitAnimations];
}

- (void)_customizeSettingAppearance {
    [self.httpsSwitch setOnTintColor:GetTableHighlightRowColor()];
    [self.expanedSwitch setOnTintColor:GetTableHighlightRowColor()];
    
// 统一风格 不要圆角
//    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.httpsView.bounds
//                                                   byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
//                                                         cornerRadii:CGSizeMake(6.0, 6.0)];
//    CAShapeLayer *maskLayer = [CAShapeLayer layer];
//    maskLayer.frame = self.httpsView.bounds;
//    maskLayer.path = maskPath.CGPath;
//    self.httpsView.layer.mask = maskLayer;
//    self.httpsView.layer.masksToBounds = YES;
    self.httpsView.layer.borderColor = SeperatorColor().CGColor;
    self.httpsView.layer.borderWidth = 0.5f;
    
    self.expanedView.layer.borderColor = SeperatorColor().CGColor;
    self.expanedView.layer.borderWidth = 0.5f;
    
    self.okButton.layer.cornerRadius = 6.0f;
    self.okButton.layer.masksToBounds = YES;
    [self.okButton setBackgroundColor:DarkGreenColor()];
    
}

- (void)_localizeTexts {
    [self.okButton setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
    self.settingLabel.text  = NSLocalizedString(@"Setting", nil);
    self.httpsLabel.text    = NSLocalizedString(@"Use HTTPS", nil);
    self.expanedLabel.text  = NSLocalizedString(@"Section Expanded", nil);
}

@end
