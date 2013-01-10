//
//  NSString+Wikish.m
//  Wikish
//
//  Created by YANG ENZO on 12-11-18.
//  Copyright (c) 2012年 Side Trip. All rights reserved.
//

#import "NSString+Wikish.h"

@implementation NSString(Wikish)

- (NSString *)urlEncodedString {
    NSString *string = [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)urlDecodedString {
    return [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end
