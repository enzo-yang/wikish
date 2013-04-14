//
//  MainTableController.h
//  Wikish
//
//  Created by ENZO YANG on 13-3-1.
//  Copyright (c) 2013年 Side Trip. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainViewController.h"

@interface MainTableController : NSObject<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *table;
@property (nonatomic, weak) MainViewController *mainController;

- (void)setTableView:(UITableView *)table andMainController:(MainViewController *)controller;

@end
