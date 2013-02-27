//
//  SettingViewController.h
//  Wikish
//
//  Created by YANG ENZO on 13-2-6.
//  Copyright (c) 2013年 Side Trip. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController

@property (nonatomic, retain) IBOutlet UISwitch     *httpsSwitch;
@property (nonatomic, retain) IBOutlet UISwitch     *expanedSwitch;
@property (nonatomic, retain) IBOutlet UITextField  *langTextField;
@property (nonatomic, retain) IBOutlet UITextField  *langNameTextField;
@property (nonatomic, retain) IBOutlet UILabel      *siteLabel;
@property (nonatomic, retain) IBOutlet UITableView  *sitesTable;
@property (nonatomic, retain) IBOutlet UITableView  *commonSitesTable;

- (IBAction)useHttpsSwitchChanged:(UISwitch *)sender;
- (IBAction)sectionExpandedSwitchChanged:(UISwitch *)sender;
@end
