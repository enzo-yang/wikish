//
//  FirstLaunchHelpController.h
//  Wikish
//
//  Created by ENZO YANG on 13-4-12.
//  Copyright (c) 2013年 Side Trip. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpController : UIViewController
@property (retain, nonatomic) IBOutlet UIScrollView *scroller;
@property (retain, nonatomic) IBOutlet UIView *content;
@property (copy, nonatomic) void (^okBlock)(void);

- (IBAction)okPressed:(id)sender;

@end
