//
//  UOneDownloadViewController.m
//  UOneMedia
//
//  Created by wuxin on 5/26/16.
//  Copyright © 2016 chiannetcenter. All rights reserved.
//

#import "WspxDownloadManager.h"
#import "WspxDownloadItem.h"

#import "UOneDownloadViewController.h"
#import "UOneDownloadTableViewCell.h"
#import <QuickLook/QuickLook.h>
#import "NSBundle+WspxUtility.h"
#import "UoneDownloadToolbar.h"
#import "WSPXAlertManager.h"

@interface UOneDownloadViewController ()<QLPreviewControllerDataSource,
QLPreviewControllerDelegate,
UIDocumentInteractionControllerDelegate,
UoneDownloadToolbarDelegate,
SWTableViewCellDelegate,
UOneDownloadTableViewCellDelegate>
@property (nonatomic, strong) UIDocumentInteractionController *docInteractionController;
@end

@implementation UOneDownloadViewController
{
    NSBundle* _bundle;
    NSMutableIndexSet* _selectedIndexSet;
    UIView* _blankView;
    WSPXAlertManager* _alertManager;
    NSMutableArray* _downloadList;
    NSMutableArray* _deleteList;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"UOneMedia" withExtension:@"bundle"]];
    }
    return self;
}
#pragma mark - ViewLifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
  
    // Do any additional setup after loading the view from its nib.

    
    self.downloadManager = [WspxDownloadManager shareInstance];
    _selectedIndexSet = [NSMutableIndexSet indexSet];
    _downloadList = [[NSMutableArray alloc] init];
    _deleteList = [[NSMutableArray alloc] init];
    
    [self refreshDownloadList];
    
    if (!self.tableView) {
        NSLog(@"self.view.frame: %@ bounds:%@", NSStringFromCGRect(self.view.frame), NSStringFromCGRect(self.view.bounds));
        CGRect tableFrame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 47);
        self.tableView = [[UITableView alloc]initWithFrame:tableFrame style:UITableViewStylePlain];
        [self.view addSubview:self.tableView];
    }
    
    //创建 BlankView 背景
    _blankView = [[UIView alloc] initWithFrame:_tableView.bounds];
    /*************
        http://stackoverflow.com/questions/22869670/how-can-i-load-an-image-from-assets-car-compiled-version-of-xcassets-within-an
     ************/
  
    UIImageView *emptyImageView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UOneMedia.bundle/无下载任务"]];
    emptyImageView1.frame = CGRectMake(0, 80, kScreenWidth, 100);
    emptyImageView1.contentMode = UIViewContentModeScaleAspectFit;
    /*
    UILabel *tip1 = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(emptyImageView1.frame) + 20, kScreenWidth, 40)];
    tip1.text = @"暂无下载任务哦~";
    tip1.textAlignment = NSTextAlignmentCenter;
    tip1.textColor = UIColorFromHex(0xb9b9b9);
    [_blankView addSubview:tip1];
    */
    
    [_blankView addSubview:emptyImageView1];
    _blankView.backgroundColor = [UIColor clearColor];
    if (_downloadList && _downloadList.count != 0) {
        _blankView.hidden = YES;
    } else {
        _blankView.hidden = NO;
    }
    
    [_tableView addSubview:_blankView];
    
    if (!self.fileManagerToolbar) {
        self.fileManagerToolbar = [[UoneDownloadToolbar alloc] init];
        self.fileManagerToolbar.customedDelegate = self;
        if (_downloadList && [_downloadList count] != 0) {
            self.fileManagerToolbar.isLabelMode = NO;
        }
        [self.view addSubview:self.fileManagerToolbar];
        [self addConstraintToToolbar];
    }
    
    self.tableView.backgroundColor = UIColorFromHex(0xF6F6F6);
    self.tableView.opaque = 0.4;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    self.tableView.tableFooterView = [UIView new];
    self.tableView.tableFooterView.backgroundColor = [UIColor clearColor];
    [self.tableView reloadData];
    
    [self registerNotification];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIInit
