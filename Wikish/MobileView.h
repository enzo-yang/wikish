//
//  MobileView.h
//  Wikish
//
//  Created by YANG ENZO on 12-11-18.
//  Copyright (c) 2012年 Side Trip. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MobileView : NSObject {
    NSString        *_title;
    NSString        *_headHTML;
    NSMutableArray  *_sections;
}
- (id)initWithTitle:(NSString *)title;

- (BOOL)parseSectionsFromDict:(NSDictionary *)dict;
- (BOOL)parseHeadHTMLFromDict:(NSDictionary *)dict;

- (NSString *)htmlFilePath;

@end
