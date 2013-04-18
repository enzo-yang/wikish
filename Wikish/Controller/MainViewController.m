//
//  MainViewController.m
//  Wikish
//
//  Created by YANG ENZO on 12-11-10.
//  Copyright (c) 2012年 Side Trip. All rights reserved.
//

#import "MainViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "RegexKitLite.h"
#import "SVProgressHUD.h"

#import "Constants.h"
#import "WikiSite.h"
#import "SiteManager.h"
#import "WikiPageInfo.h"
#import "WikiHistory.h"
#import "NSString+Wikish.h"
#import "TapDetectingWindow.h"
#import "WikiSearchPanel.h"

#import "SettingViewController.h"
#import "Setting.h"

#import "HistoryTableController.h"
#import "SectionTableController.h"

#import "InjectScriptManager.h"

#import "GAI.h"

#define kScrollViewDirectionNone    0
#define kScrollViewDirectionUp      1
#define kScrollViewDirectionDown    2

#define kHandleDragThreshold        150

@interface MainViewController ()<WikiPageInfoDelegate, UIWebViewDelegate, UIScrollViewDelegate, TapDetectingWindowDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate>
@property (strong, readwrite, nonatomic) WikiPageInfo  *pageInfo;
@property (nonatomic, strong) WikiSite      *currentSite;
@end

@implementation MainViewController

@synthesize pageInfo = _pageInfo;
@synthesize currentSite = _currentSite;


- (id)init {
    self = [super init];
    if (self) {
        _canLoadThisRequest = NO;
        _pageInfos = [NSMutableDictionary new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView.delegate = self;
    self.webView.scrollView.showsHorizontalScrollIndicator = NO;
    self.webView.scrollView.bounces = NO;
    self.webView.scrollView.delegate = self;
    
    self.leftView.hidden = YES;
    self.gestureMask.hidden = YES;
    
    [self _initializeTables];
    [self _customizeAppearance];
    
    self.titleLabel.text = NSLocalizedString(@"Blank", nil);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_loadPageFromNotification:) name:kNotificationMessageSearchKeyword object:nil];
    
    [self _loadHomePage];
    [self _updateBackwardForwardButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self _windowBeginDetectWebViewTap];
    
    if ([Setting isInitExpanded]) {
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"disable_toggling()"]];
    } else {
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"enable_toggling()"]];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 只有显示后的大小才是正确的
    if (_webViewOrgHeight == 0.0f) {
        _webViewOrgHeight   = self.webView.frame.size.height;
        _webViewOrgY        = self.webView.frame.origin.y;
        _headViewHided = NO;
    }
    // 下面这句如果放在view did load 在 ipod 4 上会显示不出webview
    [self.webView.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self _windowEndDetectWebViewTap];
    [self.webView.scrollView removeObserver:self forKeyPath:@"contentSize"];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self _windowEndDetectWebViewTap];
}

- (void)_windowBeginDetectWebViewTap {
    TapDetectingWindow *window = (TapDetectingWindow *)[[UIApplication sharedApplication].windows objectAtIndex:0];
    window.viewToObserve = self.webView;
    window.controllerThatObserves = self;
}

- (void)_windowEndDetectWebViewTap {
    TapDetectingWindow *window = (TapDetectingWindow *)[[UIApplication sharedApplication].windows objectAtIndex:0];
    window.viewToObserve = nil;
    window.controllerThatObserves = nil;
}

#pragma mask -
#pragma mask load page logic

- (void)_loadPageFromNotification:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    NSString *keyword = [info objectForKey:@"keyword"];
    
    if (!keyword) return;
    WikiSite *site = [[SiteManager sharedInstance] defaultSite];
    [self loadSite:site title:keyword];
}

