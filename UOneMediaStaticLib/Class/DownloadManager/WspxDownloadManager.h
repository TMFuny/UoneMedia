//
//  WspxDownloadManager.h
//  WebViewDemo
//
//  Created by wuxin on 5/3/16.
//  Copyright © 2016 ChinaNetCenter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WspxDownloadItem.h"
#import "UOMReachability.h"

extern NSString* _Nonnull const wspxDownloadDidCompleteNotification;
extern NSString* _Nonnull const wspxDownloadProgressChangedNotification;
extern NSString* _Nonnull const wspxTotalDownloadProgressChangedNotification;
extern NSString* _Nonnull const wspxDownloadDiskStorageNotEnoughNotification;
@class WspxDownloadItem;

@protocol WspxDownloadManagerDelegate <NSObject>

- (void)downloadProgressDidChangedWithItem:(nonnull WspxDownloadItem *)aChangedDownloadItem;
- (void)downloadProgressDidCompleteWithItem:(nonnull WspxDownloadItem *)aCompletedDownloadItem;
- (void)downloadProgressDidPendingWithItem:(nonnull WspxDownloadItem *)aPendingDownloadItem;
@optional
- (void)downloadProgressReachableChanged:(nonnull UOMReachability *)reachability;
@end


@interface WspxDownloadManager : NSObject

@property(nonnull, nonatomic, strong) NSMutableArray<WspxDownloadItem *> *downloadItems;
@property(nullable, nonatomic, weak) id<WspxDownloadManagerDelegate>delegate;
@property (nonatomic, readonly) UOMReachability *internetReachability;


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

- (BOOL)hasActiveDownloads;

- (nonnull NSString *)getDiskUsageAndStorageString;

- (uint64_t)getFreeDiskspaceInBytes;
@end
//TODO NSURLSessionDownloadTask issues with Storage almost full disk warnings https://forums.developer.apple.com/thread/43263