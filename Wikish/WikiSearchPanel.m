//
//  WikiSearchPanel.m
//  Wikish
//
//  Created by YANG ENZO on 13-2-3.
//  Copyright (c) 2013年 Side Trip. All rights reserved.
//

#import "WikiSearchPanel.h"

#define kPi 3.1415926
#define kRowHeight 40.0f

@implementation WikiSearchPanel

+ (WikiSearchPanel *)panel {
    WikiSearchPanel *panel =  (WikiSearchPanel*) [[[UINib nibWithNibName:@"WikiSearchPanel" bundle:nil]
                                             instantiateWithOwner:self options:nil] objectAtIndex:0];
    
    
    
//    CGRect panelFrame = panel.frame;
//    panelFrame.origin.y = - panel.frame.size.height; // appFrame.size.height;
//    panel.frame = panelFrame;
    
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
    CGAffineTransform transform = CGAffineTransformMakeRotation(3.1415926);
    self.resultTable.transform = transform; 
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"results"]) {
        NSLog(@"result changed, %@", _openSearch.results);
        self.resultTable.hidden = NO;
        [self.resultTable reloadData];
    }
}

- (IBAction)textChanged:(id)sender {
    if (self.textField.markedTextRange == nil) {
        NSLog(@"%@", self.textField.text);
        if (self.textField.text && self.textField.text.length > 0)
            [_openSearch request:self.textField.text];
    }
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
    
    // CGRect appFrame = [UIScreen mainScreen].applicationFrame;
    CGRect theFrame = self.frame;
    theFrame.origin.y = -theFrame.size.height; // appFrame.size.height - (theFrame.size.height - self.textPlatform.frame.size.height);
    
    [UIView animateWithDuration:duration animations:^{
//        self.frame = theFrame;
        self.frame = [WikiSearchPanel _panelOrgFrame:self];
        self.resultTable.hidden = YES;
        // self.resultTable.alpha = 0;
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
        CGAffineTransform transform = CGAffineTransformMakeRotation(3.1415926);
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

- (void)hideKeyboard:(id)sender {
    [self.textField resignFirstResponder];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}
@end
