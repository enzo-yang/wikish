//
//  WikiHistory.h
//  Wikish
//
//  Created by YANG ENZO on 13-1-17.
//  Copyright (c) 2013年 Side Trip. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WikiRecord.h"
@interface WikiHistory : NSObject {
    NSMutableArray *_history;
}
@property (nonatomic, readonly) NSArray *history;

+ (WikiHistory *)sharedInstance;
- (void)addRecord:(WikiRecord*)record;
- (void)removeRecord:(WikiRecord*)record;
- (WikiRecord *)lastRecord;

@end
