//
//  WikiRecord.m
//  Wikish
//
//  Created by YANG ENZO on 13-1-17.
//  Copyright (c) 2013年 Side Trip. All rights reserved.
//

#import "WikiRecord.h"

@implementation WikiRecord

@synthesize title = _title;

- (id)initWithLang:(NSString *)lang sublang:(NSString *)sublang title:(NSString *)title {
    WikiSite *site = [[WikiSite alloc] initWithLang:lang sublang:sublang];
    return [self initWithSite:site title:title];
}

- (id)initWithSite:(WikiSite *)site title:(NSString *)title {
    self = [super initWithName:site.name lang:site.lang sublang:site.sublang];
    if (self) {
        if (title) {
            _title = [title copy];
        } else {
            [self release];
            self = nil;
        }
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _title = [[aDecoder decodeObject] copy];
        if (!_title) {
            [self release];
            self = nil;
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.title];
}

- (id)copyWithZone:(NSZone *)zone {
    WikiRecord *record = [[WikiRecord allocWithZone:zone] initWithName:self.name lang:self.lang sublang:self.sublang];
    _title = [self.title copy];
    return record;
}

- (void)dealloc {
    [_title release];
    [super dealloc];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[WikiRecord class]]) {
        WikiRecord *record = (WikiRecord *)object;
        return ([self.lang isEqualToString:record.lang] &&
                [self.title isEqualToString:record.title]);
    }
    return NO;
}

@end
