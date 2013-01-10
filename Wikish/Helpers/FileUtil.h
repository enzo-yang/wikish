//
//  FileUtil.h
//  CarInfomation
//
//  Created by Enzo Yang on 11-12-30.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileUtil : NSObject

+ (NSString *)documentPath;
+ (NSString *)libraryPath;
+ (NSString *)cachePath;
// 序列化对象到文件中
+ (void)serializeObject:(NSObject*)obj toPath:(NSString*)path;
// 从文件中加载对象
+ (NSObject*)deserializeObjectAtPath:(NSString*)path;
// 是不是文件夹路径
+ (BOOL)isFolderAtPath:(NSString *)path;
// 不让icloud备份
+ (void) addSkipBackupAttributeToFile:(NSString*)path;
+ (void) addSkipBackupAttributeToFileUrl:(NSURL*)url;
+ (void) addSkipBackupAttributeToFilesUnderFolder:(NSString*)folderPath;

// 取得文件的大小
+ (int)fileSizeAtPath:(NSString*)path;

// 父目录没有的话会帮助创建父目录
+ (BOOL)createFolderAtPath:(NSString *)path;

@end
