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
#import "TableViewGestureRecognizer.h"

@interface HistoryTableController()<TableViewGesturePanningRowDelegate>
@property (nonatomic, retain) TableViewGestureRecognizer *recognizer;
@end

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

- (void)setTableView:(UITableView *)table andMainController:(MainViewController *)controller {
    [super setTableView:table andMainController:controller];
    self.recognizer = [table enableGestureTableViewWithDelegate:self];
    self.recognizer.blockSide = TableViewCellBlockRight;
}

- (BOOL)gestureRecognizer:(TableViewGestureRecognizer *)gestureRecognizer canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (CGFloat)gestureRecognizer:(TableViewGestureRecognizer *)gestureRecognizer lengthForCommitPanningRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150.0f;
}

- (void)gestureRecognizer:(TableViewGestureRecognizer *)gestureRecognizer didEnterPanState:(TableViewCellPanState)state forRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [gestureRecognizer.tableView cellForRowAtIndexPath:indexPath];
    CGFloat left = cell.contentView.frame.origin.x;
    CGFloat color_offset = fabsf(left)/160.0f;
    if (color_offset > 1.0f) color_offset = 1.0f;
    CGFloat r, g, b; // 正常状态的颜色 rgb
    CGFloat rd, gd, bd; // 目的状态颜色
    CGFloat rv, gv, bv; // rgb 变化权值
    [GetTableBackgourndColor() getRed:&r green:&g blue:&b alpha:NULL];
    
    [[UIColor redColor] getRed:&rd green:&gd blue:&bd alpha:NULL];
    rv = rd-r; gv = gd-g; bv = bd-b;
    
    cell.contentView.backgroundColor = [UIColor colorWithRed:r+color_offset*rv green:g+color_offset*gv blue:b+color_offset*bv alpha:1];
}
- (void)gestureRecognizer:(TableViewGestureRecognizer *)gestureRecognizer commitPanState:(TableViewCellPanState)state forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (state != TableViewCellPanStateLeft) return;
    [self.table beginUpdates];
    [_history removeRecord:[_history.history objectAtIndex:indexPath.row]];
    [self.table deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.table endUpdates];
}
- (void)gestureRecognizer:(TableViewGestureRecognizer *)gestureRecognizer recoverRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [gestureRecognizer.tableView cellForRowAtIndexPath:indexPath];
    [UIView beginAnimations:nil context:nil];
    cell.contentView.backgroundColor = GetTableBackgourndColor();
    [UIView commitAnimations];
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
        cell.textLabel.font = [UIFont systemFontOfSize:17.0f];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        cell.selectedBackgroundView = [[UIView new] autorelease];
        cell.selectedBackgroundView.backgroundColor = GetTableHighlightRowColor();
        
    }
    cell.contentView.backgroundColor    = GetTableBackgourndColor();
    WikiRecord *record = [_history.history objectAtIndex:indexPath.row];
    cell.textLabel.text = record.title;
    cell.detailTextLabel.text = record.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WikiRecord *record = [_history.history objectAtIndex:indexPath.row];
    [self.mainController loadSite:record title:record.title];
}
@end
