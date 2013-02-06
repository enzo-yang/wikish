//
//  WikiRecord.h
//  Wikish
//
//  Created by YANG ENZO on 13-1-17.
//  Copyright (c) 2013年 Side Trip. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WikiSite.h"

@interface WikiRecord : WikiSite {
    NSString *_title;
}

@property (nonatomic, readonly) NSString *title;

- (id)initWithSite:(WikiSite *)site title:(NSString *)title;
- (id)initWithLang:(NSString *)lang sublang:(NSString *)sublang title:(NSString *)title;

- (BOOL)isEqual:(id)object;

@end
