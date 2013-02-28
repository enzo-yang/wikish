//
//  LangLink.h
//  Wikish
//
//  Created by YANG ENZO on 13-1-6.
//  Copyright (c) 2013年 Side Trip. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LangLink : NSObject<NSCoding>

@property (nonatomic, copy) NSString *lang;
@property (nonatomic, copy) NSString *title;

- (id)initWithDict:(NSDictionary *)dict;

@end
