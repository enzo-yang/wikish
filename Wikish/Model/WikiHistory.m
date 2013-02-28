//
//  WikiHistory.m
//  Wikish
//
//  Created by YANG ENZO on 13-1-17.
//  Copyright (c) 2013年 Side Trip. All rights reserved.
//

#import "WikiHistory.h"
#import "FileUtil.h"

#define kHistoryPath        [[FileUtil documentPath] stringByAppendingPathComponent:@"history.arr"]
#define kHistoryCapacity    200

@interface WikiHistory()

- (NSMutableArray *)_historyFromFile;
- (void)_appWillResignActive;
- (void)_save;

@end

@implementation WikiHistory

@synthesize history = _history;

+ (WikiHistory *)sharedInstance {
    static WikiHistory *instance = nil;
    @synchronized(self) {
        if (!instance) {
            instance = [WikiHistory new];
        }
    }
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        _history = [[self _historyFromFile] retain];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}

- (NSMutableArray *)_historyFromFile {
    NSMutableArray *history = (NSMutableArray *)[FileUtil deserializeObjectAtPath:kHistoryPath];
    if (!history) history = [[NSMutableArray new] autorelease];
    return history;
}

- (void)_save {
    [FileUtil serializeObject:self.history toPath:kHistoryPath];
}

- (void)_appWillResignActive:(NSNotification *)notification {
    [self _removeExtraRecords];
    [self _save];
}

- (void)_removeExtraRecords {
    @synchronized(self) {
        int len = [_history count] - kHistoryCapacity;
        if (len > 0) {
            [_history removeObjectsInRange:NSMakeRange(0, len)];
        }
    }
}

- (void)addRecord:(WikiRecord *)record {
    @synchronized(self) {
        [self _removeRecord:record];
        [_history addObject:record];
    }
}

- (void)removeRecord:(WikiRecord *)record {
    @synchronized(self) {
        [self _removeRecord:record];
    }
}

- (void)_removeRecord:(WikiRecord *)record {
    for (int i=[_history count]-1; i>=0; --i) {
        WikiRecord *theRecord = [_history objectAtIndex:i];
        if ([theRecord isEqual:record]) {
            [_history removeObjectAtIndex:i];
            break;
        }
    }
}

@end