#pragma mark - UIConfig
#pragma mark - UIUpdate
- (void)updateToolbarInterface {
    NSMutableArray *list = _downloadList;
    
    if (_fileManagerToolbar.isEditing) {
        NSInteger selectedNums = [_selectedIndexSet count];
        if (list.count != 0) {
            [_fileManagerToolbar.selectAllButton setEnabled:YES];
            if (selectedNums == list.count) {
                _fileManagerToolbar.selectAllButton.selected = YES;
            } else {
                _fileManagerToolbar.selectAllButton.selected = NO;
            }
        } else {
            _fileManagerToolbar.selectAllButton.selected = NO;
            _fileManagerToolbar.selectAllButton.enabled = NO;
        }
        
        if (list.count == 0 || selectedNums == 0) {
            _fileManagerToolbar.deleteButton.enabled = NO;
        } else {
            _fileManagerToolbar.deleteButton.enabled = YES;
        }
        [_fileManagerToolbar setDeleteTitle:[self getDeleteString]];
    }
    
    if (list.count == 0) {
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        _blankView.hidden = NO;
        _fileManagerToolbar.editButton.enabled = NO;
        _fileManagerToolbar.isLabelMode = YES;
    } else {
        _fileManagerToolbar.editButton.enabled = YES;
        _fileManagerToolbar.isLabelMode = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _blankView.hidden = YES;
    }
}

#pragma mark - AppleDataSource and Delegate
#pragma mark - UITableViewDelegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    //  NSLog(@"editingStyleForRowAtIndexPath:%ld", (long)[indexPath row]);
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableView.isEditing) {
        return;
    }
    WspxDownloadItem* item = _downloadList[indexPath.row];
    WspxDownloadItemStatus itemStatus = item.status;
   
    switch (itemStatus) {
        case WspxDownloadItemStatusNotStarted:
        case WspxDownloadItemStatusCancelled:
        case WspxDownloadItemStatusInterrupted:
        case WspxDownloadItemStatusError:
        {
            [_downloadManager startDownloadWithItem:item];
        }
            break;
        case WspxDownloadItemStatusPending:
        case WspxDownloadItemStatusStarted:
            break;
        case WspxDownloadItemStatusPaused:
        {
            [_downloadManager resumeDownloadWithItem:item];
        }
            break;
        case WspxDownloadItemStatusCompleted:
        {
            if (_delegate && [_delegate respondsToSelector:@selector(downloadViewController:didClickCellForPreview:)]) {
                [_delegate downloadViewController:self didClickCellForPreview:indexPath];
            }
            NSURL *fileUrl = [NSURL fileURLWithPath:item.localFileURL.absoluteString isDirectory:YES];
            BOOL isCanPreview = [QLPreviewController canPreviewItem:fileUrl];
            if (isCanPreview) {
                QLPreviewController *previewController = [[QLPreviewController alloc] init];
                previewController.dataSource = self;
                previewController.delegate = self;

                previewController.currentPreviewItemIndex = indexPath.row;
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self presentViewController:previewController animated:YES completion:nil];
                });
            } else {
                
                if (_delegate && [_delegate respondsToSelector:@selector(downloadViewController:canPreviewItem:)]) {
                    [_delegate downloadViewController:self canPreviewItem:NO];
                } else {
                    [self presentOptionsMenu];
                }
            }
        }
            break;
    }
    
}

