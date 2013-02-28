//
//  TableViewGestureRecognizer.h
//  Wikish
//
//  Created by YANG ENZO on 13-2-23.
//  Copyright (c) 2013年 Side Trip. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    TableViewCellPanStateMiddle,
    TableViewCellPanStateLeft,
    TableViewCellPanStateRight,
} TableViewCellPanState;

@interface TableViewGestureRecognizer : NSObject<UITableViewDelegate>

@property (nonatomic, assign)           TableViewCellPanState swipeState;
@property (nonatomic, retain)           NSIndexPath *theIndexPath;
@property (nonatomic, assign, readonly) UITableView *tableView;

+ (TableViewGestureRecognizer *)gestureRecognizerWithTableView:(UITableView *)tableView delegate:(id)delegate;

@end

// - swipe to edit cell
@protocol TableViewGesturePanningRowDelegate <NSObject>

// Panning (required)
- (BOOL)gestureRecognizer:(TableViewGestureRecognizer *)gestureRecognizer canEditRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)gestureRecognizer:(TableViewGestureRecognizer *)gestureRecognizer didEnterPanState:(TableViewCellPanState)state forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)gestureRecognizer:(TableViewGestureRecognizer *)gestureRecognizer commitPanState:(TableViewCellPanState)state forRowAtIndexPath:(NSIndexPath *)indexPath;

@optional

- (CGFloat)gestureRecognizer:(TableViewGestureRecognizer *)gestureRecognizer lengthForCommitPanningRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)gestureRecognizer:(TableViewGestureRecognizer *)gestureRecognizer didChangeContentViewTranslation:(CGPoint)translation forRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface UITableView (TableViewGestureDelegate)

- (TableViewGestureRecognizer *)enableGestureTableViewWithDelegate:(id)delegate;

@end