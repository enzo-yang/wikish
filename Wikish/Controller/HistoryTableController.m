//
//  HistoryTableController.m
//  Wikish
//
//  Created by ENZO YANG on 13-3-1.
//  Copyright (c) 2013年 Side Trip. All rights reserved.
//

#import "HistoryTableController.h"
#import "Constants.h"
#import "WikiHistory.h"

@implementation HistoryTableController

- (id)init {
    self = [super init];
    if (self) {
        _history = [[WikiHistory sharedInstance] retain];
    }
    return self;
}


- (void)dealloc {
    [_history release]; _history = nil;
    [super dealloc];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_history.history count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID] autorelease];
        cell.backgroundView = [[UIView new] autorelease];
        cell.backgroundView.backgroundColor = GetTableCellBackgroundColor();
        cell.contentView.backgroundColor    = GetTableBackgourndColor();
    }
    WikiRecord *record = [_history.history objectAtIndex:indexPath.row];
    cell.textLabel.text = record.title;
    cell.detailTextLabel.text = record.name;
    return cell;
}
@end
