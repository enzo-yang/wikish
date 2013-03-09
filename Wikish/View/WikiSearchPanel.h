//
//  WikiSearchPanel.h
//  Wikish
//
//  Created by YANG ENZO on 13-2-3.
//  Copyright (c) 2013年 Side Trip. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Button.h"
#import "WikiOpenSearch.h"
@interface WikiSearchPanel : UIView<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    WikiOpenSearch *_openSearch;
}
@property (nonatomic, retain) IBOutlet UITextField  *textField;
@property (nonatomic, retain) IBOutlet UITableView  *resultTable;
@property (nonatomic, retain) IBOutlet UIView       *textPlatform;
@property (retain, nonatomic) IBOutlet UIButton *langBtn;
@property (retain, nonatomic) IBOutlet UIButton *cancelBtn;
+ (void)showInView:(UIView *)view;

- (IBAction)hideKeyboard:(id)sender;
- (IBAction)languageButtonPressed:(id)sender;

@end
