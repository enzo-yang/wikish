//
//  FirstLaunchHelpController.h
//  Wikish
//
//  Created by ENZO YANG on 13-4-12.
//  Copyright (c) 2013年 Side Trip. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StyledPageControl.h"

@interface HelpController : UIViewController
@property (retain, nonatomic) IBOutlet UIScrollView *scroller;
@property (retain, nonatomic) IBOutlet UIView *page1;
@property (retain, nonatomic) IBOutlet UIView *page2;
@property (retain, nonatomic) IBOutlet UIView *page3;
@property (retain, nonatomic) IBOutlet StyledPageControl *pageControl;

@property (copy, nonatomic) void (^okBlock)(void);

- (IBAction)okPressed:(id)sender;

@end
