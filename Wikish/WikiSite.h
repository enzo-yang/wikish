//
//  WikiSite.h
//  Wikish
//
//  Created by YANG ENZO on 12-11-9.
//  Copyright (c) 2012年 Side Trip. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WikiSite : NSObject<NSCopying> {
    NSString *_name;
    NSString *_lang;
    NSString *_sublang;
}

- (id)initWithName:(NSString *)name lang:(NSString *)lang sublang:(NSString *)sublang;
- (id)initWithDictionary:(NSDictionary *)dict;

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *lang;
@property (nonatomic, readonly) NSString *sublang;

- (BOOL)sameAs:(WikiSite *)site;
- (void)copy:(WikiSite *)site;

- (NSDictionary *)toDictionary;

@end