- (void)_loadHomePage {
    if ([Setting homePage] == kHomePageTypeRecommend) {
        [self loadSite:[SiteManager sharedInstance].defaultSite title:@""];
        [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:kGAUserHabit withAction:kGAHomePage withLabel:@"Feature" withValue:@1];
    } else if ([Setting homePage] == kHomePageTypeHistory) {
        WikiRecord *record = [[WikiHistory sharedInstance] lastRecord];
        if (record) [self loadSite:record title:record.title];
        [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:kGAUserHabit withAction:kGAHomePage withLabel:@"Last" withValue:@1];
    } else {
        [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:kGAUserHabit withAction:kGAHomePage withLabel:@"Blank" withValue:@1];
        ;
    }
}

- (void)loadSite:(WikiSite *)site title:(NSString *)theTitle {
    if (_viewStatus != kViewStatusNormal) [self _recoverNormalStatus];
    
    NSString *title = [theTitle urlDecodedString];
    WikiPageInfo *aPageInfo = [[WikiPageInfo alloc] initWithSite:site title:title];
    if (aPageInfo) {
        [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:kGAUserHabit withAction:kGALaunguage withLabel:site.name withValue:@1];
        self.pageInfo = aPageInfo;
        NSURLRequest *request = [NSURLRequest requestWithURL:[aPageInfo pageURL]];
        if (request) {
            if ([theTitle isEqualToString:@""]) {
                self.titleLabel.text = NSLocalizedString(@"Home_Page", nil);
            } else {
                self.titleLabel.text = [theTitle urlDecodedString];
                self.titleLabel.text = [self.titleLabel.text stringByReplacingOccurrencesOfString:@"_" withString:@" "];
            }
            self.currentSite        = site;
            _canLoadThisRequest     = YES;
            WikiRecord *record      = [[WikiRecord alloc] initWithSite:site title:title];
            [[WikiHistory sharedInstance] addRecord:record];
            
            [self.pageInfo loadPageInfo];
            [self.webView loadRequest:[NSURLRequest requestWithURL:[aPageInfo pageURL]]];
        }
    } else {
        // TODO notify mistakes
    }
}

- (WikiSite *)_siteFromURLString:(NSString *)absolute {
    NSString *lang = [absolute stringByMatching:@"(?<=//).*(?=\\.m\\.wikipedia)" capture:0];
    NSString *subLang = [absolute stringByMatching:@"(?<=wikipedia.org/).*(?=/)" capture:0];
    LOG(@"%@, %@", lang, subLang);
    WikiSite *site = [[SiteManager sharedInstance] siteOfLang:lang subLang:subLang];
    if (!site) site = [[WikiSite alloc] initWithLang:lang sublang:subLang];
    return site;
}

- (NSString *)_keyOfSite:(WikiSite *)site title:(NSString *)title {
    return [NSString stringWithFormat:@"%@%@", site.name, title];
}

- (void)setPageInfo:(WikiPageInfo *)pageInfo {
    if (_pageInfo == pageInfo) return;
    if (_pageInfo) {
        _pageInfo.delegate = nil;
    }
    if (pageInfo) {
        pageInfo.delegate = self;
    }
    _pageInfo = pageInfo;
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentSize"]) {
        [self _scrollViewContentSizeChanged];
    }
}

- (void)_scrollViewContentSizeChanged {
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
    // [self scrollViewDidScroll:self.webView.scrollView];

    [self.webView stringByEvaluatingJavaScriptFromString:[InjectScriptManager script]];
    
    if ([Setting isInitExpanded]) {
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"disable_toggling()"]];
    }
    
    UIScrollView *scrollView = self.webView.scrollView;
    [scrollView setContentOffset:CGPointMake(0, scrollView.contentOffset.y < 50.0f ? 50.0f :scrollView.contentOffset.y)];

}

- (void)wikiPageInfoLoadSuccess:(WikiPageInfo *)wikiPage {
    [_pageInfos setObject:wikiPage forKey:[self _keyOfSite:wikiPage.site title:wikiPage.title]];
    LOG(@"load success");
}

