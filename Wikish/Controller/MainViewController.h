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
    kViewStatusChangingLang,
    kViewStatusOtherLang,
    kViewStatusCount
} ViewStatus;

@class WikiPageInfo;
@class WikiSite;

@interface MainViewController : UIViewController {
    ViewStatus _viewStatus;
    
    BOOL        _sectionFinished;
    BOOL        _canLoadThisRequest;
    NSInteger   _jsInjectedCount;
    
    WikiPageInfo *_pageInfo;
    WikiSite     *_currentSite;
    
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

- (IBAction)historyBtnPressed:(id)sender;
- (IBAction)searchBtnPressed:(id)sender;
- (IBAction)otherLangBtnPressed:(id)sender;
- (IBAction)changeLangBtnPressed:(id)sender;


@end
