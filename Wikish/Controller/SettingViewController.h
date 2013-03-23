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

@property (nonatomic, retain) IBOutlet Button       *okButton;
@property (retain, nonatomic) IBOutlet Button *helpButton;
@property (nonatomic, retain) IBOutlet UILabel      *settingLabel;

@property (nonatomic, retain) IBOutlet UIView       *httpsView;
@property (nonatomic, retain) IBOutlet UILabel      *httpsLabel;
@property (nonatomic, retain) IBOutlet UISwitch     *httpsSwitch;

@property (nonatomic, retain) IBOutlet UIView       *expanedView;
@property (nonatomic, retain) IBOutlet UILabel      *expanedLabel;
@property (nonatomic, retain) IBOutlet UISwitch     *expanedSwitch;

@property (nonatomic, retain) IBOutlet UIView       *homeView;
@property (nonatomic, retain) IBOutlet UILabel      *homeLabel;
@property (nonatomic, retain) IBOutletCollection(Button) NSArray *homeButtons;


@property (nonatomic, retain) IBOutlet UITableView  *sitesTable;
@property (nonatomic, retain) IBOutlet UITableView  *commonSitesTable;

@property (nonatomic, retain) TableViewGestureRecognizer *sitesGestureRecognizer;
@property (nonatomic, retain) TableViewGestureRecognizer *commonSitesGestureRecognizer;

- (IBAction)useHttpsSwitchChanged:(UISwitch *)sender;
- (IBAction)sectionExpandedSwitchChanged:(UISwitch *)sender;
- (IBAction)okButtonPressed:(id)sender;
- (IBAction)homeTypeButtonPressed:(id)sender;
- (IBAction)helpButtonPressed:(id)sender;
@end
