//
//  WspxDownloadManager.m
//  WebViewDemo
//
//  Created by wuxin on 5/3/16.
//  Copyright © 2016 ChinaNetCenter. All rights reserved.
//

#import "WspxDownloadManager.h"
#import "WspxDownloadItem.h"
#import "HWIFileDownloader.h"
#import "HWIFileDownloadItem.h"


static void *WspxDownloadManagerProgressObserverContext = &WspxDownloadManagerProgressObserverContext;

NSString* _Nonnull const wspxDownloadDidCompleteNotification            = @"wspxDownloadDidCompleteNotification";
NSString* _Nonnull const wspxDownloadProgressChangedNotification        = @"wspxDownloadProgressChangedNotification";
NSString* _Nonnull const wspxTotalDownloadProgressChangedNotification   = @"wspxTotalDownloadProgressChangedNotification";
NSString* _Nonnull const wspxDownloadDiskStorageNotEnoughNotification   = @"wspxDownloadDiskStorageNotEnoughNotification";

@interface WspxDownloadManager() <HWIFileDownloadDelegate>

@property(nonnull, nonatomic, strong) HWIFileDownloader *fileDownloader;
@property (nonatomic, readwrite) UOMReachability *internetReachability;
@end

@implementation WspxDownloadManager
{
    NSProgress *_progress;
    NSUInteger _networkActivityIndicatorCount;
    
}
@synthesize downloadItems;

+ (instancetype) shareInstance {
    static WspxDownloadManager* sInstance;
    static dispatch_once_t onceTake;
    dispatch_once(&onceTake, ^{
        sInstance = [[WspxDownloadManager alloc] init];
    });
    return sInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.internetReachability = [UOMReachability reachabilityForInternetConnection];
        [self.internetReachability startNotifier];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kUoneReachabilityChangedNotification object:nil];
        
        _networkActivityIndicatorCount = 0;
        
        _progress = [NSProgress progressWithTotalUnitCount:0];
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
        {
            [_progress addObserver:self
                        forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                           options:NSKeyValueObservingOptionInitial
                           context:WspxDownloadManagerProgressObserverContext];
        }

        [self setupDownloadItems];
        
        // setup downloader
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
        {
            _fileDownloader = [[HWIFileDownloader alloc] initWithDelegate:self];
        }
        else
        {
            _fileDownloader = [[HWIFileDownloader alloc] initWithDelegate:self maxConcurrentDownloads:4];
        }
        [self.fileDownloader setupWithCompletion:nil];

    }
    return self;
}

- (void)dealloc
{
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        [_progress removeObserver:self
                           forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                              context:WspxDownloadManagerProgressObserverContext];
    }
}


- (void)setupDownloadItems
{
    self.downloadItems = [self restoredDownloadItems];
    
    self.downloadItems = [[self.downloadItems sortedArrayUsingComparator:^NSComparisonResult(WspxDownloadItem*  _Nonnull aDownloadItemA, WspxDownloadItem*  _Nonnull aDownloadItemB) {
        return [aDownloadItemA.downloadIdentifier compare:aDownloadItemB.downloadIdentifier options:NSNumericSearch];
    }] mutableCopy];
}

#pragma mark - NSProgress


- (void)observeValueForKeyPath:(nullable NSString *)aKeyPath
                      ofObject:(nullable id)anObject
                        change:(nullable NSDictionary<NSString*, id> *)aChange
                       context:(nullable void *)aContext
{
    if (aContext == WspxDownloadManagerProgressObserverContext)
    {
        NSProgress *aProgress = anObject; // == self.progress
        if ([aKeyPath isEqualToString:@"fractionCompleted"])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:wspxTotalDownloadProgressChangedNotification object:aProgress];
        }
        else
        {
            NSLog(@"ERR: Invalid keyPath (%@, %d)", [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
        }
    }
    else
    {
        [super observeValueForKeyPath:aKeyPath
                             ofObject:anObject
                               change:aChange
                              context:aContext];
    }
}


