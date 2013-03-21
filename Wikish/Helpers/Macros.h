//
//  Macros.h
//  Wikish
//
//  Created by ENZO YANG on 13-3-21.
//  Copyright (c) 2013年 Side Trip. All rights reserved.
//

#ifndef Wikish_Macros_h
#define Wikish_Macros_h

#ifdef DEBUG
#define LOG(xx, ...) NSLog(xx, ##__VA_ARGS__)
#else
#define LOG(xx, ...) ((void)0)
#endif

#endif
