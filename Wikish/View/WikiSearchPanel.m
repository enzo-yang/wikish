//
//  WikiSearchPanel.m
//  Wikish
//
//  Created by YANG ENZO on 13-2-3.
//  Copyright (c) 2013年 Side Trip. All rights reserved.
//

#import "WikiSearchPanel.h"
#import <QuartzCore/QuartzCore.h>
#import "SiteManager.h"
#import "Constants.h"

NSString *const kNotificationMessageSearchKeyword = @"kNotificationMessageSearchKeyword";

#define kPi 3.1415926
#define kRowHeight 40.0f

@implementation WikiSearchPanel

+ (WikiSearchPanel *)panel {
    WikiSearchPanel *panel =  (WikiSearchPanel*) [[[UINib nibWithNibName:@"WikiSearchPanel" bundle:nil]
                                             instantiateWithOwner:self options:nil] objectAtIndex:0];
    
    
    panel.frame = [self _panelOrgFrame:panel];
    
    return panel;
}

+ (CGRect)_panelOrgFrame:(WikiSearchPanel *)panel {
    CGRect appFrame = [UIScreen mainScreen].applicationFrame;
    CGRect panelFrame = panel.frame;
    panelFrame.origin.y = appFrame.size.height - (panelFrame.size.height - panel.textPlatform.frame.size.height);
    return panelFrame;
}

+ (void)showInView:(UIView *)view {
    WikiSearchPanel *panel = [self panel];
    [view addSubview:panel];
    
    [[NSNotificationCenter defaultCenter] addObserver:panel selector:@selector(_keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:panel selector:@selector(_keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [panel.textField becomeFirstResponder];
    
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _openSearch = [WikiOpenSearch new];
    [_openSearch addObserver:self forKeyPath:@"results" options:NSKeyValueObservingOptionNew context:nil];
    CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI);
    self.resultTable.transform = transform;
    
    [self _updateLanguageButton];
    [self _customizeAppearance];
}

- (void)dealloc {
    [_openSearch removeObserver:self forKeyPath:@"results"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_openSearch release];
    self.textField = nil;
    self.resultTable = nil;
    self.textPlatform = nil;
    [_langBtn release];
    [_cancelBtn release];
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"results"]) {
        // NSLog(@"result changed, %@", _openSearch.results);
        self.resultTable.hidden = NO;
        [self.resultTable reloadData];
    }
}

- (IBAction)textChanged:(id)sender {
    if (self.textField.markedTextRange == nil) {
        // NSLog(@"%@", self.textField.text);
        if (self.textField.text && self.textField.text.length > 0)
            [_openSearch request:self.textField.text];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *text = textField.text;
    if (text) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageSearchKeyword object:nil userInfo:@{@"keyword" : text}];
    }
    [textField resignFirstResponder];
    return NO;
}


- (void)_keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *frameValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [frameValue CGRectValue];
    CGRect appFrame = [UIScreen mainScreen].applicationFrame;
    
    
    CGRect theBounds = self.bounds;
    theBounds.size.height = appFrame.size.height - keyboardFrame.size.height;
    
    NSValue *durationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval duration;
    [durationValue getValue:&duration];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    self.frame = theBounds;
    // self.resultTable.alpha = 1;
    [UIView commitAnimations];
}

- (void)_keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue *durationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval duration;
    [durationValue getValue:&duration];
    
    CGRect theFrame = self.frame;
    theFrame.origin.y = -theFrame.size.height; // appFrame.size.height - (theFrame.size.height - self.textPlatform.frame.size.height);
    
    [UIView animateWithDuration:duration animations:^{
        self.frame = [WikiSearchPanel _panelOrgFrame:self];
        self.resultTable.hidden = YES;
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CGFloat tableHeight = tableView.frame.size.height;
    CGFloat contentHeight = kRowHeight * [_openSearch.results count];
    CGFloat height = tableHeight > contentHeight ? (tableHeight - contentHeight) : 0.0f;
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *v = [[[UIView alloc] init] autorelease];
    v.backgroundColor = [UIColor clearColor];
    return v;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_openSearch.results count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"c";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
        cell.textLabel.font = [UIFont systemFontOfSize:17.0f];
        CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI);
        cell.transform = transform;
    }
    NSString *text = @"";
    if ([_openSearch.results count] > indexPath.row) {
        text = [NSString stringWithFormat:@"%02d. %@", (indexPath.row + 1), [_openSearch.results objectAtIndex:indexPath.row]];
    }
    cell.textLabel.text = text;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kRowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_openSearch.results count] > indexPath.row) {
        NSString *text = [_openSearch.results objectAtIndex:indexPath.row];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMessageSearchKeyword object:nil userInfo:@{@"keyword" : text}];
    }
    [self.textField resignFirstResponder];
}

- (void)hideKeyboard:(id)sender {
    [self.textField resignFirstResponder];
}

- (IBAction)languageButtonPressed:(id)sender {
    [[SiteManager sharedInstance] alterDefaultSite];
    [_openSearch updateSite];
    [self _updateLanguageButton];
}

- (void)_updateLanguageButton {
    WikiSite *site = [[SiteManager sharedInstance] defaultSite];
    [self.langBtn setTitle:[site briefName] forState:UIControlStateNormal];
}

- (void)_customizeAppearance {
    self.textPlatform.backgroundColor = GetDarkColor();
    
//    [self.langBtn setBackgroundColor:GetDarkColor() forState:UIControlStateNormal];
//    [self.langBtn setBackgroundColor:DarkGreenColor() forState:UIControlStateSelected];
//    [self.langBtn setBackgroundColor:GetTableHighlightRowColor() forState:UIControlStateHighlighted];
//
//    self.langBtn.layer.borderWidth = 2;
//    self.langBtn.layer.borderColor = [UIColor whiteColor].CGColor;
//    self.langBtn.layer.cornerRadius = 4;
//    self.langBtn.layer.rasterizationScale = [UIScreen mainScreen].scale;
//    self.langBtn.layer.shouldRasterize = YES;
    
    UIImage *noramlImage = [[UIImage imageNamed:@"square-normal.png"] stretchableImageWithLeftCapWidth:24 topCapHeight:24];
    UIImage *highlightImage = [[UIImage imageNamed:@"square-highlight.png"] stretchableImageWithLeftCapWidth:24 topCapHeight:24];
    [self.cancelBtn setBackgroundImage:noramlImage forState:UIControlStateNormal];
    [self.cancelBtn setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    [self.cancelBtn setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    
}


@end