- (void)resetProgressIfNoActiveDownloadsRunning
{
    BOOL aHasActiveDownloadsFlag = [_fileDownloader hasActiveDownloads];
    if (aHasActiveDownloadsFlag == NO)
    {
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
        {
            [_progress removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
        }
        NSLog(@"manager progress: %@\n", _progress);
        
        _progress = [NSProgress progressWithTotalUnitCount:0];
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
        {
            [_progress addObserver:self
                            forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                               options:NSKeyValueObservingOptionInitial
                               context:WspxDownloadManagerProgressObserverContext];
        }
    }
}

#pragma mark - Start Download

- (void)startDownloadWithItem:(nonnull WspxDownloadItem *)aDownloadItem {
    
//    [self resetProgressIfNoActiveDownloadsRunning];
    
    if ((aDownloadItem.status != WspxDownloadItemStatusCancelled) && (aDownloadItem.status != WspxDownloadItemStatusCompleted))
    {
        BOOL isDownloading = [_fileDownloader isDownloadingIdentifier:aDownloadItem.downloadIdentifier];
        if (isDownloading == NO)
        {
            aDownloadItem.status = WspxDownloadItemStatusNotStarted;
            
            [self storeDownloadItems];
            
            // kick off individual download
            if ([self isValidResumeData:aDownloadItem.resumeData]) {
                
                [_fileDownloader startDownloadWithIdentifier:aDownloadItem.downloadIdentifier usingResumeData:aDownloadItem.resumeData];
            }
            else
            {
                [_fileDownloader startDownloadWithIdentifier:aDownloadItem.downloadIdentifier fromRemoteURL:aDownloadItem.remoteURL];
            }
        }
    }
}

#pragma mark - Resume Download

- (void)resumeDownloadWithItem:(nonnull WspxDownloadItem *)aDownloadItem {
    
//    [self resetProgressIfNoActiveDownloadsRunning];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_8_4)
    {
        HWIFileDownloadProgress * progress = [aDownloadItem valueForKey:@"progress"];
        if (progress && progress.nativeProgress)
        {
            [progress.nativeProgress resume];
        }
        else
        {
            [self resumeDownloadWithIdentifier:aDownloadItem.downloadIdentifier];
        }
    }
    else
    {
        [self resumeDownloadWithIdentifier:aDownloadItem.downloadIdentifier];
    }

}

#pragma mark - Cancel Download

- (void)cancelDownloadWithItem:(nonnull WspxDownloadItem *)aDownloadItem {

    BOOL isDownloading = [_fileDownloader isDownloadingIdentifier:aDownloadItem.downloadIdentifier];
    if (isDownloading) {
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            HWIFileDownloadProgress *aFileDownloadProgress = [_fileDownloader downloadProgressForIdentifier:aDownloadItem.downloadIdentifier];
            [aFileDownloadProgress.nativeProgress cancel];
        } else {
            [_fileDownloader cancelDownloadWithIdentifier:aDownloadItem.downloadIdentifier];
        }
    } else {
        aDownloadItem.status = WspxDownloadItemStatusCancelled;
        [self storeDownloadItems];
    }

}

- (void)cancelAllDownloadItems {
    NSArray* allItems = [self.downloadItems copy];
    for(WspxDownloadItem* item in allItems) {
        if (item.status != WspxDownloadItemStatusCompleted) {
            [self cancelDownloadWithItem:item];
        }
    }
}

#pragma mark - Pause Download

- (void)pauseDownloadWithItem:(nonnull WspxDownloadItem *)aDownloadItem {
    BOOL isDownloading = [_fileDownloader isDownloadingIdentifier:aDownloadItem.downloadIdentifier];
    if (isDownloading)
    {
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            HWIFileDownloadProgress *aFileDownloadProgress = [_fileDownloader downloadProgressForIdentifier:aDownloadItem.downloadIdentifier];
            [aFileDownloadProgress.nativeProgress pause];
        } else {
            [_fileDownloader pauseDownloadWithIdentifier:aDownloadItem.downloadIdentifier];
        }
    } else {
        if ((aDownloadItem.status == WspxDownloadItemStatusStarted) || (aDownloadItem.status == WspxDownloadItemStatusPending)) {
            aDownloadItem.status = WspxDownloadItemStatusPaused;
            [self storeDownloadItems];
        }
    }
}

- (void)pauseAllDownloadItems {
    for(WspxDownloadItem* item in self.downloadItems) {
        BOOL isDownloading = [_fileDownloader isDownloadingIdentifier:item.downloadIdentifier];
        if (isDownloading)
        {
            if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
                HWIFileDownloadProgress *aFileDownloadProgress = [_fileDownloader downloadProgressForIdentifier:item.downloadIdentifier];
                [aFileDownloadProgress.nativeProgress pause];
            } else {
                [_fileDownloader pauseDownloadWithIdentifier:item.downloadIdentifier];
            }
        } else {
            if ((item.status == WspxDownloadItemStatusStarted) || (item.status == WspxDownloadItemStatusPending)) {
                item.status = WspxDownloadItemStatusPaused;
                [self storeDownloadItems];
            }
        }
    }
}

