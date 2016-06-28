//
//  WspxDownloadPreviewItem.h
//  UOneMedia
//
//  Created by MrChens on 16/6/27.
//  Copyright © 2016年 chiannetcenter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuickLook/QuickLook.h>
@interface WspxDownloadPreviewItem : NSObject<QLPreviewItem>

@property (nullable, nonatomic, strong) NSString *title;
@property (nullable, nonatomic, strong) NSURL *localFileUrl;
@end
