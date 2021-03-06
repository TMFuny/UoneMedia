/*
 * Project: HWIFileDownload
 
 * File: HWIFileDownloadItem.h
 *
 */

/***************************************************************************
 
 Copyright (c) 2014-2016 Heiko Wichmann
 
 https://github.com/Heikowi/HWIFileDownload
 
 This software is provided 'as-is', without any expressed or implied warranty.
 In no event will the authors be held liable for any damages
 arising from the use of this software.
 
 Permission is granted to anyone to use this software for any purpose,
 including commercial applications, and to alter it and redistribute it
 freely, subject to the following restrictions:
 
 1. The origin of this software must not be misrepresented;
 you must not claim that you wrote the original software.
 If you use this software in a product, an acknowledgment
 in the product documentation would be appreciated
 but is not required.
 
 2. Altered source versions must be plainly marked as such,
 and must not be misrepresented as being the original software.
 
 3. This notice may not be removed or altered from any source distribution.
 
 ***************************************************************************/


#import <Foundation/Foundation.h>


/**
 HWIFileDownloadItem is used internally by HWIFileDownloader.
 */
@interface HWIFileDownloadItem : NSObject

- (nullable instancetype)initWithDownloadToken:(nonnull NSString *)aDownloadToken
                           sessionDownloadTask:(nullable NSURLSessionDownloadTask *)aSessionDownloadTask
                                 urlConnection:(nullable NSURLConnection *)aURLConnection;


@property (nonatomic, strong, nullable) NSDate *downloadStartDate;
@property (nonatomic, assign) NSTimeInterval downloadMaxAge;
@property (nonatomic, strong, nullable) NSString *downloadSuggestedFileName;
@property (nonatomic, assign) int64_t receivedFileSizeInBytes;
@property (nonatomic, assign) int64_t expectedFileSizeInBytes;
@property (nonatomic, assign) int64_t resumedFileSizeInBytes;
@property (nonatomic, assign) NSUInteger bytesPerSecondSpeed;
@property (nonatomic, strong, readonly, nonnull) NSProgress *progress;
@property (nonatomic, strong, readonly, nonnull) NSString *downloadToken;

@property (nonatomic, strong, readonly, nullable) NSURLSessionDownloadTask *sessionDownloadTask;

@property (nonatomic, strong, readonly, nullable) NSURLConnection *urlConnection;

@property (nonatomic, strong, nullable) NSArray<NSString *> *errorMessagesStack;
@property (nonatomic, assign) NSInteger lastHttpStatusCode;
@property (nonatomic, strong, nullable) NSURL *finalLocalFileURL;
@property (nonatomic, assign) BOOL isSupportResumeWithoutRestart;

@property (nonatomic, assign) NSTimeInterval lastChangeTime;

- (nullable HWIFileDownloadItem *)init __attribute__((unavailable("use initWithDownloadToken:sessionDownloadTask:urlConnection:")));
+ (nullable HWIFileDownloadItem *)new __attribute__((unavailable("use initWithDownloadToken:sessionDownloadTask:urlConnection:")));

@end
