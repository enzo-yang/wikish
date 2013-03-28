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
#import "FavouriteTableController.h"

#import "GAI.h"

#define kScrollViewDirectionNone    0
#define kScrollViewDirectionUp      1
#define kScrollViewDirectionDown    2

#define kHandleDragThreshold        150

@interface MainViewController ()<WikiPageInfoDelegate, UIWebViewDelegate, UIScrollViewDelegate, TapDetectingWindowDelegate>
@property (nonatomic, retain) WikiPageInfo  *pageInfo;
@property (nonatomic, retain) WikiSite      *currentSite;
@end

@implementation MainViewController

@synthesize pageInfo = _pageInfo;
@synthesize currentSite = _currentSite;


- (id)init {
    self = [super init];
    if (self) {
        _canLoadThisRequest = NO;
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
    
    
    self.titleLabel.text = NSLocalizedString(@"Blank", nil);
    
    [self _loadHomePage];

    self.leftView.hidden = YES;
    self.rightView.hidden = YES;
    
    [self _initializeTables];
    
    [self _customizeAppearance];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_loadPageFromNotification:) name:kNotificationMessageSearchKeyword object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self _windowBeginDetectWebViewTap];
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
    [_webView release];
    // TODO(enzo)
    [_titleLabel release];
    [_lightnessView release];
    [_lightnessMask release];
    [super dealloc];
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
    WikiPageInfo *aPageInfo = [[[WikiPageInfo alloc] initWithSite:site title:title] autorelease];
    if (aPageInfo) {
        [[[GAI sharedInstance] defaultTracker] sendEventWithCategory:kGAUserHabit withAction:kGALaunguage withLabel:site.name withValue:@1];
        self.pageInfo = aPageInfo;
        NSURLRequest *request = [NSURLRequest requestWithURL:[aPageInfo pageURL]];
        if (request) {
            if ([theTitle isEqualToString:@""]) {
                self.titleLabel.text = NSLocalizedString(@"Home_Page", nil);
            } else {
                self.titleLabel.text = [theTitle urlDecodedString];
            }
            self.currentSite        = site;
            _canLoadThisRequest     = YES;
            WikiRecord *record      = [[[WikiRecord alloc] initWithSite:site title:title] autorelease];
            [[WikiHistory sharedInstance] addRecord:record];
            
            [self.pageInfo loadPageInfo];
            [self.webView loadRequest:[NSURLRequest requestWithURL:[aPageInfo pageURL]]];
        }
    } else {
        // TODO notify mistakes
    }
}

- (void)setPageInfo:(WikiPageInfo *)pageInfo {
    if (_pageInfo == pageInfo) return;
    if (_pageInfo) {
        _pageInfo.delegate = nil;
        [_pageInfo release];
    }
    if (pageInfo) {
        pageInfo.delegate = self;
        [pageInfo retain];
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
    [self scrollViewDidScroll:self.webView.scrollView];
//    if (_sectionFinished) return;
//    if (3 > _jsInjectedCount++) {
        NSString *js = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"wiki-inject-functions" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil];
        [self.webView stringByEvaluatingJavaScriptFromString:js];
//    }
//    [self.webView stringByEvaluatingJavaScriptFromString:@"toggle_all_section(true)"];
//    LOG(@"toggle_all_sections(true)");
    
    // 限制不能左右滚动 以及 头部offset 大于50
    
}

- (void)wikiPageInfoLoadSuccess:(WikiPageInfo *)wikiPage {
    LOG(@"load success");
}

- (void)wikiPageInfoLoadFailed:(WikiPageInfo *)wikiPage error:(NSError *)error {
    LOG(@"wiki page load failed");
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    LOG(@"%@", request);
    NSMutableURLRequest *mRequest = (NSMutableURLRequest *)request;
    LOG(@"webview user agent: %@", [mRequest valueForHTTPHeaderField:@"User-Agent"]);
    if (_canLoadThisRequest) {
        _canLoadThisRequest = NO;
        [SVProgressHUD showWithStatus:@"Loading" maskType:SVProgressHUDMaskTypeBlack];
        return YES;
    }
    if ([self _isSameAsCurrentRequest:request]) return NO;
    
    NSString *absolute = [[request URL] absoluteString];
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
        NSString *lang = [absolute stringByMatching:@"(?<=//).*(?=\\.m\\.wikipedia)" capture:0];
        NSString *subLang = [absolute stringByMatching:@"(?<=wikipedia.org/).*(?=/)" capture:0];
        NSString *title = [absolute lastPathComponent];
        LOG(@"%@, %@, %@", lang, subLang, title);
        WikiSite *site = [[SiteManager sharedInstance] siteOfLang:lang subLang:subLang];
        if (!site) site = [[[WikiSite alloc] initWithLang:lang sublang:subLang] autorelease];
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self loadSite:site title:title];
        });
        return NO;
    }
    [[UIApplication sharedApplication] openURL:[request URL]];
    return NO;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if ([SVProgressHUD isVisible]) {
        [SVProgressHUD dismiss];
    }
    LOG(@"page finish load");
}




- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    LOG(@"failed load web page, %@", webView.request);
    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"page load failed", nil)];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    // 限制不能左右滚动 以及 头部offset 大于50
    [scrollView setContentOffset:CGPointMake(0, scrollView.contentOffset.y < 50.0f ? 50.0f :scrollView.contentOffset.y)];
    
    CGFloat offsetY = scrollView.contentOffset.y;
    // 控制显示隐藏顶栏
    NSInteger direction = [self _analyseScrollDirection:scrollView];
    if (offsetY < kHandleDragThreshold && direction == kScrollViewDirectionDown) {
        // 显示顶栏
        [self _hideHeadView:NO];
    }
    
    // not acurate
    CGFloat virtualOffsetY = offsetY - 50.0f;
    if (virtualOffsetY <= _webViewOrgY){
        self.webView.frame = CGRectMake(0.0f,
                                        _webViewOrgY-virtualOffsetY,
                                        CGRectGetWidth(self.webView.frame),
                                        _webViewOrgHeight + virtualOffsetY);
    } else {
        if (CGRectGetMinY(self.webView.frame) != 0) {
            self.webView.frame = CGRectMake(0, 0, CGRectGetWidth(self.webView.frame),
                                            _webViewOrgHeight + _webViewOrgY);
        }
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
    
    CGFloat currentY = scrollView.contentOffset.y;
    if (currentY > kHandleDragThreshold) {
        [self _hideHeadView:!_headViewHided];
    }
}

- (void)scrollTo:(NSString *)anchorPoint {
    if ([Setting isLaunchTimeInitExpanded]) {
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"scroll_to_expanded_section(\"%@\")", anchorPoint]];
    } else {
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"scroll_to_section(\"%@\")", anchorPoint]];
    }
    [self _recoverNormalStatus];
}

- (BOOL)_isSameAsCurrentRequest:(NSURLRequest *)request {
    NSString *urlstring = [request URL].absoluteString;
    urlstring = [urlstring urlDecodedString];
    NSRange range = [urlstring rangeOfString:@"#"];
    return (range.length != 0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)historyBtnPressed:(id)sender {
    if (_viewStatus != kViewStatusNormal) {
        [self _recoverNormalStatus];
    } else {
        [self.historyTable reloadData];
        _viewStatus = kViewStatusHistory;
        self.leftView.hidden = NO;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        CGRect f = self.middleView.frame;
        f.origin.x += 260.0f;
        self.middleView.frame = f;
        [UIView commitAnimations];
    }
}

- (IBAction)searchBtnPressed:(id)sender {
    if (_viewStatus != kViewStatusNormal) {
        [self _recoverNormalStatus];
        return;
    }
    // [self.webView stringByEvaluatingJavaScriptFromString:@"toggle_all_section(true)"];
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
        f.origin.y -= 300.0f;
        self.bottomView.frame = f;
        [UIView commitAnimations];
    }
}

- (IBAction)lightnessBtnPressed:(id)sender {
    if (_viewStatus != kViewStatusNormal) {
        [self _recoverNormalStatus];
    } else {
        _viewStatus = kViewStatusLightness;
        self.lightnessView.hidden = NO;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        CGRect f = self.lightnessView.frame;
        f.origin.y -= 100.0f;
        self.lightnessView.frame = f;
        [UIView commitAnimations];
    }
}

- (IBAction)settingBtnPressed:(id)sender {
    if (_viewStatus != kViewStatusNormal) {
        [self _recoverNormalStatus];
        return;
    }
    SettingViewController *svc = [[SettingViewController new] autorelease];
    // [self presentModalViewController:svc animated:YES];
    [self.navigationController pushViewController:svc animated:YES];
    
}

- (IBAction)lightnessUpBtnPressed:(id)sender {
    [Setting lightnessUp];
    self.lightnessMask.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:[Setting lightnessMaskValue]];
}

- (IBAction)lightnessDownBtnPressed:(id)sender {
    [Setting lightnessDown];
    self.lightnessMask.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:[Setting lightnessMaskValue]];
}

- (void)_initializeTables {
    self.historyTable.backgroundColor = GetTableBackgourndColor();
    self.sectionTable.backgroundColor = GetTableBackgourndColor();
    self.favouriteTable.backgroundColor = GetTableBackgourndColor();
    
    self.historyController = [[HistoryTableController new] autorelease];
    [self.historyController setTableView:self.historyTable andMainController:self];
    
    self.sectionController = [[SectionTableController new] autorelease];
    [self.sectionController setTableView:self.sectionTable andMainController:self];
    
    self.favouriteController = [[FavouriteTableController new] autorelease];
    [self.favouriteController setTableView:self.favouriteTable andMainController:self];
    
}

- (void)_recoverNormalStatus {
    UIView *theViewShouldChangeFrame = nil;
    UIView *theViewShouldHide = nil;
    CGRect f;
    if (_viewStatus == kViewStatusHistory) {
        f = self.middleView.frame;
        f.origin.x -= 260.0f;
        theViewShouldHide = self.leftView;
        theViewShouldChangeFrame = self.middleView;
    } else if (_viewStatus == kViewStatusSection) {
        f = self.bottomView.frame;
        f.origin.y += 300.0f;
        theViewShouldChangeFrame = self.bottomView;
    } else if (_viewStatus == kViewStatusLightness) {
        f = self.lightnessView.frame;
        f.origin.y += 100.0f;
        theViewShouldChangeFrame = self.lightnessView;
    }
    
    [UIView animateWithDuration:0.3 animations:^(){
        theViewShouldChangeFrame.frame = f;
    }completion:^(BOOL finished) {
        if (theViewShouldHide) theViewShouldHide.hidden = YES;
    }];
    
    _viewStatus = kViewStatusNormal;
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

- (void)_customizeAppearance {
    
    CGRect shadowRect = CGRectMake(0, 0, 2, CGRectGetHeight(self.middleView.frame));
    UIView *shadowView = [[[UIView alloc] initWithFrame:shadowRect] autorelease];
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
}
- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [self setLightnessView:nil];
    [self setLightnessMask:nil];
    [super viewDidUnload];
}
@end
