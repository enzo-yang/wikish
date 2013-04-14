//
//  FileUtil.m
//  CarInfomation
//
//  Created by Enzo Yang on 11-12-30.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "FileUtil.h"
#include <sys/xattr.h>
@implementation FileUtil

+ (NSString*)documentPath {
    static NSString *path = nil;
    @synchronized(self) {
        if (path == nil) {
            NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            path = [pathArray objectAtIndex:0];
        }
    }
    return path;
}

+ (NSString*)libraryPath {
    static NSString *path = nil;
    @synchronized(self) {
        if (path == nil) {
            NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
            path = [pathArray objectAtIndex:0];
        }
    }
    return path;
}

+ (NSString *)cachePath {
    static NSString *path = nil;
    @synchronized(self) {
        if (path == nil) {
            NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            path = [pathArray objectAtIndex:0];
        }
    }
    return path;
}


+ (void)serializeObject:(NSObject*)obj toPath:(NSString*)path {
  NSAssert(obj != nil, @"object to serialize is nil");
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj];
  [data writeToFile:path atomically:YES];
}

+ (NSObject*)deserializeObjectAtPath:(NSString*)path {
  // 如果文件不存在 则 返回nil
  if (![[NSFileManager defaultManager] fileExistsAtPath:path]) return nil;
  
  NSData *data = [NSData dataWithContentsOfFile:path];
  NSObject *obj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
  
  return obj;
}

+ (BOOL)isFolderAtPath:(NSString *)path {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSError *error = nil;
  NSDictionary *attrDict = [fileManager attributesOfItemAtPath:path error:&error];
  if (!attrDict || ![[attrDict objectForKey:NSFileType] isEqualToString:NSFileTypeDirectory]) {
    return NO;
  }
  return YES;
}

+ (void) addSkipBackupAttributeToFile:(NSString*)path {
  NSURL *url = [NSURL fileURLWithPath:path];
  [FileUtil addSkipBackupAttributeToFileUrl:url];
}

+ (void) addSkipBackupAttributeToFileUrl:(NSURL*)url {
  u_int8_t b = 1; 
  setxattr([[url path] fileSystemRepresentation], "com.apple.MobileBackup", &b, 1, 0, 0);
}

+ (void) addSkipBackupAttributeToFilesUnderFolder:(NSString*)folderPath {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSArray *elementArray = [fileManager contentsOfDirectoryAtPath:folderPath error:nil];
  for (NSString* elementName in elementArray) {
    LOG(@"%@", elementName);
    NSString *aPath = [folderPath stringByAppendingPathComponent:elementName];
    if ([FileUtil isFolderAtPath:aPath]) {
      [FileUtil addSkipBackupAttributeToFilesUnderFolder:aPath];
    } else {
      [FileUtil addSkipBackupAttributeToFile:aPath];
    }
  }
}

+ (int)fileSizeAtPath:(NSString *)path {
  NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:NO];
  if (fileAttributes == nil) return 0;
  NSNumber *nFileSize = [fileAttributes objectForKey:NSFileSize];
  return (int)[nFileSize longLongValue];
}

+ (BOOL)createFolderAtPath:(NSString *)path {
    return [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
}

@end
