//
//  WspxDownloadItem.m
//  WebViewDemo
//
//  Created by wadahana on 5/3/16.
//  Copyright © 2016 ChinaNetCenter. All rights reserved.
//

#import "WspxDownloadItem.h"
#import "HWIFileDownloadProgress.h"

@interface WspxDownloadItem() <NSCoding>

@property (nonatomic, strong, nullable) HWIFileDownloadProgress *progress;
@property (nonatomic, strong, readwrite, nonnull) NSString *downloadIdentifier;
@property (nonatomic, strong, readwrite, nonnull) NSURL *remoteURL;

@end


@implementation WspxDownloadItem


- (nullable instancetype)initWithDownloadIdentifier:(nonnull NSString *)aDownloadIdentifier
                                          remoteURL:(nonnull NSURL *)aRemoteURL
{
    self = [super init];
    if (self)
    {
        self.downloadIdentifier = aDownloadIdentifier;
        self.remoteURL = aRemoteURL;
        self.localFileURL = nil;
        self.status = WspxDownloadItemStatusNotStarted;
        self.lastUpdateTime = nil;
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.downloadIdentifier forKey:@"downloadIdentifier"];
    [aCoder encodeObject:self.remoteURL forKey:@"remoteURL"];
    [aCoder encodeObject:self.localFileURL forKey:@"localFileURL"];
    [aCoder encodeObject:@(self.status) forKey:@"status"];
    if (self.resumeData.length > 0)
    {
        [aCoder encodeObject:self.resumeData forKey:@"resumeData"];
    }
    if (self.progress)
    {
        [aCoder encodeObject:self.progress forKey:@"progress"];
    }
    if (self.downloadError)
    {
        [aCoder encodeObject:self.downloadError forKey:@"downloadError"];
    }
    if (self.downloadErrorMessagesStack)
    {
        [aCoder encodeObject:self.downloadErrorMessagesStack forKey:@"downloadErrorMessagesStack"];
    }
    [aCoder encodeObject:@(self.expectedFileSizeInBytes) forKey:@"expectedFileSizeInBytes"];
    [aCoder encodeObject:@(self.lastHttpStatusCode) forKey:@"lastHttpStatusCode"];
}


- (id)initWithCoder:(NSCoder *)aCoder
{
    self = [super init];
    if (self)
    {
        self.downloadIdentifier = [aCoder decodeObjectForKey:@"downloadIdentifier"];
        self.remoteURL = [aCoder decodeObjectForKey:@"remoteURL"];
        self.localFileURL = [aCoder decodeObjectForKey:@"localFileURL"];
        self.status = [[aCoder decodeObjectForKey:@"status"] unsignedIntegerValue];
        self.resumeData = [aCoder decodeObjectForKey:@"resumeData"];
        self.progress = [aCoder decodeObjectForKey:@"progress"];
        self.downloadError = [aCoder decodeObjectForKey:@"downloadError"];
        self.downloadErrorMessagesStack = [aCoder decodeObjectForKey:@"downloadErrorMessagesStack"];
        self.lastHttpStatusCode = [[aCoder decodeObjectForKey:@"lastHttpStatusCode"] integerValue];
    }
    return self;
}

#pragma mark - Description

- (NSString *)description
{
    NSMutableDictionary *aDescriptionDict = [NSMutableDictionary dictionary];
    [aDescriptionDict setObject:self.downloadIdentifier forKey:@"downloadIdentifier"];
    [aDescriptionDict setObject:self.remoteURL forKey:@"remoteURL"];
    if (self.localFileURL) {
        [aDescriptionDict setObject:self.localFileURL forKey:@"localFileURL"];
    }
    [aDescriptionDict setObject:@(self.status) forKey:@"status"];
    if (self.progress)
    {
        [aDescriptionDict setObject:self.progress forKey:@"progress"];
    }
    if (self.resumeData.length > 0)
    {
        [aDescriptionDict setObject:@"hasData" forKey:@"resumeData"];
    }
    
    NSString *aDescriptionString = [NSString stringWithFormat:@"%@", aDescriptionDict];
    
    return aDescriptionString;
}

- (float)downloadProgress {
    if (self.progress) {
//        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
//            return self.progress.nativeProgress.fractionCompleted;
//        }  else {
            return self.progress.downloadProgress;
//        }
    }
    return 0;
}

- (int64_t)receivedFileSizeInBytes {
    if (self.progress) {
        return self.progress.receivedFileSize;
    }
    return 0;
}

- (int64_t)expectedFileSizeInBytes {
    if (self.progress) {
        return self.progress.expectedFileSize;
    }
    return 0;
}

- (NSUInteger)bytesPerSecondSpeed {
    if (self.progress) {
        return self.progress.bytesPerSecondSpeed;
    }
    return 0;
}
@end
