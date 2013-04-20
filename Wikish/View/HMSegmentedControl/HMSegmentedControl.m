//
//  HMSegmentedControl.m
//  HMSegmentedControlExample
//
//  Created by Hesham Abd-Elmegid on 23/12/12.
//  Copyright (c) 2012 Hesham Abd-Elmegid. All rights reserved.
//

#import "HMSegmentedControl.h"
#import <QuartzCore/QuartzCore.h>

@interface HMSegmentedControl ()

@property (nonatomic, readwrite) CGFloat segmentWidth;

@end

@implementation HMSegmentedControl

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        [self setDefaults];
    }
    
    return self;
}

- (id)initWithSectionTitles:(NSArray *)sectiontitles {
    self = [super initWithFrame:CGRectZero];
    
    if (self) {
        self.sectionTitles = sectiontitles;
        [self setDefaults];
    }
    
    return self;
}

- (void)setDefaults {
    self.font = [UIFont boldSystemFontOfSize:14.0f];
    self.textColor = [UIColor blackColor];
    self.backgroundColor = [UIColor whiteColor];
    self.selectionIndicatorColor = [UIColor colorWithRed:52.0f/255.0f green:181.0f/255.0f blue:229.0f/255.0f alpha:1.0f];
    self.seperatorColor = [UIColor lightGrayColor];
    self.selectedIndex = 0;
    self.segmentEdgeInset = UIEdgeInsetsMake(0, 5, 0, 5);
    self.height = 32.0f;
    self.selectionIndicatorHeight = 5.0f;

}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGFloat seperatorWidth = 0.5;
    if (scale == 1.0f) seperatorWidth = 1;
    
    [self.backgroundColor set];
    UIRectFill([self bounds]);
    
    [self.textColor set];
    
    [self.sectionTitles enumerateObjectsUsingBlock:^(id titleString, NSUInteger idx, BOOL *stop) {
        CGFloat stringHeight = [titleString sizeWithFont:self.font].height;
        CGFloat y = ((self.height - self.selectionIndicatorHeight) / 2) + (self.selectionIndicatorHeight - stringHeight / 2);
        CGRect rect = CGRectZero;
        
        if (self.selectedIndex == idx) {
            [self.selectionIndicatorColor set];
            rect = CGRectMake(self.segmentWidth * idx, 0, self.segmentWidth, self.height);
            rect = CGRectInset(rect, 1, 1);
            UIRectFill(rect);
            [[UIColor whiteColor] set];
        } else {
            [self.textColor set];
        }
        
        
        
        rect = CGRectMake(self.segmentWidth * idx, y, self.segmentWidth, stringHeight);
        
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
        [titleString drawInRect:rect
                       withFont:self.font
                  lineBreakMode:UILineBreakModeClip
                      alignment:UITextAlignmentCenter];
#else
        [titleString drawInRect:rect
                       withFont:self.font
                  lineBreakMode:NSLineBreakByClipping
                      alignment:NSTextAlignmentCenter];
#endif
        if (idx != self.sectionTitles.count - 1 && (idx + 1) != _selectedIndex && idx != _selectedIndex) {
            CGContextRef c = UIGraphicsGetCurrentContext();
            
            CGContextSaveGState(c);
            CGContextSetStrokeColorWithColor(c, self.seperatorColor.CGColor);
            CGContextSetShouldAntialias(c, false);
            CGContextSetLineWidth(c, seperatorWidth);
            
            CGPoint beginPoint = CGPointMake(self.segmentWidth * (idx + 1), self.selectionIndicatorHeight + 4);
            CGPoint endPoint = CGPointMake(self.segmentWidth * (idx + 1), self.height - 4);
            
            CGContextBeginPath(c);
            CGContextMoveToPoint(c, beginPoint.x, beginPoint.y);
            CGContextAddLineToPoint(c, endPoint.x, endPoint.y);
            CGContextStrokePath(c);
            
            CGContextRestoreGState(c);
        }
        
    }];
}

- (void)updateSegmentsRects {
    // If there's no frame set, calculate the width of the control based on the number of segments and their size
    if (CGRectIsEmpty(self.frame)) {
        self.segmentWidth = 0;
        
        for (NSString *titleString in self.sectionTitles) {
            CGFloat stringWidth = [titleString sizeWithFont:self.font].width + self.segmentEdgeInset.left + self.segmentEdgeInset.right;
            self.segmentWidth = MAX(stringWidth, self.segmentWidth);
        }
        
        self.bounds = CGRectMake(0, 0, self.segmentWidth * self.sectionTitles.count, self.height);
    } else {
        self.segmentWidth = self.frame.size.width / self.sectionTitles.count;
        self.height = self.frame.size.height;
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    // Control is being removed
    if (newSuperview == nil)
        return;
    
    [self updateSegmentsRects];
}

#pragma mark - Touch

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    
    if (CGRectContainsPoint(self.bounds, touchLocation)) {
        NSInteger segment = touchLocation.x / self.segmentWidth;
        
        if (segment != self.selectedIndex) {
            [self setSelectedIndex:segment animated:YES];
        }
    }
}

#pragma mark -

- (void)setSelectedIndex:(NSInteger)index {
    [self setSelectedIndex:index animated:NO];
}

- (void)setSelectedIndex:(NSUInteger)index animated:(BOOL)animated {
    _selectedIndex = index;

    if (animated) {
        [self setNeedsDisplay];
        [UIView transitionWithView:self duration:0.2
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [self.layer displayIfNeeded];
                        } completion:^(BOOL finished) {
                            if (self.superview)
                                [self sendActionsForControlEvents:UIControlEventValueChanged];
                            
                            if (self.indexChangeBlock)
                                self.indexChangeBlock(index);
                        }];
    } else {
        [self setNeedsDisplay];
        
        if (self.superview)
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        
        if (self.indexChangeBlock)
            self.indexChangeBlock(index);

    }    
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    if (self.sectionTitles)
        [self updateSegmentsRects];
    
    [self setNeedsDisplay];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    
    if (self.sectionTitles)
        [self updateSegmentsRects];
    
    [self setNeedsDisplay];
}

@end
