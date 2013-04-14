//
//  LangLink.m
//  Wikish
//
//  Created by YANG ENZO on 13-1-6.
//  Copyright (c) 2013年 Side Trip. All rights reserved.
//

#import "LangLink.h"

@implementation LangLink

@synthesize lang, title;

- (id)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.lang = [dict objectForKey:@"lang"];
        self.title = [dict objectForKey:@"*"];
        
        if (!self.lang || !self.title) {
            self = nil;
        }
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.lang = [aDecoder decodeObjectForKey:@"lang"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.lang forKey:@"lang"];
    [aCoder encodeObject:self.title forKey:@"title"];
}


@end
