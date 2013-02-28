//
//  TapDetectingWindow.h
//  Wikish
//
//  Created by YANG ENZO on 13-2-2.
//  Copyright (c) 2013年 Side Trip. All rights reserved.
//

#import <UIKit/UIKit.h>

// http://mithin.in/2009/08/26/detecting-taps-and-events-on-uiwebview-the-right-way/
@protocol TapDetectingWindowDelegate <NSObject>
- (void)userDidTapWebView:(id)tapPoint;
@end

@interface TapDetectingWindow : UIWindow {
}

@property (nonatomic, retain) UIView *viewToObserve;
@property (nonatomic, assign) id<TapDetectingWindowDelegate> controllerThatObserves;

@end