- (void)wikiPageInfoLoadFailed:(WikiPageInfo *)wikiPage error:(NSError *)error {
    LOG(@"page info load failed");
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    LOG(@"%@", request);
    if (_canLoadThisRequest) {
        _canLoadThisRequest = NO;
        [self _hideHeadView:NO];
        [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeClear];
        return YES;
    }
    if ([self _isSameAsCurrentRequest:request]) return NO;
    
    NSString *absolute = [[request URL] absoluteString];
    
    // 前进后退
    if (UIWebViewNavigationTypeBackForward == navigationType) {
        self.titleLabel.text = [[absolute lastPathComponent] urlDecodedString];
        WikiSite *site = [self _siteFromURLString:absolute];
        if ([self.titleLabel.text isEqualToString:site.sublang]) {
            self.titleLabel.text = NSLocalizedString(@"Home_Page", nil);
        }
        if (site) {
            WikiPageInfo *info = [_pageInfos objectForKey:[self _keyOfSite:site title:self.titleLabel.text]];
            if (!info) {
                info = [[WikiPageInfo alloc] initWithSite:site title:self.titleLabel.text];
            }
            self.pageInfo = info;
            
        }
        self.titleLabel.text = [self.titleLabel.text stringByReplacingOccurrencesOfString:@"_" withString:@" "];
        [self _hideHeadView:NO];
        [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeClear];
        return YES;
    }
    
    // 如果是当前的语言
    NSRange range = [absolute rangeOfString:[NSString stringWithFormat:@"%@.m.wikipedia.org/wiki", _currentSite.lang]];
    if (range.length) {
        NSString *anotherTitle = [absolute lastPathComponent];
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self loadSite:_currentSite title:anotherTitle];
        });
        return NO;
    }
    // 如果是其它语言
    range = [absolute rangeOfString:@"m.wikipedia.org/"];
    if (range.length) {
        NSString *title = [absolute lastPathComponent];
        LOG(@"title :%@", title);
        WikiSite *site = [self _siteFromURLString:absolute];
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self loadSite:site title:title];
        });
        return NO;
    }
    [[UIApplication sharedApplication] openURL:[request URL]];
    return NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
    [self _updateBackwardForwardButton];
    
    LOG(@"webview finish load");
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    LOG(@"webview failed to load web page, %@", webView.request);
    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"page load failed", nil)];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    // 限制不能左右滚动 以及 头部offset 大于55
    [scrollView setContentOffset:CGPointMake(0, scrollView.contentOffset.y < 55.0f ? 55.0f :scrollView.contentOffset.y)];
    
    CGFloat offsetY = scrollView.contentOffset.y;
    // 控制显示隐藏顶栏
    NSInteger direction = [self _analyseScrollDirection:scrollView];
    if (offsetY < kHandleDragThreshold && direction == kScrollViewDirectionDown) {
        // 显示顶栏
        [self _hideHeadView:NO];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _webViewDragOrgY = scrollView.contentOffset.y;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    // LOG(@"velocity:(%f, %f), offset:(%f, %f)", velocity.x, velocity.y, (*targetContentOffset).x, (*targetContentOffset).y);
    CGFloat currentY = scrollView.contentOffset.y;
    if (currentY > kHandleDragThreshold && currentY > _webViewDragOrgY) { // content direction up
        [self _hideHeadView:YES];
    } 
}

- (void)userDidTapWebView:(id)tapPoint {
    if (_viewStatus != kViewStatusNormal) {
        [self _recoverNormalStatus];
        return;
    }
    
    UIScrollView *scrollView = self.webView.scrollView;
    if (!scrollView) return;
    
    [self _hideHeadView:!_headViewHided];
}

- (void)scrollTo:(NSString *)anchorPoint {
    NSString *result = [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"scroll_to_section(\"%@\")", anchorPoint]];
    if ([result isEqualToString:@"YES"]) {
        [self _hideHeadView:YES];
    }
    [self _recoverNormalStatus];
}

- (BOOL)_isSameAsCurrentRequest:(NSURLRequest *)request {
    NSString *urlstring = [request URL].absoluteString;
    urlstring = [urlstring urlDecodedString];
    NSRange range = [urlstring rangeOfString:@"#"];
    return (range.length != 0);
}

