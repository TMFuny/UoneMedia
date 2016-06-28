//
//  WspxDownloadPreviewItem.m
//  UOneMedia
//
//  Created by MrChens on 16/6/27.
//  Copyright © 2016年 chiannetcenter. All rights reserved.
//

#import "WspxDownloadPreviewItem.h"

@implementation WspxDownloadPreviewItem

- (NSString *)previewItemTitle {
    if (self.title && self.title.length != 0) {
        return self.title;
    }
    return self.previewItemTitle;
}

- (NSURL *)previewItemURL {
    return self.localFileUrl;
}
@end
