//
//  MainViewController.h
//  Wikish
//
//  Created by YANG ENZO on 12-11-10.
//  Copyright (c) 2012年 Side Trip. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kViewStatusNormal,
    kViewStatusHistory,
    kViewStatusSection,
    kViewStatusLightness,
    kViewStatusCount
} ViewStatus;

@class WikiPageInfo;
@class WikiSite;
@class HistoryTableController;
@class SectionTableController;
@class FavouriteTableController;

@interface MainViewController : UIViewController {
    ViewStatus _viewStatus;
    
    BOOL        _canLoadThisRequest;
    
    WikiPageInfo * _pageInfo;
    WikiSite     *_currentSite;
    
    NSMutableDictionary *_pageInfos;
    
    // layouts
    CGFloat     _lastWebViewOffset;
    CGFloat     _webViewOrgHeight;
    CGFloat     _webViewOrgY;
    CGFloat     _webViewDragOrgY;
    BOOL        _headViewHided;
}
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *leftView;
@property (weak, nonatomic) IBOutlet UIView *middleView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *lightnessMask;
@property (weak, nonatomic) IBOutlet UIView *gestureMask;

@property (strong, nonatomic) IBOutlet UIView *lightnessView;

@property (weak, nonatomic) IBOutlet UITableView *historyTable;
@property (strong, nonatomic) HistoryTableController *historyController;
@property (weak, nonatomic) IBOutlet UITableView *sectionTable;
@property (strong, nonatomic) SectionTableController *sectionController;


@property (weak, nonatomic) IBOutlet UIButton *backwardButton;
@property (weak, nonatomic) IBOutlet UIButton *forewardButton;

@property (strong, readonly, nonatomic) WikiPageInfo *pageInfo;

- (IBAction)historyBtnPressed:(id)sender;
- (IBAction)searchBtnPressed:(id)sender;
- (IBAction)sectionBtnPressed:(id)sender;
- (IBAction)settingBtnPressed:(id)sender;
- (IBAction)moreActionBtnPressed:(id)sender;
- (IBAction)lightnessUpBtnPressed:(id)sender;
- (IBAction)lightnessDownBtnPressed:(id)sender;
- (IBAction)browseBackPressed:(id)sender;
- (IBAction)browseForwardPressed:(id)sender;
- (IBAction)dragMiddleViewBackGesture:(UIPanGestureRecognizer *)sender;
- (IBAction)tapMiddleViewBackGesture:(UITapGestureRecognizer *)sender;


- (void)scrollTo:(NSString *)anchorPoint;
- (void)loadSite:(WikiSite *)site title:(NSString *)theTitle;


@end
