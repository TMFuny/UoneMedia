//
//  NSBundle+WspxUtility.m
//  UOneMedia
//
//  Created by wuxin on 5/26/16.
//  Copyright © 2016 chiannetcenter. All rights reserved.
//

#import "NSBundle+WspxUtility.h"

@implementation NSBundle (WspxUtility)

+ (NSBundle *)UOneMediaBundle {
    static dispatch_once_t onceToken;
    static NSBundle *sUOneMediaBundle = nil;
    dispatch_once(&onceToken, ^{
        sUOneMediaBundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"UOneMedia" withExtension:@"bundle"]];
    });
    return sUOneMediaBundle;
}

@end
