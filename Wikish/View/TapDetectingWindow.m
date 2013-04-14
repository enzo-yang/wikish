//
//  TapDetectingWindow.m
//  Wikish
//
//  Created by YANG ENZO on 13-2-2.
//  Copyright (c) 2013年 Side Trip. All rights reserved.
//

#import "TapDetectingWindow.h"

@implementation TapDetectingWindow
@synthesize viewToObserve;
@synthesize controllerThatObserves;

- (void)dealloc {
    self.controllerThatObserves = nil;
}

- (void)forwardTap:(id)touch {
    [controllerThatObserves userDidTapWebView:touch];
}

- (void)sendEvent:(UIEvent *)event {
    [super sendEvent:event];
    if (viewToObserve == nil || controllerThatObserves == nil)
        return;
    
    NSSet *touches = [event allTouches];
    if (touches.count != 1) return;
    
    UITouch *touch = touches.anyObject;
    if (touch.phase != UITouchPhaseEnded) return;
    
    // LOG(@"%@", touch.view);
    if ([touch.view isDescendantOfView:viewToObserve] == NO) return;
    
    CGPoint tapPoint = [touch locationInView:viewToObserve];
    // LOG(@"TapPoint = %f, %f", tapPoint.x, tapPoint.y);
    
    NSArray *pointArray = [NSArray arrayWithObjects:[NSNumber numberWithFloat:tapPoint.x], [NSNumber numberWithFloat:tapPoint.y], nil];
    if (touch.tapCount == 1) {
        [self performSelector:@selector(forwardTap:) withObject:pointArray afterDelay:0.25];
    } else if (touch.tapCount > 1) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(forwardTap:) object:pointArray];
    }
}

@end
