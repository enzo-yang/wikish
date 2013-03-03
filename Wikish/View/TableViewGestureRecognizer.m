//
//  TableViewGestureRecognizer.m
//  Wikish
//
//  Created by YANG ENZO on 13-2-23.
//  Copyright (c) 2013年 Side Trip. All rights reserved.
//

#import "TableViewGestureRecognizer.h"

typedef enum {
    TableViewGestureRecognizerStateNone,
    TableViewGestureRecognizerStateDragging,
    TableViewGestureRecognizerStatePanning,
} TableViewGestureRecognizerState;

CGFloat const TableViewCommitPanningRowDefaultLength = 80;

@interface TableViewGestureRecognizer() <UIGestureRecognizerDelegate>

@property (nonatomic, assign) id<TableViewGesturePanningRowDelegate>   delegate;
@property (nonatomic, assign) id<UITableViewDelegate>               tableViewDelegate;
@property (nonatomic, assign) UITableView                           *tableView;
@property (nonatomic, retain) UIPanGestureRecognizer                *panRecognizer;
@property (nonatomic, assign) TableViewGestureRecognizerState       state;
@property (nonatomic, retain) UIImage                               *cellSnapshot;
@end

@implementation TableViewGestureRecognizer

- (void)panGestureRecognizer:(UIPanGestureRecognizer *)recognizer {
    if ((recognizer.state == UIGestureRecognizerStateBegan
         || recognizer.state == UIGestureRecognizerStateChanged)
        && [recognizer numberOfTouches] > 0) {
        
        // TODO: should ask delegate before changing cell's content view
        
        CGPoint location1 = [recognizer locationOfTouch:0 inView:self.tableView];
        
        NSIndexPath *indexPath = self.theIndexPath;
        if ( ! indexPath) {
            indexPath = [self.tableView indexPathForRowAtPoint:location1];
            self.theIndexPath = indexPath;
        }
        
        if (! indexPath ) return;
        
        self.state = TableViewGestureRecognizerStatePanning;
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        CGPoint translation = [recognizer translationInView:self.tableView];
        if (translation.x < 0.0f && self.blockSide == TableViewCellBlockLeft) return;
        if (translation.x > 0.0f && self.blockSide == TableViewCellBlockRight) return;
        
        cell.contentView.frame = CGRectOffset(cell.contentView.bounds, translation.x, 0);
        
        if ([self.delegate respondsToSelector:@selector(gestureRecognizer:didChangeContentViewTranslation:forRowAtIndexPath:)]) {
            [self.delegate gestureRecognizer:self didChangeContentViewTranslation:translation forRowAtIndexPath:indexPath];
        }
        
        CGFloat commitEditingLength = TableViewCommitPanningRowDefaultLength;
        if ([self.delegate respondsToSelector:@selector(gestureRecognizer:lengthForCommitPanningRowAtIndexPath:)]) {
            commitEditingLength = [self.delegate gestureRecognizer:self lengthForCommitPanningRowAtIndexPath:indexPath];
        }
        if (fabsf(translation.x) >= commitEditingLength) {
            if (self.panState == TableViewCellPanStateMiddle) {
                self.panState = translation.x > 0 ? TableViewCellPanStateRight : TableViewCellPanStateLeft;
            }
        } else {
            if (self.panState != TableViewCellPanStateMiddle) {
                self.panState = TableViewCellPanStateMiddle;
            }
        }
        
        if ([self.delegate respondsToSelector:@selector(gestureRecognizer:didEnterPanState:forRowAtIndexPath:)]) {
            [self.delegate gestureRecognizer:self didEnterPanState:self.panState forRowAtIndexPath:indexPath];
        }
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        NSIndexPath *indexPath = self.theIndexPath;
        if (!indexPath) return;
        [[indexPath retain] autorelease];
        
        // Removes addingIndexPath before updating then tableView will be able
        // to determine correct table row height
        self.theIndexPath = nil;
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        CGPoint translation = [recognizer translationInView:self.tableView];
        
        CGFloat commitEditingLength = TableViewCommitPanningRowDefaultLength;
        if ([self.delegate respondsToSelector:@selector(gestureRecognizer:lengthForCommitPanningRowAtIndexPath:)]) {
            commitEditingLength = [self.delegate gestureRecognizer:self lengthForCommitPanningRowAtIndexPath:indexPath];
        }
        if (fabsf(translation.x) >= commitEditingLength) {
            if ([self.delegate respondsToSelector:@selector(gestureRecognizer:commitPanState:forRowAtIndexPath:)]) {
                [self.delegate gestureRecognizer:self commitPanState:self.panState forRowAtIndexPath:indexPath];
            }
        } else {
            [UIView animateWithDuration:0.3f animations:^{
                cell.contentView.frame = cell.contentView.bounds;
            } completion:^(BOOL finished) {
                if ([self.delegate respondsToSelector:@selector(gestureRecognizer:recoverRowAtIndexPath:)]) {
                    [self.delegate gestureRecognizer:self recoverRowAtIndexPath:indexPath];
                }
            }];
        }
        
        self.panState = TableViewCellPanStateMiddle;
        self.state = TableViewGestureRecognizerStateNone;
    }
}


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    if (gestureRecognizer == self.panRecognizer) {
        if ( ! [self.delegate conformsToProtocol:@protocol(TableViewGesturePanningRowDelegate)]) {
            return NO;
        }
        
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        
        CGPoint point = [pan translationInView:self.tableView];
        CGPoint location = [pan locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
        
        // The pan gesture recognizer will fail the original scrollView scroll
        // gesture, we wants to ensure we are panning left/right to enable the
        // pan gesture.
        if (fabsf(point.y) > fabsf(point.x)) {
            return NO;
        } else if (indexPath == nil) {
            return NO;
        } else if (indexPath) {
            BOOL canEditRow = [self.delegate gestureRecognizer:self canEditRowAtIndexPath:indexPath];
            return canEditRow;
        }
    }
    
    return NO;
}

