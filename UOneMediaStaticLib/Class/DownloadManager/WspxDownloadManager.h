//
//  WspxDownloadManager.h
//  WebViewDemo
//
//  Created by wuxin on 5/3/16.
//  Copyright © 2016 ChinaNetCenter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WspxDownloadItem.h"


extern NSString* _Nonnull const wspxDownloadDidCompleteNotification;
extern NSString* _Nonnull const wspxDownloadProgressChangedNotification;
extern NSString* _Nonnull const wspxTotalDownloadProgressChangedNotification;

@class WspxDownloadItem;

@interface WspxDownloadManager : NSObject

@property(nonnull, nonatomic, strong) NSMutableArray<WspxDownloadItem *> *downloadItems;




+ (nonnull instancetype) shareInstance;

- (void)startDownloadWithItem:(nonnull WspxDownloadItem *)aDownloadItem;

- (void)resumeDownloadWithItem:(nonnull WspxDownloadItem *)aDownloadItem;

- (void)cancelDownloadWithItem:(nonnull WspxDownloadItem *)aDownloadItem;

- (void)cancelAllDownloadItems;

- (void)pauseDownloadWithItem:(nonnull WspxDownloadItem *)aDownloadItem;

- (void)pauseAllDownloadItems;

- (void)removeDownloadWithItem:(nonnull WspxDownloadItem *)aDownloadItem;

- (void)removeAllDownloadItems;

- (NSDictionary *)downloadItemInfomation:(nonnull WspxDownloadItem *)aDownloadItem;

- (NSString *)getDiskUsageAndStorageString;
@end