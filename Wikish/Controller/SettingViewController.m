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
#import "TableViewGestureRecognizer.h"
#import "Button.h"
#import "HelpController.h"
#import "HMSegmentedControl.h"


@interface BottomLineContentView : UIView
@end

@implementation BottomLineContentView

- (void)drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGFloat lineColor[4] = {0.9f, 0.9f, 0.9f, 1.0f};
    CGContextSetStrokeColor(c, lineColor);
    CGContextSetShouldAntialias(c, false);
    CGContextSetLineWidth(c, 0.5);
    CGContextBeginPath(c);
    CGContextMoveToPoint(c, 1.0f, CGRectGetHeight(self.bounds));
    CGContextAddLineToPoint(c, CGRectGetWidth(self.bounds) - 1.0f, CGRectGetHeight(self.bounds));
    CGContextStrokePath(c);
}

@end


@interface SettingViewController ()<UITableViewDataSource, UITableViewDelegate, TableViewGesturePanningRowDelegate>

@property (nonatomic, weak) SiteManager *siteManager;

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
    [self _customizeSettingAppearance];
    [self _localizeTexts];
    // https
    [self.httpsSwitch setOn:[Setting isHttpsUsed] animated:NO];
    
    // expanded
    [self.expanedSwitch setOn:[Setting isInitExpanded] animated:NO];
    
    [self _createHomeSegment];
    
//    self.sitesTable.backgroundColor = GetTableBackgourndColor();
//    self.commonSitesTable.backgroundColor = GetTableBackgourndColor();
    
    
    
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
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)helpButtonPressed:(id)sender {
    HelpController *hCtrl = [HelpController new];
    HelpController * __weak wHCtrl = hCtrl;
    hCtrl.okBlock = ^{
        [wHCtrl dismissModalViewControllerAnimated:YES];
    };
    [self presentModalViewController:hCtrl animated:YES];
}

#pragma mark -
#pragma mark UITableViewDelegate
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    [headerView setBackgroundColor:[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:1.0]];
    UILabel *label = [[UILabel alloc] initWithFrame:headerView.bounds];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0]; //[UIColor whiteColor];
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cid];
        cell.backgroundView = [UIView new];
        cell.backgroundView.backgroundColor = GetTableCellBackgroundColor();
        cell.textLabel.font = [UIFont systemFontOfSize:17.0f];
        
        cell.selectedBackgroundView = [UIView new];
        cell.selectedBackgroundView.backgroundColor = GetHighlightColor();
        
        BottomLineContentView *blcv = [[BottomLineContentView alloc] initWithFrame:cell.contentView.bounds];
        blcv.backgroundColor = [UIColor clearColor];
        blcv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:blcv];
        
    }
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    
    WikiSite *site = [[_siteManager supportedSites] objectAtIndex:indexPath.row];
    cell.textLabel.text = site.name;
    return cell;
}

- (UITableViewCell *)_commonSitesTable_cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cid = @"right";
    UITableViewCell *cell = [_commonSitesTable dequeueReusableCellWithIdentifier:cid];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cid];
        cell.backgroundView = [UIView new];
        cell.backgroundView.backgroundColor = GetTableCellBackgroundColor();
        cell.textLabel.font = [UIFont systemFontOfSize:17.0f];
        
        cell.selectedBackgroundView = [UIView new];
        cell.selectedBackgroundView.backgroundColor = GetHighlightColor();
        
        BottomLineContentView *blcv = [[BottomLineContentView alloc] initWithFrame:cell.contentView.bounds];
        blcv.backgroundColor = [UIColor clearColor];
        blcv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [cell.contentView addSubview:blcv];
    }
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor blackColor];
    
    WikiSite *site = [[_siteManager commonSites] objectAtIndex:indexPath.row];
    if ([site sameAs:[_siteManager defaultSite]]) {
        cell.contentView.backgroundColor = GetHighlightColor();
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    cell.textLabel.text = site.name;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _commonSitesTable) {
        NSUInteger defaultIndex = [_siteManager.commonSites indexOfObject:[_siteManager defaultSite]];
        if (defaultIndex != indexPath.row) {
            [self _unhighlightDefaultSite];
            WikiSite *defaultSiteNew = [_siteManager.commonSites objectAtIndex:indexPath.row];
            [_siteManager setDefaultSite:defaultSiteNew];
        }
        
    } else if (tableView == _sitesTable) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        WikiSite *site = [_siteManager.supportedSites objectAtIndex:indexPath.row];
        [_siteManager addCommonSite:site];
        [_siteManager setDefaultSite:site];
        
        [_commonSitesTable reloadData];
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
        [GetHighlightColor() getRed:&rd green:&gd blue:&bd alpha:NULL];
    } else { // 偏红
        rd = 1.0f, gd = 0.3f, bd = 0.3f;
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
            cell.contentView.backgroundColor = [UIColor whiteColor];//GetTableBackgourndColor();
            [UIView commitAnimations];
        }
        
    } else {
        WikiSite *theSite = [[_siteManager commonSites] objectAtIndex:indexPath.row];
        if (gestureRecognizer.panState == TableViewCellPanStateLeft) {
            if ([[_siteManager commonSites] count] == 1) {
                [UIView beginAnimations:nil context:nil];
                cell.contentView.frame = cell.contentView.bounds;
                [UIView commitAnimations];
                [self gestureRecognizer:gestureRecognizer recoverRowAtIndexPath:indexPath];
            }
            if (![_siteManager removeCommonSite:theSite]) {
                return;
            }
            [self.commonSitesTable beginUpdates];
            [self.commonSitesTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.commonSitesTable endUpdates];
            [self _highlightDefaultSite];
        } else if (gestureRecognizer.panState == TableViewCellPanStateRight) {
            NSIndexPath *indexPath = [self.commonSitesTable indexPathForSelectedRow];
            if (indexPath) {
                [self.commonSitesTable deselectRowAtIndexPath:indexPath animated:NO];
            } else {
                [self _unhighlightDefaultSite];
            }
            [_siteManager setDefaultSite:theSite];
            [self _highlightDefaultSite];
            [UIView beginAnimations:nil context:nil];
            cell.contentView.frame = cell.contentView.bounds;
            [UIView commitAnimations];
        }
    }
}

