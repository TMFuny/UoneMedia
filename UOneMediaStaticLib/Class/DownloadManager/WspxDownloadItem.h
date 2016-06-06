//
//  WspxDownloadItem.h
//  WebViewDemo
//
//  Created by wadahana on 5/3/16.
//  Copyright © 2016 ChinaNetCenter. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, WspxDownloadItemStatus) {
    WspxDownloadItemStatusNotStarted = 0,
    WspxDownloadItemStatusStarted,
    WspxDownloadItemStatusCompleted,
    WspxDownloadItemStatusPaused,
    WspxDownloadItemStatusCancelled,
    WspxDownloadItemStatusInterrupted,
    WspxDownloadItemStatusError
};


@interface WspxDownloadItem : NSObject

- (nullable instancetype)initWithDownloadIdentifier:(nonnull NSString *)aDownloadIdentifier
                                          remoteURL:(nonnull NSURL *)aRemoteURL;


@property (nonatomic, strong, readonly, nonnull) NSString *downloadIdentifier;
@property (nonatomic, strong, readonly, nonnull) NSURL *remoteURL;
@property (nonatomic, strong, nonnull) NSURL *localFileURL;

@property (nonatomic, strong, nullable) NSData *resumeData;
@property (nonatomic, assign) WspxDownloadItemStatus status;

@property (nonatomic, strong, nullable) NSError *downloadError;
@property (nonatomic, strong, nullable) NSArray<NSString *> *downloadErrorMessagesStack;
@property (nonatomic, assign) NSInteger lastHttpStatusCode;
@property (nonatomic, readonly) int64_t receivedFileSizeInBytes;
@property (nonatomic, readonly) int64_t expectedFileSizeInBytes;
@property (nonatomic, readonly) float downloadProgress;
@property (nonatomic, assign, readonly) NSUInteger bytesPerSecondSpeed;
@property (nonatomic, strong, nullable) NSDate * lastUpdateTime;

@end