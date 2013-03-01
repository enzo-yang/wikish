//
//  MainTableController.m
//  Wikish
//
//  Created by ENZO YANG on 13-3-1.
//  Copyright (c) 2013年 Side Trip. All rights reserved.
//

#import "MainTableController.h"

@implementation MainTableController

- (void)setTableView:(UITableView *)table andMainController:(MainViewController *)controller {
    self.table = table;
    self.mainController = controller;
    
    self.table.delegate = self;
    self.table.dataSource = self;
}

- (void)dealloc {
    self.table = nil;
    self.mainController = nil;
    [super dealloc];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

@end
