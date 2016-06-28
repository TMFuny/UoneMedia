//
//  UoneUtilsDefine.h
//  UOneMedia
//
//  Created by MrChens on 16/6/27.
//  Copyright © 2016年 chiannetcenter. All rights reserved.
//

#ifndef UoneUtilsDefine_h
#define UoneUtilsDefine_h
#import "UIDeviceHardware.h"

#define kScreenWidth  ([UIScreen mainScreen].bounds.size.width)
#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)

#define UIDefaultFont(size)  ([UIFont systemFontOfSize:(size)])

#define CGFloatFromHex(value) ((value & 0xFF)/255.0)

#define UIColorFromHex(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define CGAffineTransformReset(t) do{ if (!CGAffineTransformIsIdentity(t)){ t = CGAffineTransformIdentity; } }while(0)

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define INTERFACE_IS_PAD     ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define INTERFACE_IS_PHONE   ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)

//判断是否iphone4/4s
#define isIPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)

//判断是否iphone5/5s
#define isIPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
//判断是否iphone6
#define isIPhone6 [[UIDeviceHardware platformString] isEqualToString:@"iPhone 6"]

#define isIPhone6s [[UIDeviceHardware platformString] isEqualToString:@"iPhone 6S"]

//判断是否iphone6p
#define isIPhone6p [[UIDeviceHardware platformString] isEqualToString:@"iPhone 6 Plus"]

#define isIPhone6sp [[UIDeviceHardware platformString] isEqualToString:@"iPhone 6S Plus"]

#define isSimulator [[UIDeviceHardware platformString] isEqualToString:@"Simulator"]
#endif /* UoneUtilsDefine_h */
