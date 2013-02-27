//
//  TableViewGestureRecognizer.h
//  Wikish
//
//  Created by YANG ENZO on 13-2-23.
//  Copyright (c) 2013年 Side Trip. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    TableViewCellEditingStateMiddle,
    TableViewCellEditingStateLeft,
    TableViewCellEditingStateRight,
} TableViewCellEditingState;

@interface TableViewGestureRecognizer : NSObject<UITableViewDelegate>

@property (nonatomic, assign, readonly) UITableView *tableView;

+ (TableViewGestureRecognizer *)gestureRecognizerWithTableView:(UITableView *)tableView delegate:(id)delegate;

@end

// Conform to JTTableViewGestureEditingRowDelegate to enable features
// - swipe to edit cell
@protocol TableViewGestureEditingRowDelegate <NSObject>

// Panning (required)
- (BOOL)gestureRecognizer:(TableViewGestureRecognizer *)gestureRecognizer canEditRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)gestureRecognizer:(TableViewGestureRecognizer *)gestureRecognizer didEnterEditingState:(TableViewCellEditingState)state forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)gestureRecognizer:(TableViewGestureRecognizer *)gestureRecognizer commitEditingState:(TableViewCellEditingState)state forRowAtIndexPath:(NSIndexPath *)indexPath;

@optional

- (CGFloat)gestureRecognizer:(TableViewGestureRecognizer *)gestureRecognizer lengthForCommitEditingRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)gestureRecognizer:(TableViewGestureRecognizer *)gestureRecognizer didChangeContentViewTranslation:(CGPoint)translation forRowAtIndexPath:(NSIndexPath *)indexPath;

@end
