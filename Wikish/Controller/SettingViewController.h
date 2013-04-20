//
//  SettingViewController.h
//  Wikish
//
//  Created by YANG ENZO on 13-2-6.
//  Copyright (c) 2013年 Side Trip. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Button;
@class TableViewGestureRecognizer;

@interface SettingViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIButton     *okButton;
@property (nonatomic, weak) IBOutlet UIButton     *helpButton;
@property (nonatomic, weak) IBOutlet UILabel      *settingLabel;

@property (nonatomic, weak) IBOutlet UIView       *httpsView;
@property (nonatomic, weak) IBOutlet UILabel      *httpsLabel;
@property (nonatomic, weak) IBOutlet UISwitch     *httpsSwitch;

@property (nonatomic, weak) IBOutlet UIView       *expanedView;
@property (nonatomic, weak) IBOutlet UILabel      *expanedLabel;
@property (nonatomic, weak) IBOutlet UISwitch     *expanedSwitch;

@property (nonatomic, weak) IBOutlet UIView       *homeView;
@property (nonatomic, weak) IBOutlet UILabel      *homeLabel;
@property (weak, nonatomic) IBOutlet UIView       *homePageSwitchPlatform;

@property (nonatomic, weak) IBOutlet UITableView  *sitesTable;
@property (nonatomic, weak) IBOutlet UITableView  *commonSitesTable;

@property (nonatomic, strong) TableViewGestureRecognizer *sitesGestureRecognizer;
@property (nonatomic, strong) TableViewGestureRecognizer *commonSitesGestureRecognizer;

- (IBAction)useHttpsSwitchChanged:(UISwitch *)sender;
- (IBAction)sectionExpandedSwitchChanged:(UISwitch *)sender;
- (IBAction)okButtonPressed:(id)sender;
- (IBAction)helpButtonPressed:(id)sender;
@end