- (void)presentOptionsMenu {
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    WspxDownloadItem *item = _downloadList[path.row];
    NSURL *fileURL = item.localFileURL;
    [self setupDocumentControllerWithURL:fileURL];
    self.docInteractionController.URL = fileURL;
    
    
    BOOL isCanPresentOtionsMenu = [self.docInteractionController presentOptionsMenuFromRect:self.tableView.frame
                                                                                     inView:self.tableView
                                                                                   animated:YES];

    if (!isCanPresentOtionsMenu) {
        if (_delegate && [_delegate respondsToSelector:@selector(downloadViewController:canPresentOptionsMenu:)]) {
            [_delegate downloadViewController:self canPresentOptionsMenu:NO];
        } else {
            [self showAlertViewWithTitle:nil
                                 message:@"找不到打开该文件的app"
                             cancelTitle:@"知道了"
                            cancelAction:nil
                            confirmTitle:nil
                           confirmAction:nil];
        }
    }
}
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _downloadList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString * identifier = @"kUOneDownloadTableViewCellIdentifier";
    UOneDownloadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        UINib *nib = [UINib nibWithNibName:@"UOneDownloadTableViewCell" bundle:_bundle];
        [tableView registerNib: nib forCellReuseIdentifier:identifier];
        cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    }
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    BOOL isSelected = NO;
    if (_selectedIndexSet != nil && [_selectedIndexSet containsIndex:(NSUInteger)indexPath.row]) {
        isSelected = YES;
    }
    cell.checkButton.selected = isSelected;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    cell.customDelegate = self;

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[UOneDownloadTableViewCell class]]) {
        
        NSInteger row = indexPath.row;
        WspxDownloadItem* item = _downloadList[row];
        
        [(UOneDownloadTableViewCell*)cell resetWithDownloadItem:item];
        
    }
}

#pragma mark UIDocumentInteractionControllerDelegate
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    if (self.navigationController) {
        return self.navigationController;
    } else {
        return self;
    }
}

#pragma mark QLPreviewControllerDataSource

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    
    return 1;
}
- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    NSURL *fileURL = nil;
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    WspxDownloadItem *item = _downloadList[selectedIndexPath.row];
    fileURL = item.localFileURL;
    return fileURL;
}

#pragma mark - ThirdPartyDataSource and Delegate
#pragma mark  SWTableViewDelegate
- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state {
    if (state == kCellStateCenter) {
        
    }
}

- (void)swipeableTableViewCellDidEndScrolling:(SWTableViewCell *)cell {
    NSLog(@"didEndScrolling: tag:%d",(int)cell.tag);
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    NSLog(@"didTriggerRightUtilityButtonWithIndex:");
    
    if (_delegate && [_delegate respondsToSelector:@selector(downloadViewController:didClickCellForDelete:)]) {
        [_delegate downloadViewController:self didClickCellForDelete:cell];
    }
    
    __weak __typeof(self) weakSelf = self;
    [self showAlertViewWithTitle:nil message:@"确定删除所选下载任务及其文件？" cancelTitle:@"取消" cancelAction:^{
        if (_delegate && [_delegate respondsToSelector:@selector(downloadViewController:isComfirmToDeleteDownloads:)]) {
            [_delegate downloadViewController:weakSelf isComfirmToDeleteDownloads:NO];
        }
    } confirmTitle:@"删除" confirmAction:^{
        NSMutableArray* list = _downloadList;
        NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
        if (indexPath && (indexPath.row < [list count])) {
            WspxDownloadItem* item = [list objectAtIndex:indexPath.row];
            [weakSelf.downloadManager cancelDownloadWithItem:item];
            [weakSelf.downloadManager removeDownloadWithItem:item];
            
            [list removeObject:item];
            [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        }
        if (_delegate && [_delegate respondsToSelector:@selector(downloadViewController:isComfirmToDeleteDownloads:)]) {
            [_delegate downloadViewController:weakSelf isComfirmToDeleteDownloads:YES];
        }
    }];
}

#pragma mark - CustomDataSource and Delegate
#pragma mark WspxDownloadManager Notification

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDownloadDidComplete:) name:wspxDownloadDidCompleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onProgressDidChange:) name:wspxDownloadProgressChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDownloadDidPending:) name:wspxDownloadDidPendingNotification object:nil];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTotalProgressDidChange:) name:wspxTotalDownloadProgressChangedNotification object:nil];
    }
    return;
}

- (void)unregisterNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:wspxDownloadDidCompleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:wspxDownloadProgressChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:wspxDownloadDidPendingNotification object:nil];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:wspxTotalDownloadProgressChangedNotification object:nil];
    }
    return;
}