#pragma mark - Remove Download Item

- (void)removeDownloadWithItem:(nonnull WspxDownloadItem*)aRemoveDownloadItem {

    BOOL isDownloading = [_fileDownloader isDownloadingIdentifier:aRemoveDownloadItem.downloadIdentifier];
    if (!isDownloading) {
            
        if ([[NSFileManager defaultManager] fileExistsAtPath:aRemoveDownloadItem.localFileURL.path] && [[NSFileManager defaultManager] isDeletableFileAtPath:aRemoveDownloadItem.localFileURL.path]) {
            NSError* aRemoveError = nil;
            [[NSFileManager defaultManager] removeItemAtPath:aRemoveDownloadItem.localFileURL.path error:&aRemoveError];
            
            if (aRemoveError) {
                NSLog(@"ERR: Unable to remove file at %@: %@ (%@, %d)", aRemoveDownloadItem.localFileURL, aRemoveError.localizedDescription, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
            }
        }
        [self.downloadItems removeObject:aRemoveDownloadItem];
        
    } else {
        NSUInteger aFoundDownloadItemIndex = [self.downloadItems indexOfObjectPassingTest:^BOOL(WspxDownloadItem *aDownloadItem, NSUInteger anIndex, BOOL *aStopFlag) {
            if ([aRemoveDownloadItem.downloadIdentifier isEqualToString:aDownloadItem.downloadIdentifier]) {
                return YES;
            }
            return NO;
        }];
        if (aFoundDownloadItemIndex != NSNotFound) {
            WspxDownloadItem *aTempDownloadItem = nil;
            aTempDownloadItem = [self.downloadItems objectAtIndex:aFoundDownloadItemIndex];
            aTempDownloadItem.status = WspxDownloadItemStatusDeleted;
        } else {
            NSLog(@"failed found DownloadItem with : %@", aRemoveDownloadItem.downloadIdentifier);
        }
    }
    [self storeDownloadItems];
}

#pragma mark - Remove All

- (void)removeAllDownloadItems {
    NSArray* allItems = [self.downloadItems copy];
    for(WspxDownloadItem* item in allItems) {
        [self removeDownloadWithItem:item];
    }
}

#pragma mark - Network Activity Indicator

- (void)toggleNetworkActivityIndicatorVisible:(BOOL)visible {
    NSLog(@"toggleNetworkActivityIndicatorVisible --> visible(%d)", visible);
}

- (void)incrementNetworkActivityIndicatorActivityCount
{
    [self toggleNetworkActivityIndicatorVisible:YES];
}

- (void)decrementNetworkActivityIndicatorActivityCount
{
    [self toggleNetworkActivityIndicatorVisible:NO];
}

- (void)reachabilityChanged:(NSNotification *)note {

    UOMReachability* curReach = [note object];
    if (self.delegate && [self.delegate respondsToSelector:@selector(downloadProgressReachableChanged:)]) {
        [self.delegate downloadProgressReachableChanged:curReach];
    }
}

- (void)downloadDidCompleteWithIdentifier:(nonnull NSString *)aDownloadIdentifier
                             localFileURL:(nonnull NSURL *)aLocalFileURL {
    
    NSUInteger aFoundDownloadItemIndex = [self.downloadItems indexOfObjectPassingTest:^BOOL(WspxDownloadItem *aDownloadItem, NSUInteger anIndex, BOOL *aStopFlag) {
        if ([aDownloadItem.downloadIdentifier isEqualToString:aDownloadIdentifier]) {
            return YES;
        }
        return NO;
    }];
    WspxDownloadItem *aCompletedDownloadItem = nil;
    if (aFoundDownloadItemIndex != NSNotFound) {
        NSLog(@"INFO: Download completed (id: %@) (%@, %d)", aDownloadIdentifier, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
        
        aCompletedDownloadItem = [self.downloadItems objectAtIndex:aFoundDownloadItemIndex];
        aCompletedDownloadItem.status = WspxDownloadItemStatusCompleted;
        aCompletedDownloadItem.localFileURL = aLocalFileURL;
        [self storeDownloadItems];
    } else {
        NSLog(@"ERR: Completed download item not found (id: %@) (%@, %d)", aDownloadIdentifier, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(downloadProgressDidCompleteWithItem:)]) {
        [self.delegate downloadProgressDidCompleteWithItem:aCompletedDownloadItem];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:wspxDownloadDidCompleteNotification object:aCompletedDownloadItem];
}

- (void)downloadFailedWithIdentifier:(nonnull NSString *)aDownloadIdentifier
                               error:(nonnull NSError *)anError
                      httpStatusCode:(NSInteger)aHttpStatusCode
                  errorMessagesStack:(nullable NSArray<NSString *> *)anErrorMessagesStack
                          resumeData:(nullable NSData *)aResumeData {
        
    NSUInteger aFoundDownloadItemIndex = [self.downloadItems indexOfObjectPassingTest:^BOOL(WspxDownloadItem *aDownloadItem, NSUInteger anIndex, BOOL *aStopFlag) {
        if ([aDownloadItem.downloadIdentifier isEqualToString:aDownloadIdentifier]) {
            return YES;
        }
        return NO;
    }];
    WspxDownloadItem *aFailedDownloadItem = nil;
    if (aFoundDownloadItemIndex != NSNotFound) {
        aFailedDownloadItem = [self.downloadItems objectAtIndex:aFoundDownloadItemIndex];
        aFailedDownloadItem.lastHttpStatusCode = aHttpStatusCode;
        aFailedDownloadItem.resumeData = aResumeData;
        aFailedDownloadItem.downloadError = anError;
        aFailedDownloadItem.downloadErrorMessagesStack = anErrorMessagesStack;
        // download status heuristics
        if ((aFailedDownloadItem.status != WspxDownloadItemStatusPaused) && (aFailedDownloadItem.status != WspxDownloadItemStatusDeleted)) {
            if (aResumeData.length > 0) {
                if (anError.code == NSURLErrorCancelled) {
                    aFailedDownloadItem.status = WspxDownloadItemStatusPaused;
                } else {
                    aFailedDownloadItem.status = WspxDownloadItemStatusInterrupted;
                }
            } else if ([anError.domain isEqualToString:NSURLErrorDomain] && (anError.code == NSURLErrorCancelled)) {
                aFailedDownloadItem.status = WspxDownloadItemStatusCancelled;
            } else {
                aFailedDownloadItem.status = WspxDownloadItemStatusError;
            }
        }
        [self storeDownloadItems];
        
        switch (aFailedDownloadItem.status) {
            case WspxDownloadItemStatusError:
                NSLog(@"ERR: Download with error %@ (http status: %@) - id: %@ (%@, %d)", @(anError.code), @(aHttpStatusCode), aDownloadIdentifier, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
                break;
            case WspxDownloadItemStatusInterrupted:
                NSLog(@"ERR: Download interrupted with error %@ - id: %@ (%@, %d)", @(anError.code), aDownloadIdentifier, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
                break;
            case WspxDownloadItemStatusCancelled:
                NSLog(@"INFO: Download cancelled - id: %@ (%@, %d)", aDownloadIdentifier, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
                break;
            case WspxDownloadItemStatusPaused:
                NSLog(@"INFO: Download paused - id: %@ (%@, %d)", aDownloadIdentifier, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
                break;
                
            default:
                break;
        }
    } else {
        NSLog(@"ERR: Failed download item not found (id: %@) (%@, %d)", aDownloadIdentifier, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(downloadProgressDidCompleteWithItem:)]) {
        [self.delegate downloadProgressDidCompleteWithItem:aFailedDownloadItem];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:wspxDownloadDidCompleteNotification object:aFailedDownloadItem];
    
}

- (void)downloadStorageAlmostFullWithIdentifier:(NSString *)aDownloadIdentifier
                                          error:(NSError *)anError
                                 httpStatusCode:(NSInteger)aHttpStatusCode
                             errorMessagesStack:(NSArray<NSString *> *)anErrorMessagesStack {
    
    NSUInteger aFoundDownloadItemIndex = [self.downloadItems indexOfObjectPassingTest:^BOOL(WspxDownloadItem *aDownloadItem, NSUInteger anIndex, BOOL *aStopFlag) {
        if ([aDownloadItem.downloadIdentifier isEqualToString:aDownloadIdentifier]) {
            return YES;
        }
        return NO;
    }];
    WspxDownloadItem *aFailedDownloadItem = nil;
    if (aFoundDownloadItemIndex != NSNotFound) {
        aFailedDownloadItem = [self.downloadItems objectAtIndex:aFoundDownloadItemIndex];
        aFailedDownloadItem.lastHttpStatusCode = aHttpStatusCode;
        aFailedDownloadItem.downloadError = anError;
        aFailedDownloadItem.downloadErrorMessagesStack = anErrorMessagesStack;
        // download status heuristics
        if ([anError.domain isEqualToString:NSURLErrorDomain] && (anError.code == NSURLErrorCannotCreateFile)) {
            aFailedDownloadItem.status = WspxDownloadItemStatusInterrupted;
        } else {
            aFailedDownloadItem.status = WspxDownloadItemStatusError;
        }
        [self storeDownloadItems];
        
        switch (aFailedDownloadItem.status) {
            case WspxDownloadItemStatusError:
                NSLog(@"ERR: Download with error %@ (http status: %@) - id: %@ (%@, %d)", @(anError.code), @(aHttpStatusCode), aDownloadIdentifier, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
                break;
            case WspxDownloadItemStatusInterrupted:
                NSLog(@"ERR: Download interrupted with error %@ - id: %@ (%@, %d)", @(anError.code), aDownloadIdentifier, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
                break;
            case WspxDownloadItemStatusCancelled:
                NSLog(@"INFO: Download cancelled - id: %@ (%@, %d)", aDownloadIdentifier, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
                break;
            case WspxDownloadItemStatusPaused:
                NSLog(@"INFO: Download paused - id: %@ (%@, %d)", aDownloadIdentifier, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
                break;
                
            default:
                break;
        }
    } else {
        NSLog(@"ERR: Failed download item not found (id: %@) (%@, %d)", aDownloadIdentifier, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(downloadProgressDidCompleteWithItem:)]) {
        [self.delegate downloadProgressDidCompleteWithItem:aFailedDownloadItem];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:wspxDownloadDidCompleteNotification object:aFailedDownloadItem];
}

#pragma mark HWIFileDownloadDelegate (optional)

- (void)downloadProgressIsSupportResumeWithIdentifier:(NSString *)aDownloadIdentifier maxAge:(NSTimeInterval)maxAge{
    NSUInteger aFoundDownloadItemIndex = [self.downloadItems indexOfObjectPassingTest:^BOOL(WspxDownloadItem *aDownloadItem, NSUInteger anIndex, BOOL *aStopFlag) {
        if ([aDownloadItem.downloadIdentifier isEqualToString:aDownloadIdentifier])
        {
            return YES;
        }
        return NO;
    }];
    if (aFoundDownloadItemIndex != NSNotFound)
    {
        NSLog(@"INFO: Download max-age - :%llu id: %@ (%@, %d)", maxAge, aDownloadIdentifier, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
        
        WspxDownloadItem *aStartedDownloadItem = [self.downloadItems objectAtIndex:aFoundDownloadItemIndex];
        aStartedDownloadItem.downloadMaxAge = maxAge;
        [self storeDownloadItems];
    }
    else
    {
        NSLog(@"ERR: Download max-age item not found (id: %@) (%@, %d)", aDownloadIdentifier, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
    }
}

- (void)downloadProgressChangedForIdentifier2:(nonnull NSString *)aDownloadIdentifier expectedContentLength:(long long)expectedContentLength
{
    NSUInteger aFoundDownloadItemIndex = [self.downloadItems indexOfObjectPassingTest:^BOOL(WspxDownloadItem *aDownloadItem, NSUInteger anIndex, BOOL *aStopFlag) {
        if ([aDownloadItem.downloadIdentifier isEqualToString:aDownloadIdentifier])
        {
            return YES;
        }
        return NO;
    }];
    WspxDownloadItem *aChangedDownloadItem = nil;
    if (aFoundDownloadItemIndex != NSNotFound)
    {
        aChangedDownloadItem = [self.downloadItems objectAtIndex:aFoundDownloadItemIndex];
        if (aChangedDownloadItem.status == WspxDownloadItemStatusPending)
        {
            aChangedDownloadItem.status = WspxDownloadItemStatusStarted;
        }
        
        if (!aChangedDownloadItem.downloadSuggestedFileName) {
            aChangedDownloadItem.downloadSuggestedFileName = [_fileDownloader downloadItemSuggestedFileNameForDownloadID:aDownloadIdentifier];
        }
        HWIFileDownloadProgress *aFileDownloadProgress = [_fileDownloader downloadProgressForIdentifier:aDownloadIdentifier];
        if (aFileDownloadProgress)
        {
            [aChangedDownloadItem setValue:aFileDownloadProgress forKey:@"progress"];
            if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
            {
                aFileDownloadProgress.lastLocalizedDescription = aFileDownloadProgress.nativeProgress.localizedDescription;
                aFileDownloadProgress.lastLocalizedAdditionalDescription = aFileDownloadProgress.nativeProgress.localizedAdditionalDescription;
            }
        }
        aChangedDownloadItem.isSupportResumeWithoutRestart = [_fileDownloader isSupportResumeWithoutRestartForDownloadID:aDownloadIdentifier];
        if (expectedContentLength != -1) {//不知道文件长度的也继续下载
            
            if (expectedContentLength > [self getFreeDiskspaceInBytes]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:wspxDownloadDiskStorageNotEnoughNotification object:nil];
                NSLog(@"post wspxDownloadDiskStorageNotEnoughNotification on:%s expectedSize:%llu freeSpace:%llu", __PRETTY_FUNCTION__, aChangedDownloadItem.expectedFileSizeInBytes, [self getFreeDiskspaceInBytes]);
                [self pauseDownloadWithItem:aChangedDownloadItem];
            }
        }
    }
    
    NSLog(@"onProgressDidChange --> %@", aChangedDownloadItem);
    
    [self storeDownloadItems];
    [[NSNotificationCenter defaultCenter] postNotificationName:wspxDownloadProgressChangedNotification object:aChangedDownloadItem];
}

- (void)downloadProgressChangedForIdentifier:(nonnull NSString *)aDownloadIdentifier
{
    NSUInteger aFoundDownloadItemIndex = [self.downloadItems indexOfObjectPassingTest:^BOOL(WspxDownloadItem *aDownloadItem, NSUInteger anIndex, BOOL *aStopFlag) {
        if ([aDownloadItem.downloadIdentifier isEqualToString:aDownloadIdentifier])
        {
            return YES;
        }
        return NO;
    }];
    WspxDownloadItem *aChangedDownloadItem = nil;
    if (aFoundDownloadItemIndex != NSNotFound)
    {
        aChangedDownloadItem = [self.downloadItems objectAtIndex:aFoundDownloadItemIndex];
        
        aChangedDownloadItem.status = WspxDownloadItemStatusStarted;
        
        
        if (!aChangedDownloadItem.downloadSuggestedFileName) {
            aChangedDownloadItem.downloadSuggestedFileName = [_fileDownloader downloadItemSuggestedFileNameForDownloadID:aDownloadIdentifier];
        }
        HWIFileDownloadProgress *aFileDownloadProgress = [_fileDownloader downloadProgressForIdentifier:aDownloadIdentifier];
        if (aFileDownloadProgress)
        {
            [aChangedDownloadItem setValue:aFileDownloadProgress forKey:@"progress"];
            if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
            {
                aFileDownloadProgress.lastLocalizedDescription = aFileDownloadProgress.nativeProgress.localizedDescription;
                aFileDownloadProgress.lastLocalizedAdditionalDescription = aFileDownloadProgress.nativeProgress.localizedAdditionalDescription;
            }
        }
        aChangedDownloadItem.isSupportResumeWithoutRestart = [_fileDownloader isSupportResumeWithoutRestartForDownloadID:aDownloadIdentifier];
        if (aChangedDownloadItem.expectedFileSizeInBytes != -1) {//不知道文件长度的也继续下载
            
            if (aChangedDownloadItem.expectedFileSizeInBytes > [self getFreeDiskspaceInBytes]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:wspxDownloadDiskStorageNotEnoughNotification object:nil];
                NSLog(@"post wspxDownloadDiskStorageNotEnoughNotification on:%s expectedSize:%llu freeSpace:%llu", __PRETTY_FUNCTION__, aChangedDownloadItem.expectedFileSizeInBytes, [self getFreeDiskspaceInBytes]);
                [self pauseDownloadWithItem:aChangedDownloadItem];
            }
        }
    }
    
    [self storeDownloadItems];
    if (self.delegate && [self.delegate respondsToSelector:@selector(downloadProgressDidChangedWithItem:)]) {
        [self.delegate downloadProgressDidChangedWithItem:aChangedDownloadItem];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:wspxDownloadProgressChangedNotification object:aChangedDownloadItem];
}

- (void)downloadProgressDidStartWithIdentifier:(NSString *)aDownloadIdentifier {
    NSUInteger aFoundDownloadItemIndex = [self.downloadItems indexOfObjectPassingTest:^BOOL(WspxDownloadItem *aDownloadItem, NSUInteger anIndex, BOOL *aStopFlag) {
        if ([aDownloadItem.downloadIdentifier isEqualToString:aDownloadIdentifier])
        {
            return YES;
        }
        return NO;
    }];
    if (aFoundDownloadItemIndex != NSNotFound)
    {
        NSLog(@"INFO: Download started - id: %@ (%@, %d)", aDownloadIdentifier, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
        
        WspxDownloadItem *aStartedDownloadItem = [self.downloadItems objectAtIndex:aFoundDownloadItemIndex];
        aStartedDownloadItem.status = WspxDownloadItemStatusPending;
        [self storeDownloadItems];
        if (self.delegate && [self.delegate respondsToSelector:@selector(downloadProgressDidPendingWithItem:)]) {
            [self.delegate downloadProgressDidPendingWithItem:aStartedDownloadItem];
        }
    }
    else
    {
        NSLog(@"ERR: Pownload started item not found (id: %@) (%@, %d)", aDownloadIdentifier, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
    }
    
}

- (void)downloadPausedWithIdentifier:(nonnull NSString *)aDownloadIdentifier
                          resumeData:(nullable NSData *)aResumeData {
    
    NSUInteger aFoundDownloadItemIndex = [self.downloadItems indexOfObjectPassingTest:^BOOL(WspxDownloadItem *aDownloadItem, NSUInteger anIndex, BOOL *aStopFlag) {
        if ([aDownloadItem.downloadIdentifier isEqualToString:aDownloadIdentifier])
        {
            return YES;
        }
        return NO;
    }];
    if (aFoundDownloadItemIndex != NSNotFound)
    {
        NSLog(@"INFO: Download paused - id: %@ (%@, %d)", aDownloadIdentifier, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
        
        WspxDownloadItem *aPausedDownloadItem = [self.downloadItems objectAtIndex:aFoundDownloadItemIndex];
        aPausedDownloadItem.status = WspxDownloadItemStatusPaused;
        aPausedDownloadItem.resumeData = aResumeData;
        [self storeDownloadItems];
    }
    else
    {
        NSLog(@"ERR: Paused download item not found (id: %@) (%@, %d)", aDownloadIdentifier, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
    }
}

- (void)resumeDownloadWithIdentifier:(nonnull NSString *)aDownloadIdentifier
{
    NSUInteger aFoundDownloadItemIndex = [self.downloadItems indexOfObjectPassingTest:^BOOL(WspxDownloadItem *aDownloadItem, NSUInteger anIndex, BOOL *aStopFlag) {
        if ([aDownloadItem.downloadIdentifier isEqualToString:aDownloadIdentifier])
        {
            return YES;
        }
        return NO;
    }];
    if (aFoundDownloadItemIndex != NSNotFound)
    {
        WspxDownloadItem *aDemoDownloadItem = [self.downloadItems objectAtIndex:aFoundDownloadItemIndex];
        [self startDownloadWithItem:aDemoDownloadItem];
    }
}

- (BOOL)downloadAtLocalFileURL:(nonnull NSURL *)aLocalFileURL isValidForDownloadIdentifier:(nonnull NSString *)aDownloadIdentifier
{
    BOOL anIsValidFlag = YES;
    
    // just checking for file size
    // you might want to check by converting into expected data format (like UIImage) or by scanning for expected content
    
    NSError *anError = nil;
    NSDictionary <NSString *, id> *aFileAttributesDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:aLocalFileURL.path error:&anError];
    if (anError)
    {
        NSLog(@"ERR: Error on getting file size for item at %@: %@ (%@, %d)", aLocalFileURL, anError.localizedDescription, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
        anIsValidFlag = NO;
    }
    else
    {
        unsigned long long aFileSize = [aFileAttributesDictionary fileSize];
        if (aFileSize == 0)
        {
            anIsValidFlag = NO;
        }
        else
        {
            /*// 去掉文件大小的出错判断
            if (aFileSize < 40000)
            {
                NSError *anError = nil;
                NSString *aString = [NSString stringWithContentsOfURL:aLocalFileURL encoding:NSUTF8StringEncoding error:&anError];
                if (anError)
                {
                    NSLog(@"ERR: %@ (%@, %d)", anError.localizedDescription, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
                }
                else
                {
                    NSLog(@"INFO: Downloaded file content for download identifier %@: %@ (%@, %d)", aDownloadIdentifier, aString, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
                }
                anIsValidFlag = NO;
            }
            */
        }
    }
    return anIsValidFlag;
}

- (void)downloadStorageAlmostFull {
    [[NSNotificationCenter defaultCenter] postNotificationName:wspxDownloadDiskStorageNotEnoughNotification object:nil];
}
#pragma mark - Persistence

- (NSString*)plistFilename
{
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"DownloadItems.plist"];
    
    return plistPath;
    
}

- (void)storeDownloadItems
{
    NSMutableArray <NSData *> *aDemoDownloadItemsArchiveArray = [NSMutableArray arrayWithCapacity:self.downloadItems.count];
    for (WspxDownloadItem *aDemoDownloadItem in self.downloadItems)
    {
        NSData *aDemoDownloadItemEncoded = [NSKeyedArchiver archivedDataWithRootObject:aDemoDownloadItem];
        [aDemoDownloadItemsArchiveArray addObject:aDemoDownloadItemEncoded];
    }

    NSString* plistFilename = [self plistFilename];
    [aDemoDownloadItemsArchiveArray writeToFile:plistFilename atomically:YES];
    
}

- (nonnull NSMutableArray<WspxDownloadItem *> *)restoredDownloadItems
{
    NSMutableArray <WspxDownloadItem *> *items = [NSMutableArray array];
    NSString* plistFilename = [self plistFilename];
    NSArray <NSData  *> *aRestoredMutableDataItemsArray = [[NSArray alloc] initWithContentsOfFile:plistFilename];
    if (aRestoredMutableDataItemsArray && aRestoredMutableDataItemsArray.count > 0)
    {
        for (NSData *aDataItem in aRestoredMutableDataItemsArray)
        {
            WspxDownloadItem *aDownloadItem = [NSKeyedUnarchiver unarchiveObjectWithData:aDataItem];
            if (aDownloadItem) {
                [items addObject:aDownloadItem];
            }
        }
    }
    return items;
}

- (BOOL)hasActiveDownloads {
    return [_fileDownloader hasActiveDownloads];
}

- (NSString *)getDiskUsageAndStorageString {
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    NSString *totalFreeSpaceString = @"";
    NSString *totalSpaceString = @"";
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        totalSpaceString = [NSString stringWithFormat:@"%.1f",(((totalSpace/1024ll)/1024ll)/1024.0)];
        totalFreeSpaceString = [NSString stringWithFormat:@"%.1f",(((totalFreeSpace/1024ll)/1024ll)/1024.0)];
    } else {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    
    return [NSString stringWithFormat:@"可用%@GB/共%@GB",totalFreeSpaceString, totalSpaceString];
}

#pragma mark -DeviceStorageUtil
- (uint64_t)getFreeDiskspaceInBytes {
    return [self.fileDownloader getFreeDiskspaceInBytes];
}

/* * * *
 *       every time you run xcode it will change path of the document.
 *       http://stackoverflow.com/questions/21895853/how-can-i-check-that-an-nsdata-blob-is-valid-as-resumedata-for-an-nsurlsessiondo
 * * * */
- (BOOL)isValidResumeData:(NSData *)data{
    if (!data || [data length] < 1) return NO;
    
    NSError *error;
    NSDictionary *resumeDictionary = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:&error];
    if (!resumeDictionary || error) return NO;
    
    NSString *localFilePath = [resumeDictionary objectForKey:@"NSURLSessionResumeInfoLocalPath"];
    NSString *tempFileName = [resumeDictionary objectForKey:@"NSURLSessionResumeInfoTempFileName"];
    if (localFilePath == nil && tempFileName == nil) {
        return NO;
    }
    if (tempFileName) {
        return YES;
    }
    return [[NSFileManager defaultManager] fileExistsAtPath:localFilePath];
}
@end
