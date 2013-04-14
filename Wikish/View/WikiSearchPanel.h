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
    BOOL _shouldRemove;

    WikiOpenSearch *_openSearch;
}
@property (nonatomic, strong) IBOutlet UITextField  *textField;
@property (nonatomic, strong) IBOutlet UITableView  *resultTable;
@property (nonatomic, strong) IBOutlet UIView       *textPlatform;
@property (strong, nonatomic) IBOutlet UIButton *langBtn;
@property (strong, nonatomic) IBOutlet UIButton *cancelBtn;
+ (void)showInView:(UIView *)view;

- (IBAction)hideKeyboard:(id)sender;
- (IBAction)languageButtonPressed:(id)sender;

@end