- (void)gestureRecognizer:(TableViewGestureRecognizer *)gestureRecognizer recoverRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [gestureRecognizer.tableView cellForRowAtIndexPath:indexPath];
    if (gestureRecognizer.tableView == self.sitesTable) {
        [UIView beginAnimations:nil context:nil];
        cell.contentView.backgroundColor =  [UIColor whiteColor];// GetTableBackgourndColor();
        [UIView commitAnimations];
    } else {
        WikiSite *defaultSite = [_siteManager defaultSite];
        WikiSite *theSite = [[_siteManager commonSites] objectAtIndex:indexPath.row];
        [UIView beginAnimations:nil context:nil];
        if ([defaultSite sameAs:theSite]) {
            cell.contentView.backgroundColor = GetHighlightColor();
        } else {
            cell.contentView.backgroundColor = [UIColor whiteColor];// GetTableBackgourndColor();
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
    cell.contentView.backgroundColor = GetHighlightColor();
    cell.textLabel.textColor = [UIColor whiteColor];
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
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.textLabel.textColor = [UIColor blackColor];
    [UIView commitAnimations];
}

- (void)_customizeSettingAppearance {
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGFloat borderWidth = 0.5;
    if (scale == 1.0f) borderWidth = 1;

    [self.httpsSwitch setOnTintColor:[UIColor whiteColor]];
    [self.expanedSwitch setOnTintColor:[UIColor whiteColor]];
    
    self.sitesTable.layer.borderColor = SeperatorColor().CGColor;
    self.sitesTable.layer.borderWidth = borderWidth;
    
    self.commonSitesTable.layer.borderColor = SeperatorColor().CGColor;
    self.commonSitesTable.layer.borderWidth = borderWidth;
    
    self.httpsView.layer.borderColor = SeperatorColor().CGColor;
    self.httpsView.layer.borderWidth = borderWidth;

    self.expanedView.layer.borderColor = SeperatorColor().CGColor;
    self.expanedView.layer.borderWidth = borderWidth;
    
    self.homeView.layer.borderColor = SeperatorColor().CGColor;
    self.homeView.layer.borderWidth = borderWidth;

    
}

- (void)_localizeTexts {
    self.settingLabel.text  = NSLocalizedString(@"Setting", nil);
    self.httpsLabel.text    = NSLocalizedString(@"Use HTTPS", nil);
    self.expanedLabel.text  = NSLocalizedString(@"Section Expanded", nil);
    self.homeLabel.text     = NSLocalizedString(@"Home Page", nil);

}

- (void)_createHomeSegment {
    HMSegmentedControl *segment = [[HMSegmentedControl alloc] initWithSectionTitles:@[NSLocalizedString(@"Blank", nil), NSLocalizedString(@"Extract", nil), NSLocalizedString(@"Last", nil)]];
    segment.frame = self.homePageSwitchPlatform.bounds;
    segment.selectionIndicatorHeight = 0;
    segment.height = CGRectGetHeight(segment.frame);
    segment.selectionIndicatorColor = GetHighlightColor();
    segment.textColor = [UIColor darkGrayColor];
    segment.layer.borderWidth = 0.5;
    segment.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    NSInteger index = (NSInteger)[Setting homePage];
    segment.selectedIndex = index;
    
    segment.indexChangeBlock = ^(NSUInteger index) {
        [Setting setHomePage:index];
    };
    
    [self.homePageSwitchPlatform addSubview:segment];
}

- (void)viewDidUnload {
    [self setHomePageSwitchPlatform:nil];
    [super viewDidUnload];
}
@end