#pragma mark NSProxy

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    [anInvocation invokeWithTarget:self.tableViewDelegate];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [(NSObject *)self.tableViewDelegate methodSignatureForSelector:aSelector];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    NSAssert(self.tableViewDelegate != nil, @"self.tableViewDelegate must not be nil");
    if ([self.tableViewDelegate respondsToSelector:aSelector]) {
        return YES;
    }
    return [[self class] instancesRespondToSelector:aSelector];
}

#pragma mark Class method

+ (TableViewGestureRecognizer *)gestureRecognizerWithTableView:(UITableView *)tableView delegate:(id)delegate {
    TableViewGestureRecognizer *recognizer = [[TableViewGestureRecognizer alloc] init];
    recognizer.delegate = delegate;
    recognizer.tableView = tableView;
    recognizer.tableViewDelegate = tableView.delegate;
    recognizer.blockSide = TableViewCellBlockNone;
    tableView.delegate = recognizer;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:recognizer action:@selector(panGestureRecognizer:)];
    [tableView addGestureRecognizer:pan];
    pan.delegate = recognizer;
    recognizer.panRecognizer = pan;
    [pan release];
    
    return [recognizer autorelease];
}

- (void)dealloc {
    self.theIndexPath = nil;
    [super dealloc];
}

@end

@implementation UITableView (TableViewGestureDelegate)

- (TableViewGestureRecognizer *)enableGestureTableViewWithDelegate:(id)delegate {
    if ( ! [delegate conformsToProtocol:@protocol(TableViewGesturePanningRowDelegate)]) {
        [NSException raise:@"delegate should at least conform to one of JTTableViewGestureAddingRowDelegate" format:nil];
    }
    TableViewGestureRecognizer *recognizer = [TableViewGestureRecognizer gestureRecognizerWithTableView:self delegate:delegate];
    return recognizer;
}

@end
