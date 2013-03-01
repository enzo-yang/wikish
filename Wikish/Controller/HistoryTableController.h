//
//  HistoryTableController.h
//  Wikish
//
//  Created by ENZO YANG on 13-3-1.
//  Copyright (c) 2013年 Side Trip. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainTableController.h"

@class WikiHistory;

@interface HistoryTableController : MainTableController

@property (nonatomic, readonly) WikiHistory *history;

@end