- (IBAction)historyBtnPressed:(id)sender {
    if (_viewStatus != kViewStatusNormal) {
        [self _recoverNormalStatus];
    } else {
        [self.historyTable reloadData];
        _viewStatus = kViewStatusHistory;
        self.leftView.hidden = NO;
        CGRect f = self.middleView.frame;
        f.origin.x += 260.0f;
        [UIView animateWithDuration:0.3 animations:^{
            self.middleView.frame = f;
        } completion:^(BOOL finished) {
            self.gestureMask.hidden = NO;
        }];
    }
}

- (IBAction)searchBtnPressed:(id)sender {
    if (_viewStatus != kViewStatusNormal) {
        [self _recoverNormalStatus];
        return;
    }
    [WikiSearchPanel showInView:self.view];
}

- (IBAction)sectionBtnPressed:(id)sender {
    if (_viewStatus != kViewStatusNormal) {
        [self _recoverNormalStatus];
    } else {
        [self.sectionTable reloadData];
        _viewStatus = kViewStatusSection;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        CGRect f = self.bottomView.frame;
        f.origin.y -= 230.0f;
        self.bottomView.frame = f;
        [UIView commitAnimations];
    }
}

- (IBAction)settingBtnPressed:(id)sender {
    if (_viewStatus != kViewStatusNormal) {
        [self _recoverNormalStatus];
        return;
    }
    SettingViewController *svc = [SettingViewController new];
    [self.navigationController pushViewController:svc animated:YES];
    
}

- (IBAction)moreActionBtnPressed:(id)sender {
    if (_viewStatus != kViewStatusNormal) {
        [self _recoverNormalStatus];
        return;
    }
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Lightness Control", nil), NSLocalizedString(@"Copy Link", nil), nil];
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        _viewStatus = kViewStatusLightness;
        [self _showLightnessView];
    } else if (buttonIndex == 1) {
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        pb.string = [[self.pageInfo pageURL] absoluteString];
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"link was copied", nil)];
    } else {
        NSLog(@"cancel");
    }
}

- (IBAction)lightnessUpBtnPressed:(id)sender {
    [Setting lightnessUp];
    self.lightnessMask.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:[Setting lightnessMaskValue]];
}

- (IBAction)lightnessDownBtnPressed:(id)sender {
    [Setting lightnessDown];
    self.lightnessMask.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:[Setting lightnessMaskValue]];
}

- (void)_showLightnessView {
    self.lightnessView.center = CGPointMake(CGRectGetWidth(self.view.bounds)/2, CGRectGetHeight(self.view.bounds)/2);
    self.lightnessView.alpha = 0.0f;
    [self.view addSubview:self.lightnessView];
    [UIView animateWithDuration:0.3f animations:^{
        self.lightnessView.alpha = 1.0f;
    }];
    
}

- (void)_hideLightnessView {
    [UIView animateWithDuration:0.3f animations:^{
        self.lightnessView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self.lightnessView removeFromSuperview];
    }];
}

- (IBAction)browseBackPressed:(id)sender {
    [self.webView goBack];
}

- (IBAction)browseForwardPressed:(id)sender {
    [self.webView goForward];
}

- (IBAction)dragMiddleViewBackGesture:(UIPanGestureRecognizer *)sender {
    static float orgX = 0;
    if (sender.state == UIGestureRecognizerStateBegan) {
        orgX = CGRectGetMinX(self.middleView.frame);
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [sender translationInView:self.view];
        if (translation.x < 0) {
            CGRect f = self.middleView.frame;
            f.origin.x = orgX + translation.x;
            self.middleView.frame = f;
        }
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        [self _recoverNormalStatus];
    }
}

- (IBAction)tapMiddleViewBackGesture:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        [self _recoverNormalStatus];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return !gestureRecognizer.view.hidden;
}

