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
#import "Button.h"
#import "HelpController.h"



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
    [_helpButton release];
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
    
    [self _refreshHomeButtons];
    
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
    // [self dismissModalViewControllerAnimated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)homeTypeButtonPressed:(id)sender {
    [Setting setHomePage:((UIButton *)sender).tag];
    [self _refreshHomeButtons];
}

- (IBAction)helpButtonPressed:(id)sender {
    HelpController *hCtrl = [[HelpController new] autorelease];
    hCtrl.okBlock = ^{
        [hCtrl dismissModalViewControllerAnimated:YES];
    };
    [self presentModalViewController:hCtrl animated:YES];
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
        label.text = NSLocalizedString(@"Search Language", nil);
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
        
        cell.selectedBackgroundView = [[UIView new] autorelease];
        cell.selectedBackgroundView.backgroundColor = GetTableHighlightRowColor();
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _commonSitesTable) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        NSUInteger defaultIndex = [_siteManager.commonSites indexOfObject:[_siteManager defaultSite]];
        WikiSite *defaultSiteNew = [_siteManager.commonSites objectAtIndex:indexPath.row];
        
        [_siteManager setDefaultSite:defaultSiteNew];
        
        [_commonSitesTable beginUpdates];
        [_commonSitesTable reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:defaultIndex inSection:indexPath.section], indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [_commonSitesTable endUpdates];
        
    }
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
        if (gestureRecognizer.panState == TableViewCellPanStateRight) {
            [_siteManager addCommonSite:theSite];
            [_siteManager setDefaultSite:theSite];
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
            if (![_siteManager removeCommonSite:theSite]) {
                [theSite release];
                return;
            }
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
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.75 alpha:1];
    
    [self.httpsSwitch setOnTintColor:GetTableHighlightRowColor()];
    [self.expanedSwitch setOnTintColor:GetTableHighlightRowColor()];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.httpsView.bounds
                                                   byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                         cornerRadii:CGSizeMake(6.0, 6.0)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.httpsView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.httpsView.layer.mask = maskLayer;
    self.httpsView.layer.borderColor = SeperatorColor().CGColor;
    self.httpsView.layer.borderWidth = 0.5f;
    self.httpsView.layer.rasterizationScale = scale;
    self.httpsView.layer.shouldRasterize = YES;
    
    self.expanedView.layer.borderColor = SeperatorColor().CGColor;
    self.expanedView.layer.borderWidth = 0.5f;
    self.expanedView.layer.rasterizationScale = scale;
    self.expanedView.layer.shouldRasterize = YES;
    
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.homeView.bounds
                                                   byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight
                                                         cornerRadii:CGSizeMake(6.0, 6.0)];
    maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.homeView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.homeView.layer.mask = maskLayer;
    self.homeView.layer.borderColor = SeperatorColor().CGColor;
    self.homeView.layer.borderWidth = 0.5f;
    self.homeView.layer.rasterizationScale = scale;
    self.homeView.layer.shouldRasterize = YES;
    
    self.okButton.layer.cornerRadius = 6.0f;
    self.okButton.layer.masksToBounds = YES;
    [self.okButton setBackgroundColor:DarkGreenColor() forState:UIControlStateNormal];
    [self.okButton setBackgroundColor:GetTableHighlightRowColor() forState:UIControlStateHighlighted];
    self.okButton.layer.rasterizationScale = scale;
    self.okButton.layer.shouldRasterize = YES;
    
    self.helpButton.layer.cornerRadius = 6.0f;
    self.helpButton.layer.masksToBounds = YES;
    [self.helpButton setBackgroundColor:DarkGreenColor() forState:UIControlStateNormal];
    [self.helpButton setBackgroundColor:GetTableHighlightRowColor() forState:UIControlStateHighlighted];
    self.helpButton.layer.rasterizationScale = scale;
    self.helpButton.layer.shouldRasterize = YES;
    
    for (Button *btn in self.homeButtons) {
        [btn setBackgroundColor:GetDarkColor() forState:UIControlStateNormal];
        [btn setBackgroundColor:DarkGreenColor() forState:UIControlStateSelected];
        [btn setBackgroundColor:GetTableHighlightRowColor() forState:UIControlStateHighlighted];
    }
    
    Button *leftBtn = [self.homeButtons objectAtIndex:0];
    maskPath = [UIBezierPath bezierPathWithRoundedRect:leftBtn.bounds
                                     byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerTopLeft
                                           cornerRadii:CGSizeMake(4.0, 4.0)];
    maskLayer = [CAShapeLayer layer];
    maskLayer.frame = leftBtn.bounds;
    maskLayer.path = maskPath.CGPath;
    leftBtn.layer.mask = maskLayer;
    leftBtn.layer.rasterizationScale = scale;
    leftBtn.layer.shouldRasterize = YES;
    
    Button *rightBtn = [self.homeButtons lastObject];
    maskPath = [UIBezierPath bezierPathWithRoundedRect:rightBtn.bounds
                                     byRoundingCorners:UIRectCornerBottomRight | UIRectCornerTopRight
                                           cornerRadii:CGSizeMake(4.0, 4.0)];
    maskLayer = [CAShapeLayer layer];
    maskLayer.frame = leftBtn.bounds;
    maskLayer.path = maskPath.CGPath;
    rightBtn.layer.mask = maskLayer;
    rightBtn.layer.rasterizationScale = scale;
    rightBtn.layer.shouldRasterize = YES;
    
}

- (void)_localizeTexts {
    [self.okButton setTitle:NSLocalizedString(@"OK", nil) forState:UIControlStateNormal];
    [self.helpButton setTitle:NSLocalizedString(@"Help", nil) forState:UIControlStateNormal];
    self.settingLabel.text  = NSLocalizedString(@"Setting", nil);
    self.httpsLabel.text    = NSLocalizedString(@"Use HTTPS", nil);
    self.expanedLabel.text  = NSLocalizedString(@"Section Expanded", nil);
    self.homeLabel.text     = NSLocalizedString(@"Home Page", nil);
    [(UIButton *)[self.homeButtons objectAtIndex:0] setTitle:NSLocalizedString(@"Blank", nil) forState:UIControlStateNormal];
    [(UIButton *)[self.homeButtons objectAtIndex:1] setTitle:NSLocalizedString(@"Extract", nil) forState:UIControlStateNormal];
    [(UIButton *)[self.homeButtons objectAtIndex:2] setTitle:NSLocalizedString(@"Last", nil) forState:UIControlStateNormal];
}

- (void)_refreshHomeButtons {
    NSInteger index = (NSInteger)[Setting homePage];
    for (Button *btn in self.homeButtons) {
        btn.selected = NO;
    }
    ((Button*)[self.homeButtons objectAtIndex:index]).selected = YES;
}

- (void)viewDidUnload {
    [self setHelpButton:nil];
    [super viewDidUnload];
}
@end
