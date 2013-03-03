//
//  WikiSection.h
//  Wikish
//
//  Created by YANG ENZO on 13-1-6.
//  Copyright (c) 2013年 Side Trip. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WikiSection : NSObject<NSCoding>

@property (nonatomic, assign)   NSUInteger  level;
@property (nonatomic, copy)     NSString    *line;
@property (nonatomic, copy)     NSString    *anchor;
@property (nonatomic, copy)     NSString    *index;

- (id)initWithDict:(NSDictionary *)dict;

@end
