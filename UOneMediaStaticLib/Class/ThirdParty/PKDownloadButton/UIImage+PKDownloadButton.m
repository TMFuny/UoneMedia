//
//  UIImage+PKDownloadButton.m
//  Download
//
//  Created by Pavel on 31/05/15.
//  Copyright (c) 2015 Katunin. All rights reserved.
//

#import "UIImage+PKDownloadButton.h"

@implementation UIImage (PKDownloadButton)

+ (UIImage *)stopImageOfSize:(CGFloat)size color:(UIColor *)color {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), NO, 1.0f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color setStroke];
    
    CGRect stopImageRect = CGRectMake(0.f, 0.f, size, size);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextAddRect(context, stopImageRect);
    CGContextFillRect(context, stopImageRect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return image;
}
//2个竖线
+ (UIImage *)downloadingImageOfSize:(CGFloat)size color:(UIColor *)color {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), NO, 0.0f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (size<= 8) {
        CGContextMoveToPoint(context, 1, 0);
        CGContextAddLineToPoint(context, 1, size);

        CGContextMoveToPoint(context, size-1, 0);
        CGContextAddLineToPoint(context, size-1, size);
    } else {
        
        CGContextMoveToPoint(context, size*2/3, size/4);
        CGContextAddLineToPoint(context, size*2/3, size*3/4);
        
        CGContextMoveToPoint(context, size/3, size/4);
        CGContextAddLineToPoint(context, size/3, size*3/4);
    }
    
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextStrokePath(context);
    UIImage *downloadingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return downloadingImage;
}
//向下的箭头
+ (UIImage *)pauseImageOfSize:(CGFloat)size color:(UIColor *)color {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), NO, 0.0f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (size <= 8) {
        CGContextMoveToPoint(context, size/2, 0);
        CGContextAddLineToPoint(context, size/2, size);
        
        CGContextMoveToPoint(context, size/2, size);
        CGContextAddLineToPoint(context, 0,size/2);
        
        CGContextMoveToPoint(context, size/2, size);
        CGContextAddLineToPoint(context, size, size/2);

    } else {
        CGContextMoveToPoint(context, size/2, size/4);
        CGContextAddLineToPoint(context, size/2, size*3/4);
        //left
        CGContextMoveToPoint(context, size/2, size*3/4);
        CGContextAddLineToPoint(context, size/4,size/2);
        //right
        CGContextMoveToPoint(context, size/2, size*3/4);
        CGContextAddLineToPoint(context, size*3/4, size/2);
    }
    
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextStrokePath(context);
    UIImage *pauseImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return pauseImage;
}

+ (UIImage *)buttonBackgroundWithColor:(UIColor *)color {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(30.f, 30.f), NO, 0.0f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color setStroke];
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(2.f, 2.f, 26.f, 26.f)
                                                          cornerRadius:4.f];
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    bezierPath.lineWidth = 1.f;
    [bezierPath stroke];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(10.f, 10.f, 10.f, 10.f)];
}

+ (UIImage *)highlitedButtonBackgroundWithColor:(UIColor *)color {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(30.f, 30.f), NO, 0.0f);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color setStroke];
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(2.f, 2.f, 26.f, 26.f)
                                                          cornerRadius:4.f];
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    bezierPath.lineWidth = 1.f;
    [bezierPath stroke];
    [color setFill];
    [bezierPath fill];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(10.f, 10.f, 10.f, 10.f)];
}

@end