- (void)_initializeTables {
    self.historyTable.backgroundColor = GetTableBackgourndColor();
    self.sectionTable.backgroundColor = GetTableBackgourndColor();
    
    self.historyController = [HistoryTableController new];
    [self.historyController setTableView:self.historyTable andMainController:self];
    
    self.sectionController = [SectionTableController new];
    [self.sectionController setTableView:self.sectionTable andMainController:self];
    
}

- (void)_recoverNormalStatus {
    UIView *theViewShouldChangeFrame = nil;
    UIView *theViewShouldHide = nil;
    CGRect f;
    CGFloat duration = 0.3f;
    ViewStatus viewStatus = _viewStatus;
    _viewStatus = kViewStatusNormal;
    
    if (viewStatus == kViewStatusHistory) {
        f = self.middleView.frame;
        duration = 0.3 * (f.origin.x/10) / 26;
        f.origin.x = 0;
        theViewShouldHide = self.leftView;
        theViewShouldChangeFrame = self.middleView;
    } else if (viewStatus == kViewStatusSection) {
        f = self.bottomView.frame;
        f.origin.y += 230.0f;
        theViewShouldChangeFrame = self.bottomView;
    } else if (viewStatus == kViewStatusLightness) {
        [self _hideLightnessView];
        return;
    }
    
    [UIView animateWithDuration:duration animations:^(){
        theViewShouldChangeFrame.frame = f;
    }completion:^(BOOL finished) {
        if (theViewShouldHide) theViewShouldHide.hidden = YES;
        self.gestureMask.hidden = YES;
    }];
    

}

- (NSInteger)_analyseScrollDirection:(UIScrollView *)scrollView {
    NSInteger scrollDirection = kScrollViewDirectionNone;
    if (_lastWebViewOffset > scrollView.contentOffset.y)
        scrollDirection = kScrollViewDirectionDown;
    else if (_lastWebViewOffset < scrollView.contentOffset.y)
        scrollDirection = kScrollViewDirectionUp;
    
    _lastWebViewOffset = scrollView.contentOffset.y;
    return scrollDirection;
}

- (void)_hideHeadView:(BOOL)hide {
    @synchronized(self) {
        if (hide == _headViewHided) return;
        
        CGPoint hidePoint = CGPointMake(0, -self.headerView.frame.size.height);
        CGRect headFrame = self.headerView.frame;
        if (hide)
            headFrame.origin = hidePoint;
        else
            headFrame.origin = CGPointZero;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        self.headerView.frame = headFrame;
        [UIView commitAnimations];
        
        _headViewHided = hide;
    }
}

- (void)_updateBackwardForwardButton {
    if ([self.webView canGoBack]) {
        self.backwardButton.enabled = YES;
    } else {
        self.backwardButton.enabled = NO;
    }
    
    if ([self.webView canGoForward]) {
        self.forewardButton.enabled = YES;
    } else {
        self.forewardButton.enabled = NO;
    }
}

- (void)_customizeAppearance {
    
    CGRect shadowRect = CGRectMake(0, 0, 2, CGRectGetHeight(self.middleView.frame));
    UIView *shadowView = [[UIView alloc] initWithFrame:shadowRect];
    shadowView.layer.shadowOpacity = 1;
    shadowView.layer.shadowOffset = CGSizeZero;
    shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    shadowView.layer.shadowRadius = 4;
    shadowView.layer.borderWidth = 1;
    shadowView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    shadowView.layer.shouldRasterize = YES;
    
    [self.middleView insertSubview:shadowView atIndex:0];
    shadowView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    self.middleView.layer.masksToBounds = NO;
    
    self.lightnessMask.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:[Setting lightnessMaskValue]];
    
    self.lightnessView.layer.cornerRadius = 8.0f;
}
- (void)viewDidUnload {
    self.lightnessView = nil;
    self.historyController = nil;
    self.sectionController = nil;
    self.forewardButton = nil;
    self.backwardButton = nil;
    [super viewDidUnload];
}
@end
