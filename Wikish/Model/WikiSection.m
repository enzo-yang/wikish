//
//  WikiSection.m
//  Wikish
//
//  Created by YANG ENZO on 13-1-6.
//  Copyright (c) 2013年 Side Trip. All rights reserved.
//

#import "WikiSection.h"
#import "AutoPropertyRelease.h"

@implementation WikiSection

@synthesize level, line, anchor, index;

- (id)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        NSNumber *toclevel = [dict objectForKey:@"toclevel"];
        if (toclevel) self.level = [toclevel unsignedIntegerValue];
        
        self.line = [dict objectForKey:@"line"];
        self.anchor = [dict objectForKey:@"anchor"];
        self.index = [dict objectForKey:@"number"];
        
        if (!self.line || !self.anchor) {
            [self release];
            self = nil;
        }
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.level = [aDecoder decodeIntegerForKey:@"level"];
        self.line = [aDecoder decodeObjectForKey:@"line"];
        self.anchor = [aDecoder decodeObjectForKey:@"anchor"];
        self.index = [aDecoder decodeObjectForKey:@"index"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:self.level forKey:@"level"];
    [aCoder encodeObject:self.line forKey:@"line"];
    [aCoder encodeObject:self.anchor forKey:@"anchor"];
    [aCoder encodeObject:self.index forKey:@"index"];
}

- (void)dealloc {
    [AutoPropertyRelease releaseProperties:self thisClass:[WikiSection class]];
    [super dealloc];
}

@end
