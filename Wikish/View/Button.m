//
//  Button.m
//  Wikish
//
//  Created by YANG ENZO on 13-3-6.
//  Copyright (c) 2013年 Side Trip. All rights reserved.
//

#import "Button.h"

@interface Button()
@property (nonatomic, retain) UIColor *highlightColor;
@property (nonatomic, retain) UIColor *selectedColor;
@property (nonatomic, retain) UIColor *normalColor;
@end

@implementation Button

- (void)awakeFromNib {
    [super awakeFromNib];
    self.normalColor = self.backgroundColor;
    self.selectedColor = self.backgroundColor;
    self.highlightColor = self.backgroundColor;
    
    [self addObserver:self forKeyPath:@"highlighted" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"enabled" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc {
    self.normalColor = nil;
    self.selectedColor = nil;
    self.highlightColor = nil;
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"selected"] || [keyPath isEqualToString:@"enabled"]) {
        [self refreshBackgroundColor];
    } else if ([keyPath isEqualToString:@"highlighted"]) {
        [UIView beginAnimations:nil context:nil];
        [self refreshBackgroundColor];
        [UIView commitAnimations];
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state {
    switch (state) {
        case UIControlStateNormal:
            self.normalColor = backgroundColor;
            break;
        case UIControlStateHighlighted:
            self.highlightColor = backgroundColor;
            break;
        case UIControlStateSelected:
            self.selectedColor = backgroundColor;
        default:
            break;
    }
    [self refreshBackgroundColor];
}

- (void)refreshBackgroundColor {
    if (!self.enabled) {
        float r,g,b;
        [self.normalColor getRed:&r green:&g blue:&b alpha:NULL];
        self.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:0.5f];
        return;
    }
    
    if (self.highlighted) {
        self.backgroundColor = self.highlightColor;
        return;
    }
    
    if (self.selected) {
        self.backgroundColor = self.selectedColor;
        return;
    }
    
    self.backgroundColor = self.normalColor;
}



@end
