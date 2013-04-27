//
//  WikiSite.m
//  Wikish
//
//  Created by YANG ENZO on 12-11-9.
//  Copyright (c) 2012年 Side Trip. All rights reserved.
//

#import "WikiSite.h"

static NSString *const kNameKey     = @"name";
static NSString *const kLangKey     = @"lang";
static NSString *const kSubLangKey   = @"sub-lang";

@interface WikiSite()

- (void)_clean;
- (BOOL)_isSiteValid;

@end

@implementation WikiSite

- (id)initWithCoder:(NSCoder *)aDecoder {
    NSString *name = [aDecoder decodeObject];
    NSString *lang = [aDecoder decodeObject];
    NSString *sublang = [aDecoder decodeObject];
    return [self initWithName:name lang:lang sublang:sublang];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_name];
    [aCoder encodeObject:_lang];
    [aCoder encodeObject:_sublang];
}

- (id)initWithLang:(NSString *)lang sublang:(NSString *)sublang {
    NSString *name = [NSString stringWithFormat:@"%@[%@]", lang, sublang];
    return [self initWithName:name lang:lang sublang:sublang];
}

- (id)initWithName:(NSString *)name lang:(NSString *)lang sublang:(NSString *)sublang {
    self = [super init];
    if (self) {
        _name = [name copy];
        _lang = [lang copy];
        _sublang = [sublang copy];
        
        if (![self _isSiteValid]) {
            self = nil;
        }
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    WikiSite *site = [[[self class] allocWithZone:zone] initWithName:_name lang:_lang sublang:_sublang];
    return site;
}

- (id)initWithDictionary:(NSDictionary *)dict {
    NSString *name = [dict objectForKey:kNameKey];
    NSString *lang = [dict objectForKey:kLangKey];
    NSString *sublang = [dict objectForKey:kSubLangKey];
    return [self initWithName:name lang:lang sublang:sublang];
}

- (void)dealloc {
    [self _clean];
}

- (NSString *)briefName {
    if ([self.sublang isEqualToString:@"wiki"]) return [self.lang uppercaseString];
    
    return [self.name substringToIndex:1];
}

- (BOOL)sameAs:(WikiSite *)site {
    return ([_lang isEqualToString:site.lang] && [_sublang isEqualToString:site.sublang]);
}

- (void)copy:(WikiSite *)site {
    [self _clean];
    _name   = [site.name copy];
    _lang   = [site.lang copy];
    _sublang = [site.sublang copy];
}

- (NSDictionary *)toDictionary {
    return @{
             kNameKey: _name,
             kLangKey: _lang,
             kSubLangKey: _sublang,
             };
}

- (void)_clean {
        _name = nil;
        _lang = nil;
      _sublang = nil;
}

- (BOOL)_isSiteValid {
    Class stringClass = [NSString class];
    return ([_name isKindOfClass:stringClass] &&
            [_lang isKindOfClass:stringClass] &&
            [_sublang isKindOfClass:stringClass]);
}

@end