- (void)onDownloadDidComplete:(NSNotification *)aNotification {
    WspxDownloadItem *aDownloadedItem = (WspxDownloadItem *)aNotification.object;
    NSLog(@"onDownloadDidComplete --> %@", aDownloadedItem);
    NSUInteger aFoundDownloadItemIndex = [self.downloadManager.downloadItems indexOfObjectPassingTest:^BOOL(WspxDownloadItem *aItem, NSUInteger anIndex, BOOL *aStopFlag) {
        if ([aItem.downloadIdentifier isEqualToString:aDownloadedItem.downloadIdentifier])
        {
            return YES;
        }
        return NO;
    }];
    
    if (aFoundDownloadItemIndex != NSNotFound)
    {
        NSIndexPath *anIndexPath = [NSIndexPath indexPathForRow:aFoundDownloadItemIndex inSection:0];
        if([[self.tableView indexPathsForVisibleRows] containsObject:anIndexPath]) {
            UOneDownloadTableViewCell *cell = [self.tableView cellForRowAtIndexPath:anIndexPath];
            [cell resetWithDownloadItem:aDownloadedItem];
        }
    }
    else
    {
        NSLog(@"WARN: Completed download item not found (%@, %d)", [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
    }
}

- (void)onProgressDidChange:(NSNotification *)aNotification {
    WspxDownloadItem *aDownloadedItem = (WspxDownloadItem *)aNotification.object;
    NSLog(@"onProgressDidChange --> %@", aDownloadedItem);
    
    NSUInteger aFoundDownloadItemIndex = [self.downloadManager.downloadItems indexOfObjectPassingTest:^BOOL(WspxDownloadItem *aItem, NSUInteger anIndex, BOOL *aStopFlag) {
        if ([aItem.downloadIdentifier isEqualToString:aDownloadedItem.downloadIdentifier]) {
            return YES;
        }
        return NO;
    }];
    
    if (aFoundDownloadItemIndex != NSNotFound) {
        NSTimeInterval lastChangedUpdateDelta = 10.0;
        if (aDownloadedItem.lastUpdateTime)
        {
            lastChangedUpdateDelta = [[NSDate date] timeIntervalSinceDate:aDownloadedItem.lastUpdateTime];
        }
        if (lastChangedUpdateDelta > 0.25) {
            NSIndexPath *anIndexPath = [NSIndexPath indexPathForRow:aFoundDownloadItemIndex inSection:0];
            if([[self.tableView indexPathsForVisibleRows] containsObject:anIndexPath]) {
                UOneDownloadTableViewCell *cell = [self.tableView cellForRowAtIndexPath:anIndexPath];
                [cell resetWithDownloadItem:aDownloadedItem];
            }
            aDownloadedItem.lastUpdateTime = [NSDate date];
        }
    } else {
        NSLog(@"WARN: Completed download item not found (%@, %d)", [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
    }
}
- (void)onDownloadDidPending:(NSNotification *)aNotification {
    WspxDownloadItem *aDownloadedItem = (WspxDownloadItem *)aNotification.object;
    NSLog(@"onProgressDidChange --> %@", aDownloadedItem);
    
    NSUInteger aFoundDownloadItemIndex = [self.downloadManager.downloadItems indexOfObjectPassingTest:^BOOL(WspxDownloadItem *aItem, NSUInteger anIndex, BOOL *aStopFlag) {
        if ([aItem.downloadIdentifier isEqualToString:aDownloadedItem.downloadIdentifier]) {
            return YES;
        }
        return NO;
    }];
    
    if (aFoundDownloadItemIndex != NSNotFound) {
        NSTimeInterval lastChangedUpdateDelta = 10.0;
        if (aDownloadedItem.lastUpdateTime)
        {
            lastChangedUpdateDelta = [[NSDate date] timeIntervalSinceDate:aDownloadedItem.lastUpdateTime];
        }
        if (lastChangedUpdateDelta > 0.25) {
            NSIndexPath *anIndexPath = [NSIndexPath indexPathForRow:aFoundDownloadItemIndex inSection:0];
            if([[self.tableView indexPathsForVisibleRows] containsObject:anIndexPath]) {
                UOneDownloadTableViewCell *cell = [self.tableView cellForRowAtIndexPath:anIndexPath];
                [cell resetWithDownloadItem:aDownloadedItem];
            }
            aDownloadedItem.lastUpdateTime = [NSDate date];
        }
    } else {
        NSLog(@"WARN: Completed download item not found (%@, %d)", [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
    }
}
- (void)onTotalProgressDidChange:(NSNotification *)aNotification {
    NSLog(@"onTotalProgressDidChange -->");
}

#pragma mark - UOneDownloadTableViewCellDelegate
- (void)tableViewCell:(nonnull UOneDownloadTableViewCell *)cell didClickedDownloadButton:(nonnull UIButton *)button {
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    NSInteger row = indexPath.row;
    if (row < _downloadList.count) {
        WspxDownloadItem * downloadItem = _downloadList[row];
        switch (downloadItem.status) {
            case WspxDownloadItemStatusNotStarted:
            case WspxDownloadItemStatusError:
            case WspxDownloadItemStatusInterrupted:
                [self handleStartDownload:downloadItem];
                break;
            case WspxDownloadItemStatusCompleted:
                if ([downloadItem.downloadErrorMessagesStack count] > 0) {
                    NSLog(@"error stack: %@", downloadItem.downloadErrorMessagesStack);
                }
            case WspxDownloadItemStatusCancelled:
                break;
            case WspxDownloadItemStatusPending:
            case WspxDownloadItemStatusStarted:
                [self handlePauseDownload:downloadItem];
                break;
            case WspxDownloadItemStatusPaused:
                [self handleResumeDownload:downloadItem];
                break;
        }
    }
    
}

- (void)handleStartDownload:(WspxDownloadItem *)aDownloadItem {
    if (_delegate && [_delegate respondsToSelector:@selector(downloadViewController:didClickDownloadItemForStart:)]) {
        [_delegate downloadViewController:self didClickDownloadItemForStart:aDownloadItem];
    }
    [_downloadManager startDownloadWithItem:aDownloadItem];
}

- (void)handlePauseDownload:(WspxDownloadItem *)aDownloadItem {
    if (_delegate && [_delegate respondsToSelector:@selector(downloadViewController:didClickDownloadItemForPause:)]) {
        [_delegate downloadViewController:self didClickDownloadItemForPause:aDownloadItem];
    }
    [_downloadManager pauseDownloadWithItem:aDownloadItem];
}

- (void)handleResumeDownload:(WspxDownloadItem *)aDownloadItem {
    if (_delegate && [_delegate respondsToSelector:@selector(downloadViewController:didClickDownloadItemForResume:)]) {
        [_delegate downloadViewController:self didClickDownloadItemForResume:aDownloadItem];
    }
    [_downloadManager resumeDownloadWithItem:aDownloadItem];
}

- (void)onSelected:(BOOL)selected tableViewCell:(UOneDownloadTableViewCell*)cell {
    NSMutableArray* list = _downloadList;
    
    NSUInteger row = [_tableView indexPathForCell:cell].row;
    WspxDownloadItem *item = [list objectAtIndex:row];
    if (item != nil) {
        if (selected) {
            [_selectedIndexSet addIndex:(NSUInteger)row];
        } else {
            [_selectedIndexSet removeIndex:(NSUInteger)row];
        }
    }
    [self updateToolbarInterface];
}

#pragma mark - UoneDownloadToolbarDelegate
- (void)uoneDownloadToolbar:(UoneDownloadToolbar *)toolbar didClickedEditButton:(UIButton *)button {
    
    if (_delegate && [_delegate respondsToSelector:@selector(downloadViewController:didClickToolBarForEdit:)]) {
        [_delegate downloadViewController:self didClickToolBarForEdit:toolbar];
    }
    
    [_selectedIndexSet removeAllIndexes];
    [self.tableView setEditing:_fileManagerToolbar.isEditing animated:YES];
    [self updateToolbarInterface];
    [_fileManagerToolbar layout];
}

- (void)uoneDownloadToolbar:(UoneDownloadToolbar *)toolbar didClickedDoneButton:(UIButton *)button {
    
    if (_delegate && [_delegate respondsToSelector:@selector(downloadViewController:DidClickToolBarForDone:)]) {
        [_delegate downloadViewController:self DidClickToolBarForDone:toolbar];
    }
    
    [self.tableView setEditing:_fileManagerToolbar.isEditing animated:YES];
    [_selectedIndexSet removeAllIndexes];
    [self updateToolbarInterface];
}

- (void)uoneDownloadToolbar:(UoneDownloadToolbar *)toolbar didClickedSelectAllButton:(UIButton *)button {
    
    if (_delegate && [_delegate respondsToSelector:@selector(downloadViewController:DidClickToolBarForSelectAll:)]) {
        [_delegate downloadViewController:self DidClickToolBarForSelectAll:toolbar];
    }
    
    BOOL isSelectedAll = !button.selected;
    NSMutableArray* list = _downloadList;
    
    if (isSelectedAll) {
        [_selectedIndexSet addIndexesInRange:NSMakeRange(0, (NSUInteger)[list count])];
    } else {
        [_selectedIndexSet removeAllIndexes];
    }
    [self updateToolbarInterface];
    [_fileManagerToolbar layout];
    [_tableView reloadData];
}

- (void)uoneDownloadToolbar:(UoneDownloadToolbar *)toolbar didClickedDeleteButton:(UIButton *)button {
    
    if (_delegate && [_delegate respondsToSelector:@selector(downloadViewController:DidClickToolBarForDelete:)]) {
        [_delegate downloadViewController:self DidClickToolBarForDelete:toolbar];
    }
    
    __weak __typeof(self) weakSelf = self;
    [self showAlertViewWithTitle:nil message:@"确定删除所选下载任务及其文件？" cancelTitle:@"取消" cancelAction:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateToolbarInterface];
            [weakSelf.fileManagerToolbar layout];
            if (_delegate && [_delegate respondsToSelector:@selector(downloadViewController:isComfirmToDeleteDownloads:)]) {
                [_delegate downloadViewController:weakSelf isComfirmToDeleteDownloads:NO];
            }
        });
        NSLog(@"click cancelButton");
    } confirmTitle:@"删除" confirmAction:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSUInteger i = 0;
            [weakSelf.tableView beginUpdates];
            
            NSMutableArray *indexPaths = [NSMutableArray new];
            [_deleteList removeAllObjects];
            if (_selectedIndexSet != nil && [_selectedIndexSet count] > 0) {
                for (i = [_selectedIndexSet lastIndex]; i!= NSNotFound; i = [_selectedIndexSet indexLessThanIndex: i]) {
                    WspxDownloadItem *item = [_downloadList objectAtIndex:i];
                    if (item) {
                        [_deleteList addObject:item];
                        [_downloadList removeObject:item];
                        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                        [indexPaths addObject:indexPath];
                    }
                }
                [_selectedIndexSet removeAllIndexes];
                [weakSelf.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
                [weakSelf.tableView endUpdates];
                [self deleteDownloadItemOfDownloadManager];
                [_deleteList removeAllObjects];
                [weakSelf updateToolbarInterface];
                [weakSelf.fileManagerToolbar layout];
            }
            
            if (_delegate && [_delegate respondsToSelector:@selector(downloadViewController:isComfirmToDeleteDownloads:)]) {
                [_delegate downloadViewController:weakSelf isComfirmToDeleteDownloads:YES];
            }
        });
    }];
}
#pragma mark - Target-Action Event
#pragma mark - PublicMethod
#pragma mark - PrivateMethod

