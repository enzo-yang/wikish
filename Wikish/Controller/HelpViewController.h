//
//  HelpViewController.h
//  Wikish
//
//  Created by YANG ENZO on 13-3-22.
//  Copyright (c) 2013年 Side Trip. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Button.h"

@interface HelpViewController : UIViewController
@property (retain, nonatomic) IBOutlet Button *backBtn;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIWebView *webView;

- (IBAction)backBtnPressed:(id)sender;
@end
