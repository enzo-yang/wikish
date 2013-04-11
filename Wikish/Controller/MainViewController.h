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
    BOOL        _isForwardOrBackward;
    
    WikiPageInfo *_pageInfo;
    WikiSite     *_currentSite;
    
    NSMutableDictionary *_pageInfos;
    
    // layouts
    CGFloat     _lastWebViewOffset;
    CGFloat     _webViewOrgHeight;
    CGFloat     _webViewOrgY;
    CGFloat     _webViewDragOrgY;
    BOOL        _headViewHided;
}
@property (retain, nonatomic) IBOutlet UIWebView *webView;
@property (retain, nonatomic) IBOutlet UIView *leftView;
@property (retain, nonatomic) IBOutlet UIView *middleView;
@property (retain, nonatomic) IBOutlet UIView *rightView;
@property (retain, nonatomic) IBOutlet UIView *bottomView;
@property (retain, nonatomic) IBOutlet UIView *headerView;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIView *lightnessView;
@property (retain, nonatomic) IBOutlet UIView *lightnessMask;

@property (retain, nonatomic) IBOutlet UITableView *historyTable;
@property (retain, nonatomic) HistoryTableController *historyController;
@property (retain, nonatomic) IBOutlet UITableView *sectionTable;
@property (retain, nonatomic) SectionTableController *sectionController;
@property (retain, nonatomic) IBOutlet UITableView *favouriteTable;
@property (retain, nonatomic) FavouriteTableController *favouriteController;

@property (readonly, nonatomic) WikiPageInfo *pageInfo;

- (IBAction)historyBtnPressed:(id)sender;
- (IBAction)searchBtnPressed:(id)sender;
- (IBAction)sectionBtnPressed:(id)sender;
- (IBAction)lightnessBtnPressed:(id)sender;
- (IBAction)settingBtnPressed:(id)sender;
- (IBAction)lightnessUpBtnPressed:(id)sender;
- (IBAction)lightnessDownBtnPressed:(id)sender;
- (IBAction)browseBackPressed:(id)sender;
- (IBAction)browseForwardPressed:(id)sender;

- (void)scrollTo:(NSString *)anchorPoint;
- (void)loadSite:(WikiSite *)site title:(NSString *)theTitle;


@end