-(void) refreshDownloadList {
    [_downloadList removeAllObjects];
    if (self.downloadManager.downloadItems && [self.downloadManager.downloadItems count] != 0) {
        NSArray *downloadItems = [[self.downloadManager downloadItems] copy];
        for (WspxDownloadItem* item in downloadItems) {
            if (item.status == WspxDownloadItemStatusDeleted) {
                [self.downloadManager removeDownloadWithItem:item];
            } else {
                [_downloadList addObject:item];
            }
        }
    }
}

- (void) deleteDownloadItemOfDownloadManager {
    if (_deleteList && [_deleteList count] != 0) {
        
        if ([_deleteList count] == [_downloadList count]) {
            [self.downloadManager cancelAllDownloadItems];
            [self.downloadManager removeAllDownloadItems];
            return;
        }
        
        NSArray *downloadItems = [[self.downloadManager downloadItems] copy];
        for (WspxDownloadItem *item1 in _deleteList) {
            if (downloadItems && [downloadItems count] != 0) {
                for (WspxDownloadItem *item2 in downloadItems) {
                    if ([item2.downloadIdentifier isEqualToString:item1.downloadIdentifier]) {
                        [self.downloadManager cancelDownloadWithItem:item2];
                        [self.downloadManager removeDownloadWithItem:item2];
                    }
                }
            }
        }
        return;
    }
}

- (void)showAlertViewWithTitle:(nullable NSString*)title
                       message:(nullable NSString*)message
                   cancelTitle:(nullable NSString*)cancelTitle
                  cancelAction:(void(^ __nullable)())cancelBlock
                  confirmTitle:(nullable NSString*)confirmTitle
                 confirmAction:(void(^ __nullable)()) confirmBlock {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:confirmTitle
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) {
                                                                  if (confirmBlock) {
                                                                      confirmBlock();
                                                                  }
                                                              }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 if (cancelBlock) {
                                                                     cancelBlock();
                                                                 }
                                                             }];
        [alertController addAction:confirmAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        _alertManager = [[WSPXAlertManager alloc] init];
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:cancelTitle
                                                  otherButtonTitles: confirmTitle, nil];
        alertView.didClickedButtonHandler = ^BOOL(UIAlertView* alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                if (confirmBlock) {
                    confirmBlock();
                }
            } else {
                if (cancelBlock) {
                    cancelBlock();
                }
            }
            return YES;
        };
        
        [_alertManager push:alertView];
    }
}

- (NSString*)getDeleteString {
    NSString *deleteString = @"删除";
    if (_selectedIndexSet && [_selectedIndexSet count] != 0) {
        deleteString = [NSString stringWithFormat:@"删除(%d)",[_selectedIndexSet count]];
    }
    return deleteString;
}

- (void)setupDocumentControllerWithURL:(NSURL *)url {
    if (self.docInteractionController == nil)
    {
        self.docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
        self.docInteractionController.delegate = self;
    }
    else
    {
        self.docInteractionController.URL = url;
    }
}

- (void)setQLPreviewControllerWithURL:(NSURL *)url {
    
}

- (void)addConstraintToToolbar {
    self.fileManagerToolbar.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:self.fileManagerToolbar
                                                                            attribute:NSLayoutAttributeLeading
                                                                            relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view
                                                                            attribute:NSLayoutAttributeLeading
                                                                            multiplier:1
                                                                            constant:0];
    NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:self.fileManagerToolbar
                                                                         attribute:NSLayoutAttributeTrailing
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view
                                                                         attribute:NSLayoutAttributeTrailing
                                                                        multiplier:1
                                                                          constant:0];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.fileManagerToolbar
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeWidth
                                                                      multiplier:1
                                                                        constant:0];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.fileManagerToolbar
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeHeight
                                                                       multiplier:1
                                                                         constant:47];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.fileManagerToolbar
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1
                                                                         constant:0];
    [self.view addConstraints:@[leadingConstraint, trailingConstraint, widthConstraint, heightConstraint, bottomConstraint]];
}
@end
